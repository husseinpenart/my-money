// lib/widgets/header.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:money/core/storage/token_storage.dart';
import 'package:money/dictionary/titles.dart';
import 'package:money/feature/auth/presentation/bloc/search/search_bloc.dart';
import 'package:money/feature/auth/presentation/bloc/search/search_event.dart';
import 'package:money/feature/auth/presentation/bloc/search/search_state.dart';

import 'package:money/widgets/global/CustomIconButton.dart';
import 'package:money/widgets/global/app_search_field.dart';
import 'package:money/widgets/global/notification_bell.dart';
import 'package:money/widgets/search/search_results_panel.dart';

class Header extends StatefulWidget {
  const Header({super.key});

  @override
  State<Header> createState() => _HeaderState();
}

class _HeaderState extends State<Header> {
  bool _isSearchVisible = false;
  final TextEditingController _searchController = TextEditingController();
  late final SearchBloc _searchBloc;
  String _userName = 'کاربر عزیز';

  @override
  void initState() {
    super.initState();
    _searchBloc = GetIt.I<SearchBloc>();

    final storedName = GetIt.I<TokenStorage>().getName();
    if (storedName != null && storedName.isNotEmpty) {
      _userName = storedName;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchBloc.close();
    super.dispose();
  }

  void _toggleSearch() {
    setState(() {
      _isSearchVisible = !_isSearchVisible;
      if (!_isSearchVisible) {
        _searchController.clear();
        _searchBloc.add(const SearchCleared());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _searchBloc,
      child: Container(
        padding: const EdgeInsets.all(16),
        width: double.maxFinite,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      Titles.hello,
                      style: const TextStyle(fontSize: 12, fontFamily: 'sans'),
                    ),
                    Text(
                      '$_userName 👋',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: Colors.black,
                        fontFamily: 'sans',
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    CustomIconButton(
                      onPressed: _toggleSearch,
                      icon: _isSearchVisible ? Icons.close : Icons.search,
                    ),
                    const SizedBox(width: 12),
                    const NotificationBell(),
                  ],
                ),
              ],
            ),

            AnimatedSize(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              alignment: Alignment.topCenter,
              child: _isSearchVisible
                  ? Padding(
                      padding: const EdgeInsets.only(top: 20),
                      child: Column(
                        children: [
                          BlocBuilder<SearchBloc, SearchState>(
                            buildWhen: (p, c) => p.status != c.status,
                            builder: (context, state) => AppSearchField(
                              controller: _searchController,
                              hintText: Titles.searchText,
                              isLoading: state.status == SearchStatus.loading,
                              onChanged: (v) => context.read<SearchBloc>().add(
                                SearchQueryChanged(v),
                              ),
                            ),
                          ),
                          SearchResultsPanel(
                            onContactTap: (contact) {
                              // TODO: ناوبری به صفحه‌ی مخاطب
                              Navigator.pushNamed(
                                context,
                                '/contact',
                                arguments: contact.contactId,
                              );
                            },
                            onDebtTap: (debt) {
                              // TODO: ناوبری به جزئیات بدهی/طلب
                            },
                          ),
                        ],
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}
