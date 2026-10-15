import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:money/core/cache/contact_cache.dart';
import 'package:money/core/cache/sync_repository.dart';
import 'package:money/core/network/backend_message.dart';
import 'package:money/feature/data/dataResource/contact_remote_data_source.dart';
import 'package:money/feature/model/contact/contact_model.dart';
import 'package:money/feature/model/search_models/search_models.dart';
import 'package:money/helper/utils/input_utils.dart';
import 'package:money/widgets/contact/contact_style.dart';
import 'package:money/widgets/global/app_search_field.dart';
import 'package:money/widgets/report/report_format.dart';

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
    this.hintText = 'انتخاب یا افزودن طرف حساب',
  });

  Future<void> _open(BuildContext context) async {
    FocusScope.of(context).unfocus();
    final picked = await showModalBottomSheet<SearchContact>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      constraints: const BoxConstraints(maxWidth: 560),
      builder: (_) => const _PickerSheet(),
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

class _PickerSheet extends StatefulWidget {
  const _PickerSheet();
  @override
  State<_PickerSheet> createState() => _PickerSheetState();
}

class _PickerSheetState extends State<_PickerSheet> {
  static const _step = 30;

  final _cache = GetIt.I<ContactCache>();
  final _scroll = ScrollController();
  final _name = TextEditingController();
  final _phone = TextEditingController();

  String _query = '';
  int _limit = _step;
  bool _loading = false;
  bool _creating = false;
  bool _busy = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(() {
      if (_scroll.hasClients &&
          _scroll.position.pixels >= _scroll.position.maxScrollExtent - 100) {
        setState(() => _limit += _step);
      }
    });
    // فقط اگر هنوز هیچ داده‌ای روی دستگاه نیست
    if (!_cache.hasData) {
      _loading = true;
      GetIt.I<SyncRepository>().refresh().whenComplete(() {
        if (mounted) setState(() => _loading = false);
      }).ignore();
    }
  }

  @override
  void dispose() {
    _scroll.dispose();
    _name.dispose();
    _phone.dispose();
    super.dispose();
  }

  SearchContact _toSearch(ContactModel c) => SearchContact(
    contactId: c.contactId,
    name: c.name,
    phoneNumber: c.phoneNumber,
    createdAt: c.createdAt,
    debts: c.debts,
  );

  void _startCreate() {
    final q = _query.trim();
    final looksPhone =
        RegExp(r'^[\d+\s\-]+$').hasMatch(normalizeDigits(q)) && q.isNotEmpty;
    setState(() {
      _creating = true;
      _error = null;
      _name.text = looksPhone ? '' : q;
      _phone.text = looksPhone ? q : '';
    });
  }

  Future<void> _save() async {
    final name = _name.text.trim();
    final phone = normalizePhone(_phone.text);
    if (name.isEmpty) {
      setState(() => _error = 'نام را وارد کن');
      return;
    }
    if (phone.isNotEmpty && !isValidPhone(phone)) {
      setState(() => _error = 'شماره تماس معتبر نیست');
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final c = await GetIt.I<ContactRemoteDataSource>().create(
        name: name,
        phoneNumber: phone,
      );
      if (mounted) Navigator.of(context).pop(_toSearch(c));
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _error = e is ContactApiException ? e.message : backendMessage(e);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final all = _cache.query(query: _query, sort: ContactSort.name);
    final shown = all.take(_limit).toList();

    return Container(
      height: media.size.height * 0.85,
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
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: AppSearchField(
              autofocus: false,
              hintText: 'جستجوی نام یا شماره',
              isLoading: _loading,
              onChanged: (v) => setState(() {
                _query = v.trim();
                _limit = _step;
              }),
            ),
          ),
          const SizedBox(height: 8),
          _createTile(),
          if (_creating) _createForm(),
          const Divider(height: 1),
          Expanded(child: _list(shown, all.length)),
        ],
      ),
    );
  }

  Widget _createTile() {
    final q = _query.trim();
    final text = q.isEmpty
        ? 'افزودن طرف حساب جدید'
        : 'افزودن «$q» به‌عنوان طرف حساب جدید';
    return ListTile(
      dense: true,
      leading: CircleAvatar(
        radius: 18,
        backgroundColor: kAccent.withValues(alpha: 0.12),
        child: const Icon(
          Icons.person_add_alt_1_rounded,
          size: 18,
          color: kAccent,
        ),
      ),
      title: Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: sans(size: 13, weight: FontWeight.bold, color: kAccent),
      ),
      subtitle: Text(
        'شماره اختیاری است',
        style: sans(size: 11, color: Colors.grey.shade600),
      ),
      onTap: _creating ? null : _startCreate,
    );
  }

  Widget _createForm() {
    InputDecoration d(String l, IconData i) => InputDecoration(
      labelText: l,
      labelStyle: sans(size: 12.5),
      prefixIcon: Icon(i, size: 19, color: kAccent),
      isDense: true,
      filled: true,
      fillColor: Colors.grey.shade50,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    );

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: kAccent.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: kAccent.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          TextField(
            controller: _name,
            style: sans(size: 14),
            textInputAction: TextInputAction.next,
            decoration: d('نام طرف حساب', Icons.person_outline),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _phone,
            style: sans(size: 14),
            keyboardType: TextInputType.phone,
            onSubmitted: (_) => _save(),
            decoration: d('شماره تماس (اختیاری)', Icons.phone_outlined),
          ),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Align(
                alignment: AlignmentDirectional.centerStart,
                child: Text(
                  _error!,
                  style: sans(size: 11.5, color: Colors.red.shade400),
                ),
              ),
            ),
          const SizedBox(height: 10),
          Row(
            children: [
              TextButton(
                onPressed: _busy
                    ? null
                    : () => setState(() => _creating = false),
                child: Text('انصراف', style: sans(size: 12)),
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: _busy ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: kAccent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: _busy
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        'ثبت و انتخاب',
                        style: sans(size: 12.5, weight: FontWeight.bold),
                      ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _list(List<ContactModel> shown, int total) {
    if (_loading && shown.isEmpty) {
      return const Center(child: CircularProgressIndicator(color: kAccent));
    }
    if (shown.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            _query.isEmpty
                ? 'هنوز طرف حسابی نداری. از بالا یکی اضافه کن.'
                : 'طرف حسابی با این جستجو پیدا نشد. از بالا «افزودن» را بزن.',
            textAlign: TextAlign.center,
            style: sans(size: 12, color: Colors.grey.shade600),
          ),
        ),
      );
    }
    return ListView.builder(
      controller: _scroll,
      itemCount: shown.length + 1,
      itemBuilder: (context, i) {
        if (i == shown.length) {
          return Padding(
            padding: const EdgeInsets.all(12),
            child: Center(
              child: Text(
                '${fa('$total')} طرف حساب',
                style: sans(size: 11, color: Colors.grey.shade500),
              ),
            ),
          );
        }
        final c = shown[i];
        return ListTile(
          onTap: () => Navigator.of(context).pop(_toSearch(c)),
          leading: CircleAvatar(
            backgroundColor: kAccent.withValues(alpha: 0.12),
            child: Text(
              c.name.isEmpty ? '؟' : c.name.characters.first,
              style: sans(size: 14, weight: FontWeight.bold, color: kAccent),
            ),
          ),
          title: Text(c.name, style: sans(size: 13)),
          subtitle: c.hasPhone
              ? Text(
                  fa(c.phoneNumber),
                  style: sans(size: 11, color: Colors.grey.shade600),
                )
              : null,
        );
      },
    );
  }
}
