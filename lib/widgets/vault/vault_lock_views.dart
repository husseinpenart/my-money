import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:money/feature/auth/presentation/bloc/vault/vault_bloc.dart';
import 'package:money/feature/auth/presentation/bloc/vault/vault_event.dart';
import 'package:money/feature/auth/presentation/bloc/vault/vault_state.dart';
import 'package:money/widgets/contact/contact_style.dart';
import 'package:money/widgets/vault/vault_recovery_views.dart';

const _red = Color(0xFFEF4444);

/// اعتبارسنجی passphrase گاوصندوق: حداقل ۱۰ کاراکتر.
/// (یک عبارت از چند کلمه بسیار امن‌تر از رمز کوتاه است.)
String? vaultPassphraseError(String pass) {
  if (pass.length < 10) return 'رمز باید حداقل ۱۰ کاراکتر باشد';
  return null;
}

InputDecoration _lockDec(String label, IconData icon, {bool obscure = false}) =>
    InputDecoration(
      labelText: label,
      labelStyle: sans(size: 13, color: Colors.grey.shade600),
      prefixIcon: Icon(icon, color: kAccent, size: 20),
      filled: true,
      fillColor: Colors.grey.shade50,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
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

// ───────────── ساخت گاوصندوق ─────────────
class VaultSetupView extends StatefulWidget {
  const VaultSetupView({super.key});
  @override
  State<VaultSetupView> createState() => _VaultSetupViewState();
}

class _VaultSetupViewState extends State<VaultSetupView> {
  final _a = TextEditingController();
  final _b = TextEditingController();
  bool _obscure = true;
  String? _err;

  @override
  void dispose() {
    _a.dispose();
    _b.dispose();
    super.dispose();
  }

  void _go() {
    final pe = vaultPassphraseError(_a.text);
    if (pe != null) {
      setState(() => _err = pe);
    } else if (_a.text != _b.text) {
      setState(() => _err = 'دو بار وارد‌شده یکسان نیست');
    } else {
      setState(() => _err = null);
      context.read<VaultBloc>().add(VaultSetupSubmitted(_a.text));
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Icon(Icons.lock_person_outlined, size: 56, color: kAccent),

          const SizedBox(height: 14),
          Text(
            'گاوصندوق خود را بساز',
            textAlign: TextAlign.center,
            style: sans(size: 18, weight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          Text(
            'رمزی که اینجا می‌گذاری هیچ‌وقت به سرور نمی‌رود. ما فقط یک کلید '
            'رمز‌شده‌ی تصادفی نگه می‌داریم؛ پس حتی خودمان هم نمی‌توانیم '
            'اطلاعاتت را بخوانیم.',
            textAlign: TextAlign.center,
            style: sans(
              size: 12.5,
              color: Colors.grey.shade600,
            ).copyWith(height: 1.7),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _a,
            obscureText: _obscure,
            style: sans(size: 14),
            decoration: _lockDec('رمز گاوصندوق', Icons.lock_outline).copyWith(
              suffixIcon: IconButton(
                icon: Icon(
                  _obscure ? Icons.visibility_off : Icons.visibility,
                  size: 20,
                ),
                onPressed: () => setState(() => _obscure = !_obscure),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'حداقل ۱۰ کاراکتر؛ یک عبارت از چند کلمه بسیار امن‌تر از رمز کوتاه است.',
            style: sans(size: 11, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _b,
            obscureText: _obscure,
            style: sans(size: 14),
            decoration: _lockDec('تکرار رمز', Icons.lock_reset_outlined),
            onSubmitted: (_) => _go(),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.orange.shade200),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.orange.shade700,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'بعد از ساخت، یک «کلید بازیابی» نشانت می‌دهیم. اگر رمز را '
                    'فراموش کنی، با آن بدون از دست رفتن اطلاعات دوباره وارد '
                    'می‌شوی. اگر هم رمز و هم کلید بازیابی را گم کنی، هیچ‌کس '
                    '(حتی ما) نمی‌تواند اطلاعات را برگرداند.',
                    style: sans(
                      size: 12,
                      color: Colors.orange.shade900,
                    ).copyWith(height: 1.7),
                  ),
                ),
              ],
            ),
          ),
          _errBlock(),
          const SizedBox(height: 16),
          BlocBuilder<VaultBloc, VaultState>(
            buildWhen: (p, c) => p.isBusy != c.isBusy,
            builder: (context, s) => SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: s.isBusy ? null : _go,
                style: ElevatedButton.styleFrom(
                  backgroundColor: kAccent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: s.isBusy
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        'ساخت گاوصندوق',
                        style: sans(size: 15, weight: FontWeight.bold),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _errBlock() {
    return BlocBuilder<VaultBloc, VaultState>(
      buildWhen: (p, c) => !identical(p.feedback, c.feedback),
      builder: (context, s) {
        final msg =
            _err ?? (s.feedback?.isError == true ? s.feedback!.message : null);
        if (msg == null) return const SizedBox.shrink();
        return Padding(
          padding: const EdgeInsets.only(top: 12),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(msg, style: sans(size: 12, color: Colors.red.shade600)),
          ),
        );
      },
    );
  }
}

// ───────────── باز کردن گاوصندوق ─────────────
class VaultUnlockView extends StatefulWidget {
  const VaultUnlockView({super.key});
  @override
  State<VaultUnlockView> createState() => _VaultUnlockViewState();
}

class _VaultUnlockViewState extends State<VaultUnlockView> {
  final _pass = TextEditingController();
  bool _obscure = true;
  String? _err;

  @override
  void dispose() {
    _pass.dispose();
    super.dispose();
  }

  void _go() {
    if (_pass.text.isEmpty) {
      setState(() => _err = 'رمز را وارد کن');
      return;
    }
    setState(() => _err = null);
    context.read<VaultBloc>().add(VaultUnlockSubmitted(_pass.text));
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Icon(Icons.lock_person_outlined, size: 56, color: kAccent),
          const SizedBox(height: 14),
          Text(
            'گاوصندوق قفل است',
            textAlign: TextAlign.center,
            style: sans(size: 18, weight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          Text(
            'رمز گاوصندوق را وارد کن تا باز شود.',
            textAlign: TextAlign.center,
            style: sans(size: 12.5, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _pass,
            obscureText: _obscure,
            style: sans(size: 14),
            decoration: _lockDec('رمز گاوصندوق', Icons.lock_outline).copyWith(
              suffixIcon: IconButton(
                icon: Icon(
                  _obscure ? Icons.visibility_off : Icons.visibility,
                  size: 20,
                ),
                onPressed: () => setState(() => _obscure = !_obscure),
              ),
            ),
            onSubmitted: (_) => _go(),
          ),
          _errBlock(),
          const SizedBox(height: 16),
          BlocBuilder<VaultBloc, VaultState>(
            buildWhen: (p, c) => p.isBusy != c.isBusy,
            builder: (context, s) => SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: s.isBusy ? null : _go,
                style: ElevatedButton.styleFrom(
                  backgroundColor: kAccent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: s.isBusy
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        'ورود به گاوصندوق',
                        style: sans(size: 15, weight: FontWeight.bold),
                      ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: TextButton(
              onPressed: () => showVaultRecoverySheet(context),
              child: Text(
                'رمز را فراموش کرده‌ام',
                style: sans(size: 12, color: Colors.grey.shade700),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Center(
            child: TextButton(
              onPressed: () => confirmVaultReset(context),
              child: Text(
                'هم رمز و هم کلید بازیابی را گم کرده‌ام؟ پاک کردن همه‌ی اطلاعات',
                textAlign: TextAlign.center,
                style: sans(size: 11, color: _red),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _errBlock() {
    return BlocBuilder<VaultBloc, VaultState>(
      buildWhen: (p, c) => !identical(p.feedback, c.feedback),
      builder: (context, s) {
        final msg =
            _err ?? (s.feedback?.isError == true ? s.feedback!.message : null);
        if (msg == null) return const SizedBox.shrink();
        return Padding(
          padding: const EdgeInsets.only(top: 12),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(msg, style: sans(size: 12, color: Colors.red.shade600)),
          ),
        );
      },
    );
  }
}

// ───────────── آخرین راه: پاک کردن کامل (دو تأیید) ─────────────
Future<void> confirmVaultReset(BuildContext context) async {
  final bloc = context.read<VaultBloc>();
  final ctrl = TextEditingController();
  final word = TextEditingController();
  final pass = await showDialog<String>(
    context: context,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setS) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'پاک کردن همه‌ی اطلاعات گاوصندوق',
            style: sans(
              size: 15,
              weight: FontWeight.bold,
              color: Colors.red.shade500,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'این فقط برای کسی است که هم رمز و هم کلید بازیابی را گم کرده. '
                  'در این حالت اطلاعات قابل برگشت نیست و با ادامه برای همیشه '
                  'پاک می‌شود. اگر کلید بازیابی داری، از «رمز را فراموش '
                  'کرده‌ام» استفاده کن تا چیزی پاک نشود.',
                  style: sans(size: 12.5).copyWith(height: 1.7),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: word,
                  onChanged: (_) => setS(() {}),
                  decoration: const InputDecoration(
                    labelText: 'برای تأیید بنویس: حذف',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: ctrl,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'رمز عبور حساب',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('انصراف', style: sans()),
            ),
            TextButton(
              onPressed: word.text.trim() == 'حذف'
                  ? () => Navigator.pop(ctx, ctrl.text)
                  : null,
              child: Text('پاک کن', style: sans(color: Colors.red.shade500)),
            ),
          ],
        ),
      ),
    ),
  );
  ctrl.dispose();
  word.dispose();
  if (pass != null && pass.isNotEmpty) bloc.add(VaultResetRequested(pass));
}
