import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:money/core/network/backend_message.dart';
import 'package:money/feature/auth/presentation/bloc/search/search_event.dart';
import 'package:money/feature/auth/presentation/bloc/search/search_state.dart';
import 'package:money/feature/data/dataResource/search_remote_data_source.dart';
import 'package:money/feature/model/search_models/search_filter.dart';


class SearchBloc extends Bloc<SearchEvent, SearchState> {
  final SearchRemoteDataSource remoteDataSource;

  static const Duration _debounce = Duration(milliseconds: 400);
  static const int _pageSize = 10;

  CancelToken? _cancelToken;

  SearchBloc({required this.remoteDataSource}) : super(const SearchState()) {
    // restartable: با هر ورودی جدید، پردازش قبلی کنسل می‌شود
    on<SearchQueryChanged>(_onQueryChanged, transformer: restartable());
    on<SearchFilterChanged>(_onFilterChanged, transformer: restartable());
    // droppable: تا پایان لود یک صفحه، درخواست‌های تکراری نادیده گرفته می‌شود
    on<SearchLoadMore>(_onLoadMore, transformer: droppable());
    on<SearchCleared>(_onCleared);
  }

  Future<void> _onQueryChanged(
    SearchQueryChanged event,
    Emitter<SearchState> emit,
  ) async {
    final q = event.query.trim();

    if (q.isEmpty && !state.filter.isActive) {
      _cancelToken?.cancel();
      emit(SearchState(filter: state.filter)); // بازگشت به حالت اولیه
      return;
    }

    emit(state.copyWith(query: q, status: SearchStatus.loading, clearError: true));

    await Future<void>.delayed(_debounce); // debounce
    await _fetchFirstPage(emit);
  }

  Future<void> _onFilterChanged(
    SearchFilterChanged event,
    Emitter<SearchState> emit,
  ) async {
    emit(state.copyWith(filter: event.filter, clearError: true));

    if (state.query.isEmpty && !event.filter.isActive) {
      _cancelToken?.cancel();
      emit(SearchState(filter: event.filter));
      return;
    }

    emit(state.copyWith(status: SearchStatus.loading));
    await _fetchFirstPage(emit);
  }

  Future<void> _fetchFirstPage(Emitter<SearchState> emit) async {
    _cancelToken?.cancel();
    final token = _cancelToken = CancelToken();

    try {
      final res = await remoteDataSource.search(
        query: state.query,
        filter: state.filter,
        pageNumber: 1,
        pageSize: _pageSize,
        cancelToken: token,
      );

      emit(state.copyWith(
        status: SearchStatus.success,
        contacts: res.contacts,
        debts: res.debts,
        isLoadingMore: false,
      ));
    } catch (error) {
      if (error is DioException && CancelToken.isCancel(error)) return;
      emit(state.copyWith(
        status: SearchStatus.failure,
        error: backendMessage(error),
      ));
    }
  }

  Future<void> _onLoadMore(
    SearchLoadMore event,
    Emitter<SearchState> emit,
  ) async {
    if (state.status != SearchStatus.success || !state.hasMore) return;

    emit(state.copyWith(isLoadingMore: true));

    try {
      final type = state.filter.type;
      final loadContacts =
          (type == SearchType.all || type == SearchType.contacts) &&
              state.contacts.hasMore;
      final loadDebts =
          (type == SearchType.all || type == SearchType.debts) &&
              state.debts.hasMore;

      var contacts = state.contacts;
      var debts = state.debts;

      // هر لیست صفحه‌ی بعدی خودش را می‌گیرد (pagination مستقل)
      if (loadContacts) {
        final res = await remoteDataSource.search(
          query: state.query,
          filter: state.filter.copyWith(type: SearchType.contacts),
          pageNumber: state.contacts.pageNumber + 1,
          pageSize: _pageSize,
        );
        contacts = contacts.append(res.contacts);
      }
      if (loadDebts) {
        final res = await remoteDataSource.search(
          query: state.query,
          filter: state.filter.copyWith(type: SearchType.debts),
          pageNumber: state.debts.pageNumber + 1,
          pageSize: _pageSize,
        );
        debts = debts.append(res.debts);
      }

      emit(state.copyWith(
        contacts: contacts,
        debts: debts,
        isLoadingMore: false,
      ));
    } catch (error) {
      emit(state.copyWith(isLoadingMore: false, error: backendMessage(error)));
    }
  }

  void _onCleared(SearchCleared event, Emitter<SearchState> emit) {
    _cancelToken?.cancel();
    emit(const SearchState());
  }

  @override
  Future<void> close() {
    _cancelToken?.cancel();
    return super.close();
  }
}