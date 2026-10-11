import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:money/core/network/backend_message.dart';
import 'package:money/feature/data/dataResource/auth_remote_data_source.dart';
import 'package:money/widgets/contact/contact_style.dart';

const _red = Color(0xFFEF4444);

/// خروجی true یعنی حساب در سرور حذف شد (فراخوان باید نشست را پاک کند و به ورود برود)
Future<bool> showDeleteAccountDialog(BuildContext context) async {
  final ok = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (_) => const _DeleteAccountDialog(),
  );
  return ok == true;
}

class _DeleteAccountDialog extends StatefulWidget {
  const _DeleteAccountDialog();

  @override
  State<_DeleteAccountDialog> createState() => _DeleteAccountDialogState();
}

class _DeleteAccountDialogState extends State<_DeleteAccountDialog> {
  final _pass = TextEditingController();
  bool _understood = false;
  bool _busy = false;
  bool _obscure = true;
  String? _error;

  @override
  void dispose() {
    _pass.dispose();
    super.dispose();
  }

  Future<void> _delete() async {
    if (_pass.text.isEmpty) {
      setState(() => _error = 'رمز عبور را وارد کن');
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });

    try {
      final res = await GetIt.I<AuthRemoteDataSource>().deleteAccount(
        currentPassword: _pass.text,
      );

      if (res is Map<String, dynamic> && res['success'] == false) {
        final msgs = extractApiMessages(res['message']);
        throw Exception(msgs.isEmpty ? 'حذف حساب ناموفق بود' : msgs.join('\n'));
      }
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _error = backendMessage(e);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: PopScope(
        canPop: !_busy,
        child: AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              const Icon(Icons.warning_amber_rounded, color: _red),
              const SizedBox(width: 8),
              Text(
                'حذف دائمی حساب',
                style: sans(size: 15, weight: FontWeight.bold, color: _red),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'با حذف حساب، همه‌ی این موارد برای همیشه پاک می‌شود:',
                  style: sans(size: 12.5).copyWith(height: 1.7),
                ),
                const SizedBox(height: 8),
                for (final t in const [
                  'مخاطبین، طلب‌ها و بدهی‌ها',
                  'تصاویر پیوست‌شده',
                  'حقوق، بودجه، هزینه‌ها و تاریخچه',
                  'اطلاعات ورود شما',
                ])
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.remove_circle_outline,
                          size: 15,
                          color: _red,
                        ),
                        const SizedBox(width: 6),
                        Expanded(child: Text(t, style: sans(size: 12))),
                      ],
                    ),
                  ),
                const SizedBox(height: 8),
                Text(
                  'این کار قابل بازگشت نیست.',
                  style: sans(size: 12, weight: FontWeight.bold, color: _red),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _pass,
                  obscureText: _obscure,
                  enabled: !_busy,
                  style: sans(size: 14),
                  decoration: InputDecoration(
                    labelText: 'رمز عبور فعلی',
                    labelStyle: sans(size: 13),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscure ? Icons.visibility_off : Icons.visibility,
                        size: 20,
                      ),
                      onPressed: () => setState(() => _obscure = !_obscure),
                    ),
                  ),
                ),
                CheckboxListTile(
                  value: _understood,
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  controlAffinity: ListTileControlAffinity.leading,
                  activeColor: _red,
                  onChanged: _busy
                      ? null
                      : (v) => setState(() => _understood = v == true),
                  title: Text(
                    'متوجه‌ام که اطلاعات قابل بازیابی نیست',
                    style: sans(size: 12),
                  ),
                ),
                if (_error != null)
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      _error!,
                      style: sans(size: 12, color: Colors.red.shade600),
                    ),
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: _busy ? null : () => Navigator.of(context).pop(false),
              child: Text('انصراف', style: sans(size: 13)),
            ),
            TextButton(
              onPressed: (_understood && !_busy) ? _delete : null,
              child: _busy
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: _red,
                      ),
                    )
                  : Text('حذف حساب', style: sans(size: 13, color: _red)),
            ),
          ],
        ),
      ),
    );
  }
}
