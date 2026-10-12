import 'package:flutter/material.dart';
import 'package:money/widgets/contact/contact_style.dart';
import 'package:money/widgets/report/report_format.dart';

/// زمان آخرین بروزرسانی + دکمه‌ی رفرش (برای مخاطبین و بدهی/طلب)
class SyncBar extends StatelessWidget {
  final DateTime? syncedAt;
  final bool busy;
  final VoidCallback onRefresh;
  const SyncBar({
    super.key,
    required this.syncedAt,
    required this.busy,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(Icons.cloud_done_outlined, size: 15, color: Colors.grey.shade500),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            syncedAt == null
                ? 'هنوز بروزرسانی نشده'
                : 'آخرین بروزرسانی: ${jalaliDateTime(syncedAt!)}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: sans(size: 11, color: Colors.grey.shade600),
          ),
        ),
        OutlinedButton.icon(
          onPressed: busy ? null : onRefresh,
          icon: busy
              ? const SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: kAccent,
                  ),
                )
              : const Icon(Icons.refresh_rounded, size: 17, color: kAccent),
          label: Text('بروزرسانی', style: sans(size: 12, color: kAccent)),
          style: OutlinedButton.styleFrom(
            visualDensity: VisualDensity.compact,
            side: BorderSide(color: kAccent.withValues(alpha: 0.4)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ),
      ],
    );
  }
}
