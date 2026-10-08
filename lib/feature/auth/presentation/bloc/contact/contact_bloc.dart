import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:money/core/network/backend_message.dart';
import 'package:money/feature/auth/presentation/bloc/contact/contact_event.dart';
import 'package:money/feature/auth/presentation/bloc/contact/contact_state.dart';
import 'package:money/feature/data/dataResource/contact_remote_data_source.dart';
import 'package:money/feature/model/contact/contact_model.dart';
import 'package:money/feature/model/search_models/search_models.dart';

class ContactBloc extends Bloc<ContactEvent, ContactState> {
  final ContactRemoteDataSource remoteDataSource;
  static const int _pageSize = 20;

  ContactBloc({required this.remoteDataSource}) : super(const ContactState()) {
    on<ContactsFetched>(_onFetched, transformer: droppable());
    on<ContactsLoadMore>(_onLoadMore, transformer: droppable());
    on<ContactCreated>(_onCreated, transformer: sequential());
    on<ContactsImported>(_onImported, transformer: sequential());
    on<ContactUpdated>(_onUpdated, transformer: sequential());
    on<ContactDeleted>(_onDeleted, transformer: sequential());
  }

  // ───────────── دریافت ─────────────
  Future<void> _onFetched(
    ContactsFetched event,
    Emitter<ContactState> emit,
  ) async {
    try {
      if (state.items.isEmpty) {
        emit(state.copyWith(status: ContactsStatus.loading, clearError: true));
      }
      final page = await remoteDataSource.getAll(
        pageNumber: 1,
        pageSize: _pageSize,
      );
      emit(
        _applyPage(page).copyWith(
          status: ContactsStatus.success,
          isLoadingMore: false,
          clearError: true,
        ),
      );
    } catch (e) {
      if (state.items.isEmpty) {
        emit(
          state.copyWith(status: ContactsStatus.failure, error: _messageOf(e)),
        );
      } else {
        emit(state.copyWith(feedback: ContactFeedback.error(_messageOf(e))));
      }
    } finally {
      if (event.done != null && !event.done!.isCompleted) {
        event.done!.complete();
      }
    }
  }

  Future<void> _onLoadMore(
    ContactsLoadMore event,
    Emitter<ContactState> emit,
  ) async {
    if (state.status != ContactsStatus.success ||
        !state.hasMore ||
        state.isSubmitting) {
      return;
    }
    emit(state.copyWith(isLoadingMore: true));
    try {
      final next = await remoteDataSource.getAll(
        pageNumber: state.pageNumber + 1,
        pageSize: _pageSize,
      );
      emit(
        state.copyWith(
          items: [...state.items, ...next.items],
          pageNumber: next.pageNumber,
          totalPages: next.totalPages,
          totalItems: next.totalItems,
          isLoadingMore: false,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isLoadingMore: false,
          feedback: ContactFeedback.error(_messageOf(e)),
        ),
      );
    }
  }

  // ───────────── ساخت ─────────────
  Future<void> _onCreated(
    ContactCreated event,
    Emitter<ContactState> emit,
  ) async {
    emit(state.copyWith(isSubmitting: true));
    try {
      final created = await remoteDataSource.create(
        name: event.name,
        phoneNumber: event.phoneNumber,
      );

      final page = await _reload();
      final base = page != null
          ? _applyPage(page)
          : state.copyWith(
              items: [created, ...state.items],
              totalItems: state.totalItems + 1,
            );

      emit(
        base.copyWith(
          status: ContactsStatus.success,
          isSubmitting: false,
          feedback: ContactFeedback.success('مخاطب با موفقیت ثبت شد'),
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isSubmitting: false,
          feedback: ContactFeedback.error(_messageOf(e)),
        ),
      );
    }
  }

  // ───────────── ثبت گروهی از مخاطبین گوشی ─────────────
  Future<void> _onImported(
    ContactsImported event,
    Emitter<ContactState> emit,
  ) async {
    final total = event.entries.length;
    emit(state.copyWith(isSubmitting: true, importDone: 0, importTotal: total));

    var ok = 0;
    String? firstError;

    for (var i = 0; i < total; i++) {
      final e = event.entries[i];
      try {
        await remoteDataSource.create(name: e.name, phoneNumber: e.phoneNumber);
        ok++;
      } catch (err) {
        firstError ??= _messageOf(err); // مثلاً مخاطب تکراری
      }
      emit(state.copyWith(importDone: i + 1));
    }

    final page = await _reload();
    final base = page != null ? _applyPage(page) : state;

    if (ok == 0) {
      emit(
        base.copyWith(
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
      base.copyWith(
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
  Future<void> _onUpdated(
    ContactUpdated event,
    Emitter<ContactState> emit,
  ) async {
    emit(state.copyWith(isSubmitting: true));
    try {
      final updated = await remoteDataSource.update(
        contactId: event.contactId,
        name: event.name,
        phoneNumber: event.phoneNumber,
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
    } catch (e) {
      emit(
        state.copyWith(
          isSubmitting: false,
          feedback: ContactFeedback.error(_messageOf(e)),
        ),
      );
    }
  }

  // ───────────── حذف ─────────────
  Future<void> _onDeleted(
    ContactDeleted event,
    Emitter<ContactState> emit,
  ) async {
    try {
      await remoteDataSource.delete(event.contactId);
      emit(
        state.copyWith(
          items: state.items
              .where((c) => c.contactId != event.contactId)
              .toList(),
          totalItems: state.totalItems > 0 ? state.totalItems - 1 : 0,
          feedback: ContactFeedback.success('با موفقیت حذف شد'),
        ),
      );
    } catch (e) {
      // مثلاً: «این مخاطب بدهی یا طلب ثبت‌شده دارد و قابل حذف نیست»
      emit(state.copyWith(feedback: ContactFeedback.error(_messageOf(e))));
    }
  }

  // ───────────── helpers ─────────────
  Future<PagedResult<ContactModel>?> _reload() async {
    try {
      return await remoteDataSource.getAll(pageNumber: 1, pageSize: _pageSize);
    } catch (_) {
      return null;
    }
  }

  ContactState _applyPage(PagedResult<ContactModel> p) => state.copyWith(
    items: p.items,
    pageNumber: p.pageNumber,
    totalPages: p.totalPages,
    totalItems: p.totalItems,
  );

  String _messageOf(Object e) =>
      e is ContactApiException ? e.message : backendMessage(e);
}
