import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:money/core/vault/vault_repository.dart';
import 'package:money/feature/auth/presentation/bloc/vault/vault_bloc.dart';
import 'package:money/feature/auth/presentation/bloc/vault/vault_event.dart';
import 'package:money/feature/auth/presentation/bloc/vault/vault_state.dart';
import 'package:money/feature/model/DebtReceviable/cover_image.dart';
import 'package:money/feature/model/vault/vault_models.dart';
import 'package:money/widgets/DebtReceviable/cover_image_view.dart';
import 'package:money/widgets/DebtReceviable/cover_viewer.dart';
import 'package:money/widgets/contact/contact_style.dart';
import 'package:money/widgets/vault/vault_fields.dart';
import 'package:money/widgets/vault/vault_form_sheet.dart';

Future<void> showVaultDetailSheet(BuildContext context, String id) {
  final bloc = context.read<VaultBloc>();
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    constraints: const BoxConstraints(maxWidth: 640),
    builder: (_) => BlocProvider.value(
      value: bloc,
      child: _Detail(id: id),
    ),
  );
}

/// کپی؛ حافظه‌ی کلیپ‌بورد بعد از ۳۰ ثانیه خالی می‌شود
Future<void> _copy(BuildContext context, String text, String label) async {
  await Clipboard.setData(ClipboardData(text: text));
  Timer(
    const Duration(seconds: 30),
    () => Clipboard.setData(const ClipboardData(text: '')),
  );
  if (!context.mounted) return;
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        content: Text(
          '$label کپی شد (۳۰ ثانیه‌ی دیگر پاک می‌شود)',
          style: sans(size: 12, color: Colors.white),
        ),
      ),
    );
}

class _Detail extends StatefulWidget {
  final String id;
  const _Detail({required this.id});
  @override
  State<_Detail> createState() => _DetailState();
}

class _DetailState extends State<_Detail> {
  final _repo = GetIt.I<VaultRepository>();
  final Set<String> _revealed = {};
  final Map<String, Future<Uint8List>> _thumbs = {};

