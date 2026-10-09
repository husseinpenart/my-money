import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:money/core/network/backend_message.dart';
import 'package:money/core/network/notification_read_store.dart';
import 'package:money/feature/auth/presentation/bloc/notification/notification_event.dart';
import 'package:money/feature/auth/presentation/bloc/notification/notification_state.dart';
import 'package:money/feature/data/dataResource/notification_remote_data_source.dart';
import 'package:money/feature/model/notification/notification_models.dart';


class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  final NotificationRemoteDataSource remote;
  final NotificationReadStore store;

  static const Duration _debounce = Duration(milliseconds: 400);
  static const int _pageSize = 15;

  CancelToken? _cancel;

  NotificationBloc({required this.remote, required this.store})
      : super(const NotificationState()) {
    on<NotificationStarted>(_onStarted, transformer: droppable());
    on<NotificationSummaryRequested>(_onSummary, transformer: droppable());
    on<NotificationRefreshed>(_onRefreshed, transformer: restartable());
    on<NotificationQueryChanged>(_onQuery, transformer: restartable());
    on<NotificationFilterChanged>(_onFilter, transformer: restartable());
    on<NotificationLoadMore>(_onLoadMore, transformer: droppable());
    on<NotificationRead>(_onRead, transformer: sequential());
    on<NotificationAllRead>(_onAllRead, transformer: sequential());
  }

  Future<void> _onStarted(NotificationStarted e, Emitter<NotificationState> emit) async {
    emit(state.copyWith(readKeys: store.load()));
    await _loadSummary(emit);
  }

  Future<void> _onSummary(NotificationSummaryRequested e, Emitter<NotificationState> emit) =>
      _loadSummary(emit);

  Future<void> _loadSummary(Emitter<NotificationState> emit) async {
    try {
      final s = await remote.fetchSummary();
      emit(state.copyWith(summary: s));
    } catch (_) {
      // شمارنده‌ی زنگوله نباید خطا نشان بدهد
    }
  }

  Future<void> _onRefreshed(NotificationRefreshed e, Emitter<NotificationState> emit) async {
    try {
      await _loadSummary(emit);
      await _fetchFirst(emit, showLoading: state.items.isEmpty);
    } finally {
      if (e.done != null && !e.done!.isCompleted) e.done!.complete();
    }
  }

  Future<void> _onQuery(NotificationQueryChanged e, Emitter<NotificationState> emit) async {
    final q = e.query.trim();
    emit(state.copyWith(query: q, status: NotificationStatus.loading, clearError: true));
    await Future<void>.delayed(_debounce);
    await _fetchFirst(emit, showLoading: false);
  }

  Future<void> _onFilter(NotificationFilterChanged e, Emitter<NotificationState> emit) async {
    emit(state.copyWith(
      filter: e.filter,
      status: NotificationStatus.loading,
      clearError: true,
    ));
    await _fetchFirst(emit, showLoading: false);
  }

  Future<void> _fetchFirst(Emitter<NotificationState> emit, {required bool showLoading}) async {
    _cancel?.cancel();
    final token = _cancel = CancelToken();

    if (showLoading) {
      emit(state.copyWith(status: NotificationStatus.loading, clearError: true));
    }

    try {
      final page = await remote.fetchPage(
        query: state.query,
        filter: state.filter,
        pageNumber: 1,
        pageSize: _pageSize,
        cancelToken: token,
      );
      emit(state.copyWith(
        status: NotificationStatus.success,
        items: page.items,
        pageNumber: page.pageNumber,
        totalPages: page.totalPages,
        totalItems: page.totalItems,
        isLoadingMore: false,
        clearError: true,
      ));
    } catch (err) {
      if (err is DioException && CancelToken.isCancel(err)) return;
      emit(state.copyWith(
        status: NotificationStatus.failure,
        error: err is NotificationApiException ? err.message : backendMessage(err),
      ));
    }
  }

  Future<void> _onLoadMore(NotificationLoadMore e, Emitter<NotificationState> emit) async {
    if (state.status != NotificationStatus.success || !state.hasMore) return;
    emit(state.copyWith(isLoadingMore: true));
    try {
      final next = await remote.fetchPage(
        query: state.query,
        filter: state.filter,
        pageNumber: state.pageNumber + 1,
        pageSize: _pageSize,
      );
      // جلوگیری از تکرار اگر در حین اسکرول داده تغییر کرده باشد
      final have = state.items.map((i) => i.key).toSet();
      emit(state.copyWith(
        items: [...state.items, ...next.items.where((i) => !have.contains(i.key))],
        pageNumber: next.pageNumber,
        totalPages: next.totalPages,
        totalItems: next.totalItems,
        isLoadingMore: false,
      ));
    } catch (err) {
      emit(state.copyWith(
        isLoadingMore: false,
        error: err is NotificationApiException ? err.message : backendMessage(err),
      ));
    }
  }

  Future<void> _onRead(NotificationRead e, Emitter<NotificationState> emit) async {
    if (state.readKeys.contains(e.key)) return;
    final keys = {...state.readKeys, e.key};
    emit(state.copyWith(readKeys: keys));
    await store.save(keys);
  }

  Future<void> _onAllRead(NotificationAllRead e, Emitter<NotificationState> emit) async {
    // همه‌ی کلیدهای فعال (از شمارنده) + آنچه الان در لیست است
    final keys = {
      ...state.readKeys,
      ...state.summary.keys,
      ...state.items.map((i) => i.key),
    };
    emit(state.copyWith(readKeys: keys));
    await store.save(keys);
  }

  @override
  Future<void> close() {
    _cancel?.cancel();
    return super.close();
  }
}