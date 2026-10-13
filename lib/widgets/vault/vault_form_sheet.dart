import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:money/core/vault/vault_repository.dart';
import 'package:money/feature/auth/presentation/bloc/vault/vault_bloc.dart';
import 'package:money/feature/auth/presentation/bloc/vault/vault_event.dart';
import 'package:money/feature/auth/presentation/bloc/vault/vault_state.dart';
import 'package:money/feature/model/vault/vault_models.dart';
import 'package:money/widgets/contact/contact_style.dart';
import 'package:money/widgets/vault/vault_fields.dart';

Future<void> showVaultFormSheet(BuildContext context, {VaultEntry? entry}) {
  final bloc = context.read<VaultBloc>();
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    constraints: const BoxConstraints(maxWidth: 640),
    builder: (_) => BlocProvider.value(
      value: bloc,
      child: _FormSheet(entry: entry),
    ),
  );
}

InputDecoration _dec(String label, IconData icon) => InputDecoration(
  labelText: label,
  labelStyle: sans(size: 13, color: Colors.grey.shade600),
  prefixIcon: Icon(icon, color: kAccent, size: 20),
  filled: true,
  fillColor: Colors.grey.shade50,
  enabledBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(12),
    borderSide: BorderSide(color: Colors.grey.shade200),
  ),
  focusedBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(12),
    borderSide: const BorderSide(color: kAccent, width: 1.5),
  ),
  errorStyle: sans(size: 11),
);

class _FormSheet extends StatefulWidget {
  final VaultEntry? entry;
  const _FormSheet({this.entry});
  @override
  State<_FormSheet> createState() => _FormSheetState();
}

class _FormSheetState extends State<_FormSheet> {
  final _key = GlobalKey<FormState>();
  late VaultCategory _cat = widget.entry?.category ?? VaultCategory.asset;
  late final _title = TextEditingController(
    text: widget.entry?.plain?.title ?? '',
  );
  late final _note = TextEditingController(
    text: widget.entry?.plain?.note ?? '',
  );
  final Map<String, TextEditingController> _c = {};
  final Map<String, String> _sel = {};
  final List<VaultNewFile> _files = [];
  final Set<String> _removed = {};
  String? _error;
  bool _wasBusy = false;

  bool get _isEdit => widget.entry != null;

  @override
  void initState() {
    super.initState();
    final f = widget.entry?.plain?.fields ?? const <String, String>{};
    for (final list in kVaultFields.values) {
      for (final fld in list) {
        if (fld.options != null) {
          _sel['${_cat.id}:${fld.key}'] = f[fld.key] ?? fld.options!.keys.first;
        } else {
          _c['${_catOf(list)}:${fld.key}'] = TextEditingController(
            text: f[fld.key] ?? '',
          );
        }
      }
    }
    // کنترلرها و انتخاب‌ها به‌ازای هر دسته جدا نگه داشته می‌شوند
    for (final cat in VaultCategory.values) {
      for (final fld in kVaultFields[cat]!) {
        if (fld.options != null) {
          _sel['${cat.id}:${fld.key}'] =
              (cat == _cat ? f[fld.key] : null) ?? fld.options!.keys.first;
        } else {
          _c['${cat.id}:${fld.key}'] = TextEditingController(
            text: cat == _cat ? (f[fld.key] ?? '') : '',
          );
        }
      }
    }
  }

  int _catOf(List<VaultField> list) =>
      kVaultFields.entries.firstWhere((e) => identical(e.value, list)).key.id;

  @override
  void dispose() {
    _title.dispose();
    _note.dispose();
    for (final c in _c.values) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _pick() async {
    final room =
        VaultRepository.kMaxAttachments -
        ((widget.entry?.visibleAttachments ?? 0) - _removed.length) -
        _files.length;
    if (room <= 0) {
      setState(
        () =>
            _error = 'به سقف ${VaultRepository.kMaxAttachments} پیوست رسیده‌ای',
      );
      return;
    }
    final res = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['jpg', 'jpeg', 'png', 'webp'],
      allowMultiple: true,
      withData: true,
    );
    if (res == null) return;
    var skipped = 0;
    for (final f in res.files) {
      final b = f.bytes;
      if (b == null || b.length > 20 * 1024 * 1024 || _files.length >= room) {
        skipped++;
        continue;
      }
      _files.add(VaultNewFile(f.name, b));
    }
    setState(
      () => _error = skipped > 0
          ? '$skipped فایل اضافه نشد (حجم یا سقف تعداد)'
          : null,
    );
  }

