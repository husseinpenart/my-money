import 'package:flutter/material.dart';
import 'package:money/theme/app_colors.dart';
import 'login_screen.dart';

/// Shown after either a successful login or a successful registration.
/// [title]/[subtitle] let the caller adapt the copy without duplicating the screen.
class SuccessScreen extends StatefulWidget {
  final String title;
  final String subtitle;

  const SuccessScreen({super.key, required this.title, required this.subtitle});

  @override
  State<SuccessScreen> createState() => _SuccessScreenState();
}

class _SuccessScreenState extends State<SuccessScreen> {
  double _progress = 0;

  @override
  void initState() {
    super.initState();
    // Kick off the progress-bar animation a beat after first frame,
    // mirroring the "signing you in..." loading feel from the design.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 150), () {
        if (mounted) setState(() => _progress = 1);
      });
    });
  }

  void _backToLogin() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(30),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: 1),
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.elasticOut,
                  builder: (context, value, child) =>
                      Transform.scale(scale: value, child: child),
                  child: Container(
                    width: 88,
                    height: 88,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: AppColors.greenGradient,
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(26),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.green2.withOpacity(0.35),
                          blurRadius: 34,
                          offset: const Offset(0, 16),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.check_rounded,
                      color: Colors.white,
                      size: 42,
                    ),
                  ),
                ),
                const SizedBox(height: 22),
                Text(
                  widget.title,
                  style: const TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  widget.subtitle,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 13.5,
                    color: Color(0xFF6B7280),
                    fontWeight: FontWeight.w500,
                    height: 1.8,
                  ),
                ),
                const SizedBox(height: 18),
                Container(
                  width: 220,
                  height: 6,
                  decoration: BoxDecoration(
                    color: AppColors.line,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 1600),
                      curve: Curves.easeOut,
                      width: _progress * 220,
                      height: 6,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: AppColors.greenGradient,
                        ),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                TextButton(
                  onPressed: _backToLogin,
                  child: const Text(
                    'بازگشت به صفحه ورود',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF9AA1B3),
                      decoration: TextDecoration.underline,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
