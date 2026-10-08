import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:money/core/network/backend_message.dart';
import 'package:money/feature/data/dataResource/search_remote_data_source.dart';
import 'package:money/feature/model/search_models/search_filter.dart';
import 'package:money/feature/model/search_models/search_models.dart';
import 'package:money/widgets/contact/contact_style.dart';
import 'package:money/widgets/global/app_search_field.dart';

const _border = Color.fromARGB(255, 211, 205, 205);

class ContactPickerField extends StatelessWidget {
  final SearchContact? value;
  final ValueChanged<SearchContact> onSelected;
  final String? errorText;
  final String hintText;

  const ContactPickerField({
    super.key,
    required this.value,
    required this.onSelected,
    this.errorText,
    this.hintText = 'انتخاب از مخاطبین',
  });

  Future<void> _open(BuildContext context) async {
    FocusScope.of(context).unfocus();
    final picked = await showModalBottomSheet<SearchContact>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      constraints: const BoxConstraints(maxWidth: 560),
      builder: (_) => const _ContactPickerSheet(),
    );
    if (picked != null) onSelected(picked);
  }

  @override
  Widget build(BuildContext context) {
    final has = value != null;
    return InkWell(
      onTap: () => _open(context),
      borderRadius: BorderRadius.circular(16),
      child: InputDecorator(
        decoration: InputDecoration(
          errorText: errorText,
          errorStyle: sans(size: 11),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: _border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: _border),
          ),
          prefixIcon: const Icon(Icons.person, size: 20),
          suffixIcon: const Icon(Icons.arrow_drop_down),
        ),
        child: Text(
          has ? value!.name : hintText,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: has ? sans(size: 14) : sans(size: 12, color: _border),
        ),
      ),
    );
  }
}

class _ContactPickerSheet extends StatefulWidget {
  const _ContactPickerSheet();

  @override
  State<_ContactPickerSheet> createState() => _ContactPickerSheetState();
}

class _ContactPickerSheetState extends State<_ContactPickerSheet> {
  final _ds = GetIt.I<SearchRemoteDataSource>();
  final _scroll = ScrollController();
  Timer? _debounce;

  String _query = '';
  List<SearchContact> _items = [];
  int _page = 1;
  int _totalPages = 0;
  bool _loading = true;
  bool _loadingMore = false;
  String? _error;
  int _req = 0; // برای نادیده گرفتن پاسخ‌های قدیمی

  @override
  void initState() {
    super.initState();
    _scroll.addListener(() {
      if (_scroll.hasClients &&
          _scroll.position.pixels >= _scroll.position.maxScrollExtent - 100) {
        _load(reset: false);
      }
    });
    _load(reset: true);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _scroll.dispose();
    super.dispose();
  }

  void _onChanged(String v) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      _query = v.trim();
      _load(reset: true);
    });
  }

  Future<void> _load({required bool reset}) async {
    if (!reset && (_loadingMore || _loading || _page >= _totalPages)) return;
    final req = ++_req;
    setState(() {
      if (reset) {
        _loading = true;
        _error = null;
      } else {
        _loadingMore = true;
      }
    });

    try {
      final res = await _ds.search(
        query: _query,
        filter: const SearchFilter(type: SearchType.contacts),
        pageNumber: reset ? 1 : _page + 1,
        pageSize: 20,
      );
      if (!mounted || req != _req) return;
      setState(() {
        _items = reset
            ? res.contacts.items
            : [..._items, ...res.contacts.items];
        _page = res.contacts.pageNumber;
        _totalPages = res.contacts.totalPages;
        _loading = false;
        _loadingMore = false;
      });
    } catch (e) {
      if (!mounted || req != _req) return;
      setState(() {
        _loading = false;
        _loadingMore = false;
        _error = backendMessage(e);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    return Container(
      height: media.size.height * 0.8,
      padding: EdgeInsets.only(bottom: media.viewInsets.bottom),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 10),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'انتخاب طرف حساب',
            style: sans(size: 16, weight: FontWeight.bold),
          ),
          const SizedBox(height: 14),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: AppSearchField(
              hintText: 'جستجوی نام یا شماره',
              isLoading: _loading,
              onChanged: _onChanged,
            ),
          ),
          const SizedBox(height: 8),
          Expanded(child: _body()),
        ],
      ),
    );
  }

  Widget _body() {
    if (_loading && _items.isEmpty) {
      return const Center(child: CircularProgressIndicator(color: kAccent));
    }
    if (_error != null && _items.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_error!, style: sans(size: 12, color: Colors.red.shade400)),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: () => _load(reset: true),
              child: Text('تلاش دوباره', style: sans(size: 12)),
            ),
          ],
        ),
      );
    }
    if (_items.isEmpty) {
      return Center(
        child: Text(
          _query.isEmpty ? 'هنوز مخاطبی ثبت نکرده‌ای' : 'مخاطبی پیدا نشد',
          style: sans(size: 12, color: Colors.grey.shade600),
        ),
      );
    }

    return ListView.builder(
      controller: _scroll,
      itemCount: _items.length + (_loadingMore ? 1 : 0),
      itemBuilder: (context, i) {
        if (i >= _items.length) {
          return const Padding(
            padding: EdgeInsets.all(12),
            child: Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: kAccent,
                ),
              ),
            ),
          );
        }
        final c = _items[i];
        return ListTile(
          onTap: () => Navigator.of(context).pop(c),
          leading: CircleAvatar(
            backgroundColor: kAccent.withValues(alpha: 0.12),
            child: Text(
              c.name.isEmpty ? '?' : c.name.characters.first,
              style: sans(size: 14, weight: FontWeight.bold, color: kAccent),
            ),
          ),
          title: Text(c.name, style: sans(size: 13)),
          subtitle: Text(
            c.phoneNumber,
            style: sans(size: 11, color: Colors.grey.shade600),
          ),
        );
      },
    );
  }
}
