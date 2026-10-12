import 'dart:async';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:money/core/cache/contact_cache.dart';
import 'package:money/core/cache/sync_repository.dart';
import 'package:money/core/network/backend_message.dart';
import 'package:money/feature/auth/presentation/bloc/contact/contact_event.dart';
import 'package:money/feature/auth/presentation/bloc/contact/contact_state.dart';
import 'package:money/feature/data/dataResource/contact_remote_data_source.dart';
import 'package:money/feature/model/contact/contact_model.dart';

class ContactBloc extends Bloc<ContactEvent, ContactState> {
  final ContactRemoteDataSource remote;
  final ContactCache cache;
  final SyncRepository sync;

  static const int _pageSize = 20;
  int _visible = _pageSize;
  late final VoidCallback _onCache;

  ContactBloc({required this.remote, required this.cache, required this.sync})
    : super(const ContactState()) {
    on<ContactsFetched>(_onFetched);
    on<ContactsRefreshed>(_onRefreshed, transformer: droppable());
    on<ContactsLocalChanged>((e, emit) => _project(emit));
    on<ContactQueryChanged>(_onQuery);
    on<ContactFilterChanged>(_onFilter);
    on<ContactSortChanged>(_onSort);
    on<ContactsLoadMore>(_onLoadMore);
    on<ContactCreated>(_onCreated, transformer: sequential());
    on<ContactsImported>(_onImported, transformer: sequential());
    on<ContactUpdated>(_onUpdated, transformer: sequential());
    on<ContactDeleted>(_onDeleted, transformer: sequential());

    // هر تغییر کش (Command یا همگام‌سازی) خودکار روی لیست اعمال می‌شود
    _onCache = () {
      if (!isClosed) add(const ContactsLocalChanged());
    };
    cache.addListener(_onCache);
  }

  // ───────────── نمایش (محلی، بدون شبکه) ─────────────
  void _project(Emitter<ContactState> emit, {ContactsStatus? status}) {
    final all = cache.query(
      query: state.query,
      filter: state.filter,
      sort: state.sort,
    );
    final shown = all.take(_visible).toList();
    emit(
      state.copyWith(
        status:
            status ?? (cache.hasData ? ContactsStatus.success : state.status),
        items: shown,
        totalItems: all.length,
        pageNumber: shown.isEmpty ? 1 : (shown.length / _pageSize).ceil(),
        totalPages: (all.length / _pageSize).ceil(),
        stats: cache.stats,
        lastSyncedAt: cache.syncedAt,
        isLoadingMore: false,
        clearError: true,
      ),
    );
  }

  Future<void> _onFetched(ContactsFetched e, Emitter<ContactState> emit) async {
    try {
      if (cache.hasData) {
        _project(emit);
        return;
      }
      emit(state.copyWith(status: ContactsStatus.loading, clearError: true));
      await _sync(emit, toast: false);
    } finally {
      _complete(e.done);
    }
  }

  Future<void> _onRefreshed(
    ContactsRefreshed e,
    Emitter<ContactState> emit,
  ) async {
    try {
      await _sync(emit, toast: true);
    } finally {
      _complete(e.done);
    }
  }

  Future<void> _sync(Emitter<ContactState> emit, {required bool toast}) async {
    emit(state.copyWith(isRefreshing: true));
    try {
      final r = await sync.refresh();
      _project(emit, status: ContactsStatus.success);
      emit(
        state.copyWith(
          isRefreshing: false,
          feedback: toast ? ContactFeedback.success(r.message) : null,
        ),
      );
    } catch (err) {
      final msg = _msg(err);
      if (cache.hasData) {
        _project(emit);
        emit(
          state.copyWith(
            isRefreshing: false,
            feedback: ContactFeedback.error(msg),
          ),
        );
      } else {
        emit(
          state.copyWith(
            status: ContactsStatus.failure,
            isRefreshing: false,
            error: msg,
          ),
        );
      }
    }
  }

  void _complete(Completer<void>? c) {
    if (c != null && !c.isCompleted) c.complete();
  }

