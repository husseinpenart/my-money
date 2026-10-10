import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:money/core/network/backend_message.dart';
import 'package:money/feature/data/dataResource/auth_remote_data_source.dart';

TextStyle _s({double size = 13, FontWeight? w, Color? c}) =>
    TextStyle(fontFamily: 'sans', fontSize: size, fontWeight: w, color: c);

/// کد را یک‌بار نشان می‌دهد؛ تا کاربر تأیید نکند که ذخیره کرده، بسته نمی‌شود
Future<void> showRecoveryCodeDialog(BuildContext context, String code) {
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    useRootNavigator: true,
    builder: (_) => PopScope(
      canPop: false, // دکمه‌ی back هم بسته نمی‌کند
      child: _RecoveryCodeDialog(code: code),
    ),
  );
}

class _RecoveryCodeDialog extends StatefulWidget {
  final String code;
  const _RecoveryCodeDialog({required this.code});

  @override
  State<_RecoveryCodeDialog> createState() => _RecoveryCodeDialogState();
}

class _RecoveryCodeDialogState extends State<_RecoveryCodeDialog> {
  bool _saved = false;
  bool _copied = false;

  Future<void> _copy() async {
    await Clipboard.setData(ClipboardData(text: widget.code));
    if (mounted) setState(() => _copied = true);
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('کد بازیابی شما', style: _s(size: 16, w: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F7FF),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFD8DEFF)),
              ),
              child: SelectableText(
                widget.code,
                textAlign: TextAlign.center,
                textDirection: TextDirection.ltr,
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Align(
              child: TextButton.icon(
                onPressed: _copy,
                icon: Icon(
                  _copied ? Icons.check : Icons.copy_rounded,
                  size: 18,
                ),
                label: Text(_copied ? 'کپی شد' : 'کپی کد', style: _s(size: 12)),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'این کد فقط همین یک‌بار نمایش داده می‌شود. اگر رمز عبورت را فراموش کنی، فقط با همین کد می‌توانی آن را بازیابی کنی. آن را جای امنی نگه دار.',
              style: _s(size: 12, c: Colors.grey.shade700),
            ),
            const SizedBox(height: 8),
            CheckboxListTile(
              value: _saved,
              dense: true,
              contentPadding: EdgeInsets.zero,
              controlAffinity: ListTileControlAffinity.leading,
              onChanged: (v) => setState(() => _saved = v == true),
              title: Text('کد را ذخیره کردم', style: _s(size: 12)),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: _saved
                ? () => Navigator.of(context, rootNavigator: true).pop()
                : null,
            child: Text('بستن', style: _s()),
          ),
        ],
      ),
    );
  }
}

/// برای صفحه‌ی تنظیمات/پروفایل: رمز فعلی را می‌گیرد و کد جدید می‌سازد.
/// (کد قبلی، اگر بوده، باطل می‌شود)
Future<void> showGenerateRecoveryCodeFlow(BuildContext context) async {
  final ctrl = TextEditingController();

  final password = await showDialog<String>(
    context: context,
    builder: (ctx) => Directionality(
      textDirection: TextDirection.rtl,
      child: AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('ساخت کد بازیابی', style: _s(size: 15, w: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'برای تأیید، رمز عبور فعلی را وارد کن. کد بازیابی قبلی (اگر داری) باطل می‌شود.',
              style: _s(size: 12, c: Colors.grey.shade700),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: ctrl,
              obscureText: true,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: 'رمز عبور فعلی',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('انصراف', style: _s()),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, ctrl.text),
            child: Text('ساخت کد', style: _s()),
          ),
        ],
      ),
    ),
  );
  ctrl.dispose();

  if (password == null || password.isEmpty || !context.mounted) return;

  try {
    final res = await GetIt.I<AuthRemoteDataSource>().generateRecoveryCode(
      currentPassword: password,
    );

    String? code;
    String? error;
    if (res is Map<String, dynamic>) {
      final failed = res['success'] == false;
      if (failed) {
        error = extractApiMessages(res['message']).join('\n');
      } else {
        final d = res['data'];
        if (d is Map<String, dynamic>) code = d['recoveryCode']?.toString();
      }
    }

    if (!context.mounted) return;
    if (code != null && code.isNotEmpty) {
      await showRecoveryCodeDialog(context, code);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red.shade600,
          content: Text(
            (error == null || error.isEmpty) ? 'ساخت کد ناموفق بود' : error,
            style: _s(c: Colors.white),
          ),
        ),
      );
    }
  } catch (e) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.red.shade600,
        content: Text(backendMessage(e), style: _s(c: Colors.white)),
      ),
    );
  }
}
