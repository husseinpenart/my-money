import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:money/core/network/backend_message.dart';
import 'package:money/feature/auth/presentation/bloc/contact/contact_event.dart';
import 'package:money/feature/auth/presentation/bloc/contact/contact_state.dart';
import 'package:money/feature/model/contact/contact_list_options.dart';
import 'package:money/feature/model/contact/contact_model.dart';
import 'package:money/feature/model/search_models/search_models.dart';
// مسیر DataSource را مطابق پروژه‌ات تنظیم کن
import 'package:money/feature/data/dataResource/contact_remote_data_source.dart';

class ContactBloc extends Bloc<ContactEvent, ContactState> {
  final ContactRemoteDataSource remoteDataSource;

  static const int _pageSize = 20;
  static const Duration _debounce = Duration(milliseconds: 400);

  /// با هر بارگذاری صفحه‌ی اول زیاد می‌شود تا پاسخ‌های قدیمی نادیده گرفته شوند
  int _gen = 0;
  CancelToken? _cancel;

  ContactBloc({required this.remoteDataSource}) : super(const ContactState()) {
    on<ContactsFetched>(_onFetched, transformer: restartable());
    on<ContactQueryChanged>(_onQuery, transformer: restartable());
    on<ContactFilterChanged>(_onFilter, transformer: restartable());
    on<ContactSortChanged>(_onSort, transformer: restartable());
    on<ContactsLoadMore>(_onLoadMore, transformer: droppable());
    on<ContactCreated>(_onCreated, transformer: sequential());
    on<ContactsImported>(_onImported, transformer: sequential());
    on<ContactUpdated>(_onUpdated, transformer: sequential());
    on<ContactDeleted>(_onDeleted, transformer: sequential());
  }

  // ───────────── دریافت و فیلتر ─────────────
  Future<void> _onFetched(ContactsFetched e, Emitter<ContactState> emit) async {
    try {
      if (state.items.isEmpty) {
        emit(state.copyWith(status: ContactsStatus.loading, clearError: true));
      }
      await _fetchFirst(emit, withStats: true);
    } finally {
      if (e.done != null && !e.done!.isCompleted) e.done!.complete();
    }
  }

  Future<void> _onQuery(
    ContactQueryChanged e,
    Emitter<ContactState> emit,
  ) async {
    final q = e.query.trim();
    if (q == state.query) return;
    emit(state.copyWith(query: q, isRefreshing: true));
    await Future<void>.delayed(_debounce); // debounce
    if (emit.isDone) return;
    await _fetchFirst(emit);
  }

  Future<void> _onFilter(
    ContactFilterChanged e,
    Emitter<ContactState> emit,
  ) async {
    emit(state.copyWith(filter: e.filter, isRefreshing: true));
    await _fetchFirst(emit);
  }

  Future<void> _onSort(ContactSortChanged e, Emitter<ContactState> emit) async {
    emit(state.copyWith(sort: e.sort, isRefreshing: true));
    await _fetchFirst(emit);
  }

  Future<void> _fetchFirst(
    Emitter<ContactState> emit, {
    bool withStats = false,
  }) async {
    final gen = ++_gen;
    _cancel?.cancel();
    final token = _cancel = CancelToken();

    try {
      final r = await Future.wait<dynamic>([
        remoteDataSource.fetch(
          pageNumber: 1,
          pageSize: _pageSize,
          query: state.query,
          filter: state.filter,
          sort: state.sort,
          cancelToken: token,
        ),
        if (withStats) remoteDataSource.stats(),
      ]);
      if (gen != _gen || emit.isDone) return;

      final page = r[0] as PagedResult<ContactModel>;
      emit(
        state.copyWith(
          status: ContactsStatus.success,
          items: page.items,
          pageNumber: page.pageNumber,
          totalPages: page.totalPages,
          totalItems: page.totalItems,
          isRefreshing: false,
          isLoadingMore: false,
          stats: withStats ? r[1] as ContactStats : null,
          clearError: true,
        ),
      );
    } catch (err) {
      if (err is DioException && CancelToken.isCancel(err)) return;
      if (gen != _gen || emit.isDone) return;
      if (state.items.isEmpty) {
        emit(
          state.copyWith(
            status: ContactsStatus.failure,
            isRefreshing: false,
            error: _msg(err),
          ),
        );
      } else {
        emit(
          state.copyWith(
            isRefreshing: false,
            feedback: ContactFeedback.error(_msg(err)),
          ),
        );
      }
    }
  }