  // ───────────── جستجو / فیلتر / مرتب‌سازی / صفحه‌ی بعد (محلی) ─────────────
  void _onQuery(ContactQueryChanged e, Emitter<ContactState> emit) {
    final q = e.query.trim();
    if (q == state.query) return;
    _visible = _pageSize;
    emit(state.copyWith(query: q));
    _project(emit);
  }

  void _onFilter(ContactFilterChanged e, Emitter<ContactState> emit) {
    _visible = _pageSize;
    emit(state.copyWith(filter: e.filter));
    _project(emit);
  }

  void _onSort(ContactSortChanged e, Emitter<ContactState> emit) {
    _visible = _pageSize;
    emit(state.copyWith(sort: e.sort));
    _project(emit);
  }

  void _onLoadMore(ContactsLoadMore e, Emitter<ContactState> emit) {
    if (!state.hasMore) return;
    _visible += _pageSize;
    _project(emit);
  }

  // ───────────── Commandها (نتیجه مستقیم در کش اعمال می‌شود) ─────────────
  Future<void> _onCreated(ContactCreated e, Emitter<ContactState> emit) async {
    emit(state.copyWith(isSubmitting: true));
    try {
      await remote.create(name: e.name, phoneNumber: e.phoneNumber);
      emit(
        state.copyWith(
          isSubmitting: false,
          feedback: ContactFeedback.success('مخاطب با موفقیت ثبت شد'),
        ),
      );
    } catch (err) {
      emit(
        state.copyWith(
          isSubmitting: false,
          feedback: ContactFeedback.error(_msg(err)),
        ),
      );
    }
  }

  Future<void> _onImported(
    ContactsImported e,
    Emitter<ContactState> emit,
  ) async {
    final total = e.entries.length;
    emit(state.copyWith(isSubmitting: true, importDone: 0, importTotal: total));

    var ok = 0;
    String? firstError;
    await cache.runBatch(() async {
      for (var i = 0; i < total; i++) {
        try {
          await remote.create(
            name: e.entries[i].name,
            phoneNumber: e.entries[i].phoneNumber,
          );
          ok++;
        } catch (err) {
          firstError ??= _msg(err); // مثلاً مخاطب تکراری
        }
        emit(state.copyWith(importDone: i + 1));
      }
    });

    if (ok == 0) {
      emit(
        state.copyWith(
          isSubmitting: false,
          importDone: 0,
          importTotal: 0,
          feedback: ContactFeedback.error(
            firstError ?? 'ثبت مخاطبین ناموفق بود',
          ),
        ),
      );
      return;
    }
    final failed = total - ok;
    emit(
      state.copyWith(
        isSubmitting: false,
        importDone: 0,
        importTotal: 0,
        feedback: ContactFeedback.success(
          failed == 0
              ? '$ok مخاطب با موفقیت اضافه شد'
              : '$ok مخاطب اضافه شد؛ $failed مورد تکراری یا ناموفق بود',
        ),
      ),
    );
  }

  Future<void> _onUpdated(ContactUpdated e, Emitter<ContactState> emit) async {
    emit(state.copyWith(isSubmitting: true));
    try {
      await remote.update(
        contactId: e.contactId,
        name: e.name,
        phoneNumber: e.phoneNumber,
      );
      emit(
        state.copyWith(
          isSubmitting: false,
          feedback: ContactFeedback.success('با موفقیت ویرایش شد'),
        ),
      );
    } catch (err) {
      emit(
        state.copyWith(
          isSubmitting: false,
          feedback: ContactFeedback.error(_msg(err)),
        ),
      );
    }
  }

  Future<void> _onDeleted(ContactDeleted e, Emitter<ContactState> emit) async {
    try {
      await remote.delete(e.contactId);
      emit(
        state.copyWith(feedback: ContactFeedback.success('با موفقیت حذف شد')),
      );
    } catch (err) {
      // مثلاً: «این مخاطب بدهی یا طلب ثبت‌شده دارد و قابل حذف نیست»
      emit(state.copyWith(feedback: ContactFeedback.error(_msg(err))));
    }
  }

  String _msg(Object e) =>
      e is ContactApiException ? e.message : backendMessage(e);

  @override
  Future<void> close() {
    cache.removeListener(_onCache);
    return super.close();
  }
}
