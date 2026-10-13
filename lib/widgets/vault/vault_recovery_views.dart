import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:money/feature/auth/presentation/bloc/vault/vault_bloc.dart';
import 'package:money/feature/auth/presentation/bloc/vault/vault_event.dart';
import 'package:money/feature/auth/presentation/bloc/vault/vault_state.dart';
import 'package:money/widgets/contact/contact_style.dart';
import 'package:money/widgets/vault/vault_lock_views.dart'
    show vaultPassphraseError;

const _green = Color(0xFF10B981);
const _red = Color(0xFFEF4444);

InputDecoration _recDec(String label, IconData icon, {bool obscure = false}) =>
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

// ───────────── نمایش کلید بازیابی (یک‌بار، مرکزی) ─────────────
Future<void> showVaultRecoveryKeyDialog(BuildContext context, String key) {
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (ctx) => Directionality(
      textDirection: TextDirection.rtl,
      child: AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Row(
          children: [
            const Icon(Icons.vpn_key_rounded, color: _green),
            const SizedBox(width: 8),
            Text(
              'کلید بازیابی شما',
              style: sans(size: 15, weight: FontWeight.bold),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: _red.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: _red.withValues(alpha: 0.3)),
              ),
              child: Text(
                'این کلید فقط یک‌بار نمایش داده می‌شود. آن را در جای امن (کاغذ یا '
                'مدیر رمز) ذخیره کن. اگر رمز را فراموش کنی، با همین کلید بدون از '
                'دست رفتن اطلاعات دوباره وارد می‌شوی. اگر هم رمز و هم این کلید را '
                'گم کنی، هیچ‌کس (حتی ما) نمی‌تواند اطلاعات را برگرداند.',
                style: sans(
                  size: 12,
                  color: Colors.red.shade700,
                ).copyWith(height: 1.7),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: SelectableText(
                key,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'sans',
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                  height: 1.6,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: () async {
                  await Clipboard.setData(ClipboardData(text: key));
                  if (!ctx.mounted) return;
                  ScaffoldMessenger.of(ctx)
                    ..hideCurrentSnackBar()
                    ..showSnackBar(
                      SnackBar(
                        behavior: SnackBarBehavior.floating,
                        duration: const Duration(seconds: 2),
                        content: Text(
                          'کلید کپی شد؛ آن را جای امن بچسبان',
                          style: sans(size: 12, color: Colors.white),
                        ),
                      ),
                    );
                },
                icon: const Icon(Icons.copy_rounded, size: 18),
                label: Text('کپی کلید', style: sans(size: 12)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'ذخیره کردم، ببند',
              style: sans(size: 13, color: _green, weight: FontWeight.bold),
            ),
          ),
        ],
      ),
    ),
  );
}

// ───────────── فراموشی رمز: با کلید بازیابی، بدون پاک‌شدن ─────────────
Future<void> showVaultRecoverySheet(BuildContext context) {
  final bloc = context.read<VaultBloc>();
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: false,
    backgroundColor: Colors.transparent,
    constraints: const BoxConstraints(maxWidth: 640),
    builder: (_) =>
        BlocProvider.value(value: bloc, child: const _RecoverySheet()),
  );
}

class _RecoverySheet extends StatefulWidget {
  const _RecoverySheet();
  @override
  State<_RecoverySheet> createState() => _RecoverySheetState();
}

class _RecoverySheetState extends State<_RecoverySheet> {
  final _rec = TextEditingController();
  final _np = TextEditingController();
  final _np2 = TextEditingController();
  final _acct = TextEditingController();
  bool _obscure = true;
  String? _err;

  @override
  void dispose() {
    _rec.dispose();
    _np.dispose();
    _np2.dispose();
    _acct.dispose();
    super.dispose();
  }