  void _submit() {
    if (!_key.currentState!.validate()) return;
    final fields = <String, String>{};
    for (final fld in kVaultFields[_cat]!) {
      final k = '${_cat.id}:${fld.key}';
      final v = fld.options != null
          ? (_sel[k] ?? '')
          : (_c[k]?.text.trim() ?? '');
      if (v.isNotEmpty) fields[fld.key] = v;
    }
    setState(() => _error = null);
    context.read<VaultBloc>().add(
      VaultItemSaved(
        id: widget.entry?.id,
        category: _cat,
        plain: VaultPlain(
          title: _title.text.trim(),
          note: _note.text.trim(),
          fields: fields,
        ),
        newFiles: List.of(_files),
        removedAttachmentIds: _removed.toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    return BlocListener<VaultBloc, VaultState>(
      listenWhen: (p, c) => p.isBusy && !c.isBusy,
      listener: (context, s) {
        if (s.feedback?.isError == true &&
            s.feedback!.message.startsWith('ذخیره شد') == false) {
          setState(() => _error = s.feedback!.message);
        } else {
          Navigator.of(context).pop();
        }
      },
      child: Container(
        constraints: BoxConstraints(maxHeight: media.size.height * 0.94),
        padding: EdgeInsets.only(bottom: media.viewInsets.bottom),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
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
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 6, 8, 0),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                  Expanded(
                    child: Text(
                      _isEdit ? 'ویرایش آیتم' : 'آیتم جدید',
                      textAlign: TextAlign.center,
                      style: sans(size: 16, weight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),
            const Divider(height: 1),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _key,
                  child: Column(
                    children: [
                      if (!_isEdit)
                        SegmentedButton<VaultCategory>(
                          segments: [
                            for (final c in VaultCategory.values)
                              ButtonSegment(
                                value: c,
                                icon: Icon(c.icon, size: 16),
                                label: Text(c.label, style: sans(size: 12)),
                              ),
                          ],
                          selected: {_cat},
                          onSelectionChanged: (s) =>
                              setState(() => _cat = s.first),
                        ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _title,
                        style: sans(size: 14),
                        decoration: _dec('عنوان', Icons.label_outline),
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? 'عنوان را وارد کن'
                            : null,
                      ),
                      for (final fld in kVaultFields[_cat]!) ...[
                        const SizedBox(height: 12),
                        if (fld.options != null)
                          DropdownButtonFormField<String>(
                            value: _sel['${_cat.id}:${fld.key}'],
                            decoration: _dec(fld.label, fld.icon),
                            items: [
                              for (final o in fld.options!.entries)
                                DropdownMenuItem(
                                  value: o.key,
                                  child: Text(o.value, style: sans(size: 13)),
                                ),
                            ],
                            onChanged: (v) => setState(
                              () => _sel['${_cat.id}:${fld.key}'] = v ?? '',
                            ),
                          )
                        else
                          TextFormField(
                            controller: _c['${_cat.id}:${fld.key}'],
                            style: sans(size: 14),
                            minLines: fld.multiline ? 3 : 1,
                            maxLines: fld.multiline ? 8 : 1,
                            keyboardType: fld.numeric
                                ? TextInputType.number
                                : (fld.multiline
                                      ? TextInputType.multiline
                                      : null),
                            decoration: _dec(fld.label, fld.icon),
                          ),
                      ],
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _note,
                        minLines: 2,
                        maxLines: 5,
                        style: sans(size: 14),
                        decoration: _dec('توضیحات', Icons.notes_outlined),
                      ),
                      const SizedBox(height: 16),
                      _attachments(),
                    ],
                  ),
                ),
              ),
            ),
            if (_error != null)
              Container(
                width: double.infinity,
                margin: const EdgeInsets.fromLTRB(16, 4, 16, 4),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  _error!,
                  style: sans(size: 12, color: Colors.red.shade400),
                ),
              ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
              child: BlocBuilder<VaultBloc, VaultState>(
                buildWhen: (p, c) => p.isBusy != c.isBusy,
                builder: (context, s) => SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: s.isBusy ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kAccent,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: s.isBusy
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            _isEdit ? 'ذخیره تغییرات' : 'ثبت در گاوصندوق',
                            style: sans(size: 14, weight: FontWeight.bold),
                          ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _attachments() {
    final repo = GetIt.I<VaultRepository>();
    final existing =
        (widget.entry?.record.attachments ?? const <VaultAttachment>[])
            .where((a) => a.state != 2 && !_removed.contains(a.id))
            .toList();

    Widget chip(Widget label, VoidCallback onRemove) => Chip(
      avatar: const Icon(Icons.image_outlined, size: 16),
      label: label,
      deleteIcon: const Icon(Icons.close, size: 16),
      onDeleted: onRemove,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'تصاویر و مدارک',
              style: sans(size: 12, color: Colors.grey[600]),
            ),
            const Spacer(),
            TextButton.icon(
              onPressed: _pick,
              icon: const Icon(Icons.add_photo_alternate_outlined, size: 18),
              label: Text('افزودن تصویر', style: sans(size: 12)),
            ),
          ],
        ),
        Text(
          'تصاویر قبل از رمزنگاری فشرده می‌شوند',
          style: sans(size: 10.5, color: Colors.grey.shade500),
        ),
        Wrap(
          spacing: 8,
          children: [
            for (final a in existing)
              FutureBuilder(
                future: repo.attachmentInfo(a),
                builder: (_, snap) => chip(
                  Text(snap.data?.name ?? '...', style: sans(size: 11)),
                  () => setState(() => _removed.add(a.id)),
                ),
              ),
            for (final f in _files)
              chip(
                Text(f.name, style: sans(size: 11)),
                () => setState(() => _files.remove(f)),
              ),
          ],
        ),
      ],
    );
  }
}
