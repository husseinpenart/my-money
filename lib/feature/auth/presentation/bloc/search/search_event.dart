import 'package:money/feature/model/search_models/search_filter.dart';

abstract class SearchEvent {
  const SearchEvent();
}

class SearchQueryChanged extends SearchEvent {
  final String query;
  const SearchQueryChanged(this.query);
}

class SearchFilterChanged extends SearchEvent {
  final SearchFilter filter;
  const SearchFilterChanged(this.filter);
}

class SearchLoadMore extends SearchEvent {
  const SearchLoadMore();
}

class SearchCleared extends SearchEvent {
  const SearchCleared();
}