  Future<void> _delete() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'حذف از گاوصندوق',
          style: sans(size: 15, weight: FontWeight.bold),
        ),
        content: Text(
          'این آیتم و پیوست‌هایش برای همیشه حذف شود؟',
          style: sans(size: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('انصراف', style: sans()),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('حذف', style: sans(color: Colors.red.shade400)),
          ),
        ],
      ),
    );
    if (ok == true && mounted) {
      context.read<VaultBloc>().add(VaultItemDeleted(widget.id));
      Navigator.of(context).pop();
    }
  }

  Future<void> _openViewer(VaultEntry e, int index) async {
    final atts = e.record.attachments.where((a) => a.state != 2).toList();
    try {
      final images = <CoverImage>[];
      for (final a in atts) {
        final info = await _repo.attachmentInfo(a);
        final bytes = await _thumb(a);
        images.add(CoverImage(id: a.id, name: info.name, bytes: bytes));
      }
      if (!mounted) return;
      final ctrl = CoverController(images);
      await showCoverViewer(
        context,
        controller: ctrl,
        initialIndex: index,
        editable: false,
      );
      ctrl.dispose();
    } catch (err) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$err', style: sans(size: 12, color: Colors.white)),
          ),
        );
      }
    }
  }

  Future<Uint8List> _thumb(VaultAttachment a) =>
      _thumbs.putIfAbsent(a.id, () => _repo.readAttachment(a));

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<VaultBloc, VaultState>(
      builder: (context, _) {
        final e = _repo.entryById(widget.id);
        if (e == null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted && Navigator.of(context).canPop())
              Navigator.of(context).pop();
          });
          return const SizedBox.shrink();
        }
        final cat = e.category;
        final p = e.plain;
        final atts = e.record.attachments.where((a) => a.state != 2).toList();

        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.92,
          ),
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
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: cat.color.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(cat.icon, size: 18, color: cat.color),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        e.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: sans(size: 16, weight: FontWeight.bold),
                      ),
                    ),
                    if (p != null)
                      IconButton(
                        tooltip: 'ویرایش',
                        onPressed: () => showVaultFormSheet(context, entry: e),
                        icon: const Icon(Icons.edit_outlined, color: kAccent),
                      ),
                    IconButton(
                      tooltip: 'حذف',
                      onPressed: _delete,
                      icon: Icon(
                        Icons.delete_outline_rounded,
                        color: Colors.red.shade400,
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: p == null
                      ? Text(
                          'این آیتم رمزگشایی نشد؛ ممکن است داده خراب یا دستکاری شده باشد.',
                          style: sans(size: 13, color: Colors.red.shade400),
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            for (final f in kVaultFields[cat]!)
                              if ((p.fields[f.key] ?? '').isNotEmpty)
                                _fieldRow(f, p.fields[f.key]!),
                            if (p.note.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              Text(
                                'توضیحات',
                                style: sans(
                                  size: 12,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade50,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Colors.grey.shade200,
                                  ),
                                ),
                                child: SelectableText(
                                  p.note,
                                  style: sans(size: 13),
                                ),
                              ),
                            ],
                            if (atts.isNotEmpty) ...[
                              const SizedBox(height: 16),
                              Text(
                                'تصاویر و مدارک (${atts.length})',
                                style: sans(
                                  size: 12,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: [
                                  for (var i = 0; i < atts.length; i++)
                                    _thumbBox(e, atts[i], i),
                                ],
                              ),
                            ],
                            if (e.record.pending ||
                                e.record.pendingAttachments > 0)
                              Padding(
                                padding: const EdgeInsets.only(top: 16),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.cloud_upload_outlined,
                                      size: 16,
                                      color: Colors.orange.shade700,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      'در انتظار همگام‌سازی با سرور',
                                      style: sans(
                                        size: 11,
                                        color: Colors.orange.shade800,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _fieldRow(VaultField f, String raw) {
    final shown = f.options?[raw] ?? raw;
    final hidden = f.secret && !_revealed.contains(f.key);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(f.icon, size: 18, color: Colors.grey.shade500),
          const SizedBox(width: 10),
          SizedBox(
            width: 100,
            child: Text(
              f.label,
              style: sans(size: 12, color: Colors.grey.shade600),
            ),
          ),
          Expanded(
            child: Text(
              hidden ? '••••••••' : shown,
              textDirection: f.numeric ? TextDirection.ltr : null,
              textAlign: TextAlign.start,
              style: sans(size: 13.5, weight: FontWeight.w600),
            ),
          ),
          if (f.secret)
            IconButton(
              visualDensity: VisualDensity.compact,
              tooltip: hidden ? 'نمایش' : 'پنهان کردن',
              onPressed: () => setState(() {
                hidden ? _revealed.add(f.key) : _revealed.remove(f.key);
              }),
              icon: Icon(
                hidden
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                size: 18,
              ),
            ),
          IconButton(
            visualDensity: VisualDensity.compact,
            tooltip: 'کپی',
            onPressed: () => _copy(context, raw, f.label),
            icon: const Icon(Icons.copy_rounded, size: 17, color: kAccent),
          ),
        ],
      ),
    );
  }

  Widget _thumbBox(VaultEntry e, VaultAttachment a, int i) => GestureDetector(
    onTap: () => _openViewer(e, i),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: SizedBox(
        width: 84,
        height: 84,
        child: FutureBuilder<Uint8List>(
          future: _thumb(a),
          builder: (_, s) {
            if (s.hasError) {
              return Container(
                color: Colors.grey.shade200,
                child: Icon(
                  Icons.broken_image_outlined,
                  color: Colors.grey.shade500,
                ),
              );
            }
            if (!s.hasData) {
              return const Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              );
            }
            return CoverImageView(
              image: CoverImage(id: a.id, name: '', bytes: s.data),
              fit: BoxFit.cover,
            );
          },
        ),
      ),
    ),
  );
}