  // ───────────── صفحه‌ی بعد ─────────────
  Future<void> _onLoadMore(
    ContactsLoadMore e,
    Emitter<ContactState> emit,
  ) async {
    if (state.status != ContactsStatus.success ||
        !state.hasMore ||
        state.isLoadingMore ||
        state.isRefreshing ||
        state.isSubmitting) {
      return;
    }
    final gen = _gen;
    emit(state.copyWith(isLoadingMore: true));
    try {
      final next = await remoteDataSource.fetch(
        pageNumber: state.pageNumber + 1,
        pageSize: _pageSize,
        query: state.query,
        filter: state.filter,
        sort: state.sort,
      );
      if (gen != _gen) {
        emit(state.copyWith(isLoadingMore: false));
        return;
      }
      final have = state.items.map((c) => c.contactId).toSet();
      emit(
        state.copyWith(
          items: [
            ...state.items,
            ...next.items.where((c) => !have.contains(c.contactId)),
          ],
          pageNumber: next.pageNumber,
          totalPages: next.totalPages,
          totalItems: next.totalItems,
          isLoadingMore: false,
        ),
      );
    } catch (err) {
      emit(
        state.copyWith(
          isLoadingMore: false,
          feedback: ContactFeedback.error(_msg(err)),
        ),
      );
    }
  }

  // ───────────── ساخت ─────────────
  Future<void> _onCreated(ContactCreated e, Emitter<ContactState> emit) async {
    emit(state.copyWith(isSubmitting: true));
    try {
      await remoteDataSource.create(name: e.name, phoneNumber: e.phoneNumber);
      await _reloadQuiet(emit);
      emit(
        state.copyWith(
          status: ContactsStatus.success,
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

  // ───────────── ثبت گروهی از مخاطبین گوشی ─────────────
  Future<void> _onImported(
    ContactsImported e,
    Emitter<ContactState> emit,
  ) async {
    final total = e.entries.length;
    emit(state.copyWith(isSubmitting: true, importDone: 0, importTotal: total));

    var ok = 0;
    String? firstError;
    for (var i = 0; i < total; i++) {
      try {
        await remoteDataSource.create(
          name: e.entries[i].name,
          phoneNumber: e.entries[i].phoneNumber,
        );
        ok++;
      } catch (err) {
        firstError ??= _msg(err); // مثلاً مخاطب تکراری
      }
      emit(state.copyWith(importDone: i + 1));
    }

    await _reloadQuiet(emit);

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
        status: ContactsStatus.success,
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

  // ───────────── ویرایش ─────────────
  Future<void> _onUpdated(ContactUpdated e, Emitter<ContactState> emit) async {
    emit(state.copyWith(isSubmitting: true));
    try {
      final updated = await remoteDataSource.update(
        contactId: e.contactId,
        name: e.name,
        phoneNumber: e.phoneNumber,
      );
      emit(
        state.copyWith(
          isSubmitting: false,
          items: [
            for (final c in state.items)
              c.contactId == updated.contactId ? updated : c,
          ],
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

  // ───────────── حذف ─────────────
  Future<void> _onDeleted(ContactDeleted e, Emitter<ContactState> emit) async {
    try {
      await remoteDataSource.delete(e.contactId);
      final s = state.stats;
      emit(
        state.copyWith(
          items: state.items.where((c) => c.contactId != e.contactId).toList(),
          totalItems: state.totalItems > 0 ? state.totalItems - 1 : 0,
          stats: s == null
              ? null
              : ContactStats(
                  total: s.total > 0 ? s.total - 1 : 0,
                  demanders: s.demanders,
                  debtors: s.debtors,
                ),
          feedback: ContactFeedback.success('با موفقیت حذف شد'),
        ),
      );
    } catch (err) {
      // مثلاً: «این مخاطب بدهی یا طلب ثبت‌شده دارد و قابل حذف نیست»
      emit(state.copyWith(feedback: ContactFeedback.error(_msg(err))));
    }
  }

  /// بعد از ساخت/ثبت گروهی؛ خطا نادیده گرفته می‌شود چون خود عملیات موفق بوده
  Future<void> _reloadQuiet(Emitter<ContactState> emit) async {
    final gen = ++_gen;
    try {
      final r = await Future.wait<dynamic>([
        remoteDataSource.fetch(
          pageNumber: 1,
          pageSize: _pageSize,
          query: state.query,
          filter: state.filter,
          sort: state.sort,
        ),
        remoteDataSource.stats(),
      ]);
      if (gen != _gen) return;
      final page = r[0] as PagedResult<ContactModel>;
      emit(
        state.copyWith(
          items: page.items,
          pageNumber: page.pageNumber,
          totalPages: page.totalPages,
          totalItems: page.totalItems,
          stats: r[1] as ContactStats,
        ),
      );
    } catch (_) {}
  }

  String _msg(Object e) =>
      e is ContactApiException ? e.message : backendMessage(e);

  @override
  Future<void> close() {
    _cancel?.cancel();
    return super.close();
  }
}
