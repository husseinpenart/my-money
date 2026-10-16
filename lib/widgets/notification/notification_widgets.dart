import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:money/core/alerts/alert_coordinator.dart';
import 'package:money/feature/auth/presentation/bloc/notification/notification_bloc.dart';
import 'package:money/feature/auth/presentation/bloc/notification/notification_state.dart';
import 'package:money/feature/model/notification/notification_models.dart';
import 'package:money/widgets/contact/contact_style.dart';
import 'package:money/widgets/report/report_format.dart';

/// زنگوله با نشان‌گر شمارنده. فقط وقتی نخوانده هست نشان داده می‌شود
class NotificationBell extends StatelessWidget {
  final VoidCallback onTap;
  const NotificationBell({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return BlocSelector<NotificationBloc, NotificationState, int>(
      selector: (s) => s.unreadCount,
      builder: (context, unread) => IconButton(
        tooltip: 'اعلان‌ها',
        onPressed: onTap,
        icon: Badge(
          isLabelVisible: unread > 0,
          backgroundColor: const Color(0xFFEF4444),
          label: Text(
            unread > 99 ? '+۹۹' : fa('$unread'),
            style: sans(size: 9, color: Colors.white),
          ),
          child: const Icon(Icons.notifications_none_rounded, size: 26),
        ),
      ),
    );
  }
}

/// هشدارهای حقوق و بودجه؛ بالای لیست اعلان‌ها (وقتی جستجو یا فیلتر فعال نیست)
class BudgetAlertsSection extends StatelessWidget {
  final List<BudgetAlert> alerts;
  final Set<String> readKeys;
  final ValueChanged<String> onRead;
  const BudgetAlertsSection({
    super.key,
    required this.alerts,
    required this.readKeys,
    required this.onRead,
  });

  @override
  Widget build(BuildContext context) {
    if (alerts.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 4, 4, 8),
          child: Text(
            'حقوق و بودجه',
            style: sans(
              size: 12,
              weight: FontWeight.bold,
              color: Colors.grey.shade700,
            ),
          ),
        ),
        for (final a in alerts)
          Builder(
            builder: (_) {
              final unread = !readKeys.contains(a.key);
              return InkWell(
                onTap: () => onRead(a.key),
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: a.color.withValues(alpha: unread ? 0.10 : 0.04),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: a.color.withValues(alpha: unread ? 0.35 : 0.15),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(a.icon, size: 20, color: a.color),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              a.title,
                              style: sans(
                                size: 13,
                                weight: unread
                                    ? FontWeight.bold
                                    : FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              a.message,
                              style: sans(
                                size: 11.5,
                                color: Colors.grey.shade700,
                              ).copyWith(height: 1.7),
                            ),
                          ],
                        ),
                      ),
                      if (unread)
                        Container(
                          width: 8,
                          height: 8,
                          margin: const EdgeInsets.only(top: 4),
                          decoration: BoxDecoration(
                            color: a.color,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        const SizedBox(height: 4),
      ],
    );
  }
}

/// کلید روشن/خاموش اعلان دستگاه
class DeviceAlertsTile extends StatefulWidget {
  const DeviceAlertsTile({super.key});
  @override
  State<DeviceAlertsTile> createState() => _DeviceAlertsTileState();
}

class _DeviceAlertsTileState extends State<DeviceAlertsTile> {
  final _c = GetIt.I<AlertCoordinator>();
  bool _busy = false;

  Future<void> _toggle(bool v) async {
    setState(() => _busy = true);
    var ok = false;
    if (v) {
      ok = await _c.enable();
    } else {
      await _c.disable();
    }
    if (!mounted) return;
    setState(() => _busy = false);
    if (v && !ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.red.shade400,
          content: Text(
            'اجازه‌ی اعلان داده نشد. از تنظیمات دستگاه یا مرورگر فعالش کن.',
            style: sans(size: 12, color: Colors.white),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: kAccent.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: kAccent.withValues(alpha: 0.2)),
      ),
      child: SwitchListTile(
        dense: true,
        value: _c.enabled,
        onChanged: _busy ? null : _toggle,
        activeThumbColor: kAccent,
        title: Text(
          'اعلان روی دستگاه',
          style: sans(size: 13, weight: FontWeight.bold),
        ),
        subtitle: Text(
          _c.supportsSchedule
              ? 'هر روز ساعت ۹ صبح، سررسیدهای فردا و امروز را یادآوری می‌کند؛ حتی وقتی اپ بسته است.'
              : 'وقتی این تب باز است، سررسیدها و هشدارهای بودجه را اعلان می‌کند.',
          style: sans(
            size: 11,
            color: Colors.grey.shade700,
          ).copyWith(height: 1.6),
        ),
      ),
    );
  }
}
