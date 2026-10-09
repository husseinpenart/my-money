import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:money/feature/auth/presentation/bloc/notification/notification_bloc.dart';
import 'package:money/feature/auth/presentation/bloc/notification/notification_event.dart';
import 'package:money/feature/auth/presentation/bloc/notification/notification_state.dart';
import 'package:money/widgets/notification/notification_sheet.dart';

class NotificationBell extends StatefulWidget {
  const NotificationBell({super.key});

  @override
  State<NotificationBell> createState() => _NotificationBellState();
}

class _NotificationBellState extends State<NotificationBell> {
  late final NotificationBloc _bloc;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _bloc = GetIt.I<NotificationBloc>()..add(const NotificationStarted());
    // شمارنده هر ۵ دقیقه تازه می‌شود
    _timer = Timer.periodic(
      const Duration(minutes: 5),
      (_) => _bloc.add(const NotificationSummaryRequested()),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _bloc.close();
    super.dispose();
  }

  Future<void> _open() async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      constraints: const BoxConstraints(maxWidth: 640),
      builder: (_) =>
          BlocProvider.value(value: _bloc, child: const NotificationSheet()),
    );
    // بعد از بستن، شمارنده با تغییرات احتمالی همگام شود
    _bloc.add(const NotificationSummaryRequested());
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NotificationBloc, NotificationState>(
      bloc: _bloc,
      buildWhen: (p, c) => p.unreadCount != c.unreadCount,
      builder: (context, state) {
        final unread = state.unreadCount;
        return Stack(
          clipBehavior: Clip.none,
          children: [
            InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: _open,
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: const Icon(
                  Icons.notifications_outlined,
                  size: 22,
                  color: Colors.black87,
                ),
              ),
            ),
            if (unread > 0)
              Positioned(
                top: -2,
                right: -2,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.redAccent,
                    shape: BoxShape.circle,
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 18,
                    minHeight: 18,
                  ),
                  child: Center(
                    child: Text(
                      unread > 99 ? '99+' : '$unread',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'sans',
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
