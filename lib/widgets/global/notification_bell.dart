// lib/widgets/global/notification_bell.dart
import 'package:flutter/material.dart';

// مدل ساده برای داده‌های هر پیام
class NotificationItem {
  final String title;
  final String description;
  final String time;
  final bool isRead;

  const NotificationItem({
    required this.title,
    required this.description,
    required this.time,
    this.isRead = false,
  });
}

class NotificationBell extends StatefulWidget {
  final List<NotificationItem>? initialNotifications;

  const NotificationBell({super.key, this.initialNotifications});

  @override
  State<NotificationBell> createState() => _NotificationBellState();
}

class _NotificationBellState extends State<NotificationBell> {
  // لیست نمونه پیام‌ها (می‌توانید بعداً به API یا BLoC متصل کنید)
  late List<NotificationItem> _notifications;

  @override
  void initState() {
    super.initState();
    _notifications = widget.initialNotifications ??
        [
          const NotificationItem(
            title: 'ورود موفق',
            description: 'شما با موفقیت وارد حساب کاربری شدید.',
            time: 'لحظاتی پیش',
            isRead: false,
          ),
          const NotificationItem(
            title: 'به‌روزرسانی سیستم',
            description: 'نسخه جدید با قابلیت‌های بهینه‌تر فعال شد.',
            time: 'دیروز',
            isRead: true,
          ),
        ];
  }

  // محاسبه تعداد پیام‌های خوانده‌نشده
  int get _unreadCount => _notifications.where((n) => !n.isRead).length;

  void _showNotificationsDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.6,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // دستگیره بالای باتم‌شیت
              Container(
                margin: const EdgeInsets.only(top: 10, bottom: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),

              // نوار تیتر باتم‌شیت
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'پیام‌ها و اعلان‌ها',
                      style: TextStyle(
                        fontFamily: 'sans',
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (_unreadCount > 0)
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _notifications = _notifications
                                .map((n) => NotificationItem(
                                      title: n.title,
                                      description: n.description,
                                      time: n.time,
                                      isRead: true,
                                    ))
                                .toList();
                          });
                          Navigator.pop(ctx);
                        },
                        child: const Text(
                          'خواندن همه',
                          style: TextStyle(fontFamily: 'sans', fontSize: 12),
                        ),
                      ),
                  ],
                ),
              ),
              const Divider(height: 1),

              // لیست اعلان‌ها
              Expanded(
                child: _notifications.isEmpty
                    ? const Center(
                        child: Text(
                          'هیچ پیامی وجود ندارد',
                          style: TextStyle(fontFamily: 'sans', color: Colors.grey),
                        ),
                      )
                    : ListView.separated(
                        itemCount: _notifications.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final item = _notifications[index];
                          return Container(
                            color: item.isRead
                                ? Colors.transparent
                                : const Color(0xFFF3F5FF),
                            padding: const EdgeInsets.all(14),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF536DFF).withOpacity(0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.notifications_active_outlined,
                                    color: Color(0xFF536DFF),
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            item.title,
                                            style: TextStyle(
                                              fontFamily: 'sans',
                                              fontWeight: item.isRead
                                                  ? FontWeight.w500
                                                  : FontWeight.bold,
                                              fontSize: 14,
                                            ),
                                          ),
                                          Text(
                                            item.time,
                                            style: TextStyle(
                                              fontFamily: 'sans',
                                              fontSize: 11,
                                              color: Colors.grey.shade500,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        item.description,
                                        style: TextStyle(
                                          fontFamily: 'sans',
                                          fontSize: 12,
                                          color: Colors.grey.shade700,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // کانتینر دکمه زنگوله هماهنگ با طراحی CustomIconButton
        InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => _showNotificationsDialog(context),
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

        // نشانگر پیام‌های خوانده نشده (Badge)
        if (_unreadCount > 0)
          Positioned(
            top: -2,
            right: -2,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Colors.redAccent,
                shape: BoxShape.circle,
              ),
              constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
              child: Center(
                child: Text(
                  '$_unreadCount',
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
  }
}