  void _submit() {
    if (_rec.text.trim().isEmpty) {
      setState(() => _err = 'کلید بازیابی را وارد کن');
      return;
    }
    final pe = vaultPassphraseError(_np.text);
    if (pe != null) {
      setState(() => _err = pe);
      return;
    }
    if (_np.text != _np2.text) {
      setState(() => _err = 'رمز جدید و تکرار آن یکسان نیست');
      return;
    }
    if (_acct.text.isEmpty) {
      setState(() => _err = 'رمز عبور حساب را وارد کن');
      return;
    }
    setState(() => _err = null);
    context.read<VaultBloc>().add(
      VaultRecoverSubmitted(_rec.text.trim(), _np.text, _acct.text),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _SheetScaffold(
      title: 'باز کردن با کلید بازیابی',
      busyBuilder: (busy, fb) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'کلید بازیابی ۱۲ گروهی را که هنگام ساخت ذخیره کرده‌ای وارد کن، '
            'سپس رمز تازه‌ی گاوصندوق را تعیین کن. اطلاعاتت دست‌نخورده می‌ماند '
            'و یک کلید بازیابی جدید هم به تو داده می‌شود.',
            style: sans(
              size: 12.5,
              color: Colors.grey.shade700,
            ).copyWith(height: 1.7),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _rec,
            enabled: !busy,
            autocorrect: false,
            textCapitalization: TextCapitalization.characters,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9\- ]')),
            ],
            style: const TextStyle(
              fontFamily: 'sans',
              fontSize: 14,
              letterSpacing: 1,
            ),
            decoration: _recDec('کلید بازیابی', Icons.vpn_key_outlined),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _np,
            enabled: !busy,
            obscureText: _obscure,
            style: sans(size: 14),
            decoration: _recDec('رمز جدید گاوصندوق', Icons.lock_outline)
                .copyWith(
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscure ? Icons.visibility_off : Icons.visibility,
                      size: 20,
                    ),
                    onPressed: () => setState(() => _obscure = !_obscure),
                  ),
                ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _np2,
            enabled: !busy,
            obscureText: _obscure,
            style: sans(size: 14),
            decoration: _recDec('تکرار رمز جدید', Icons.lock_reset_outlined),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _acct,
            enabled: !busy,
            obscureText: true,
            style: sans(size: 14),
            decoration: _recDec('رمز عبور حساب کاربری', Icons.person_outline),
          ),
          _inlineError(_err ?? (fb?.isError == true ? fb!.message : null)),
          const SizedBox(height: 16),
          _primaryButton(busy, 'باز کردن گاوصندوق', _submit),
        ],
      ),
    );
  }
}

// ───────────── تغییر رمز (وقتی باز است) ─────────────
Future<void> showVaultChangePassphrase(BuildContext context) {
  final bloc = context.read<VaultBloc>();
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: false,
    backgroundColor: Colors.transparent,
    constraints: const BoxConstraints(maxWidth: 640),
    builder: (_) =>
        BlocProvider.value(value: bloc, child: const _ChangePassSheet()),
  );
}

class _ChangePassSheet extends StatefulWidget {
  const _ChangePassSheet();
  @override
  State<_ChangePassSheet> createState() => _ChangePassSheetState();
}

class _ChangePassSheetState extends State<_ChangePassSheet> {
  final _old = TextEditingController();
  final _np = TextEditingController();
  final _np2 = TextEditingController();
  final _acct = TextEditingController();
  String? _err;

  @override
  void dispose() {
    _old.dispose();
    _np.dispose();
    _np2.dispose();
    _acct.dispose();
    super.dispose();
  }

  void _submit() {
    if (_old.text.isEmpty) {
      setState(() => _err = 'رمز فعلی را وارد کن');
      return;
    }
    final pe = vaultPassphraseError(_np.text);
    if (pe != null) {
      setState(() => _err = pe);
      return;
    }
    if (_np.text != _np2.text) {
      setState(() => _err = 'رمز جدید و تکرار آن یکسان نیست');
      return;
    }
    if (_acct.text.isEmpty) {
      setState(() => _err = 'رمز عبور حساب را وارد کن');
      return;
    }
    setState(() => _err = null);
    context.read<VaultBloc>().add(
      VaultPassphraseChangeSubmitted(_old.text, _np.text, _acct.text),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _SheetScaffold(
      title: 'تغییر رمز گاوصندوق',
      busyBuilder: (busy, fb) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'کلید رمزگذاری داده‌ها عوض نمی‌شود، پس هیچ اطلاعاتی پاک یا '
            'بازرمز نمی‌شود؛ فقط قُفلِ ورود عوض می‌شود. رمز عبور حساب هم برای '
            'تأیید هویت لازم است.',
            style: sans(
              size: 12.5,
              color: Colors.grey.shade700,
            ).copyWith(height: 1.7),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _old,
            enabled: !busy,
            obscureText: true,
            style: sans(size: 14),
            decoration: _recDec('رمز فعلی گاوصندوق', Icons.lock_outline),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _np,
            enabled: !busy,
            obscureText: true,
            style: sans(size: 14),
            decoration: _recDec('رمز جدید', Icons.lock_reset_outlined),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _np2,
            enabled: !busy,
            obscureText: true,
            style: sans(size: 14),
            decoration: _recDec('تکرار رمز جدید', Icons.check_circle_outline),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _acct,
            enabled: !busy,
            obscureText: true,
            style: sans(size: 14),
            decoration: _recDec('رمز عبور حساب کاربری', Icons.person_outline),
          ),
          _inlineError(_err ?? (fb?.isError == true ? fb!.message : null)),
          const SizedBox(height: 16),
          _primaryButton(busy, 'تغییر رمز', _submit),
        ],
      ),
    );
  }
}

// ───────────── ساخت کلید بازیابی جدید ─────────────
Future<void> showVaultRegenerateRecovery(BuildContext context) {
  final bloc = context.read<VaultBloc>();
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: false,
    backgroundColor: Colors.transparent,
    constraints: const BoxConstraints(maxWidth: 640),
    builder: (_) => BlocProvider.value(value: bloc, child: const _RegenSheet()),
  );
}

class _RegenSheet extends StatefulWidget {
  const _RegenSheet();
  @override
  State<_RegenSheet> createState() => _RegenSheetState();
}

class _RegenSheetState extends State<_RegenSheet> {
  final _acct = TextEditingController();
  String? _err;

  @override
  void dispose() {
    _acct.dispose();
    super.dispose();
  }

  void _submit() {
    if (_acct.text.isEmpty) {
      setState(() => _err = 'رمز عبور حساب را وارد کن');
      return;
    }
    setState(() => _err = null);
    context.read<VaultBloc>().add(VaultRecoveryRegenerated(_acct.text));
  }

  @override
  Widget build(BuildContext context) {
    return _SheetScaffold(
      title: 'کلید بازیابی جدید',
      busyBuilder: (busy, fb) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.orange.shade200),
            ),
            child: Text(
              'با این کار کلید فعلی باطل می‌شود و کلید تازه‌ای ساخته می‌شود. '
              'کلید جدید را فوراً ذخیره کن؛ کلید قبلی دیگر کار نمی‌کند.',
              style: sans(
                size: 12,
                color: Colors.orange.shade800,
              ).copyWith(height: 1.7),
            ),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _acct,
            enabled: !busy,
            obscureText: true,
            style: sans(size: 14),
            decoration: _recDec('رمز عبور حساب کاربری', Icons.person_outline),
          ),
          _inlineError(_err ?? (fb?.isError == true ? fb!.message : null)),
          const SizedBox(height: 16),
          _primaryButton(busy, 'ساخت کلید جدید', _submit),
        ],
      ),
    );
  }
}

// ───────────── پوسته‌ی مشترک sheet‌ها ─────────────
/// بعد از پایان کار: موفق → بستن | خطا → نمایش inline.
class _SheetScaffold extends StatefulWidget {
  const _SheetScaffold({required this.title, required this.busyBuilder});
  final String title;
  final Widget Function(bool busy, VaultFeedback? fb) busyBuilder;

  @override
  State<_SheetScaffold> createState() => _SheetScaffoldState();
}

class _SheetScaffoldState extends State<_SheetScaffold> {
  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final inset = media.viewInsets.bottom > 0
        ? media.viewInsets.bottom
        : media.padding.bottom;

    return BlocListener<VaultBloc, VaultState>(
      listenWhen: (p, c) => p.isBusy && !c.isBusy,
      listener: (context, s) {
        final fb = s.feedback;
        if (fb == null) return;
        if (fb.isError) return; // inline نمایش داده می‌شود
        Navigator.of(context).pop();
      },
      child: Container(
        constraints: BoxConstraints(maxHeight: media.size.height * 0.94),
        padding: EdgeInsets.only(bottom: inset),
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
                      widget.title,
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
                child: BlocBuilder<VaultBloc, VaultState>(
                  buildWhen: (p, c) =>
                      p.isBusy != c.isBusy ||
                      !identical(p.feedback, c.feedback),
                  builder: (context, s) =>
                      widget.busyBuilder(s.isBusy, s.feedback),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget _inlineError(String? msg) {
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
}

Widget _primaryButton(bool busy, String label, VoidCallback onTap) {
  return SizedBox(
    width: double.infinity,
    height: 48,
    child: ElevatedButton(
      onPressed: busy ? null : onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: kAccent,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: busy
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
          : Text(label, style: sans(size: 14, weight: FontWeight.bold)),
    ),
  );
}
