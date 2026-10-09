import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:money/feature/auth/presentation/bloc/notification/notification_bloc.dart';
import 'package:money/feature/auth/presentation/bloc/notification/notification_event.dart';
import 'package:money/feature/auth/presentation/bloc/notification/notification_state.dart';
import 'package:money/feature/model/notification/notification_models.dart';
import 'package:money/widgets/contact/contact_style.dart';

import 'package:money/widgets/global/app_search_field.dart';
import 'package:money/widgets/notification/debt_detail_sheet.dart';
import 'package:money/widgets/report/report_format.dart';

class NotificationSheet extends StatefulWidget {
  const NotificationSheet({super.key});

  @override
  State<NotificationSheet> createState() => _NotificationSheetState();
}

class _NotificationSheetState extends State<NotificationSheet> {
  final _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    _scroll.addListener(() {
      if (_scroll.hasClients &&
          _scroll.position.pixels >= _scroll.position.maxScrollExtent - 120) {
        context.read<NotificationBloc>().add(const NotificationLoadMore());
      }
    });
    context.read<NotificationBloc>().add(const NotificationRefreshed());
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _open(AppNotification n) async {
    final bloc = context.read<NotificationBloc>();
    bloc.add(NotificationRead(n.key));
    final changed = await showDebtDetailSheet(context, n.payId);
    if (changed == true) bloc.add(const NotificationRefreshed());
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);

    return Container(
      height: media.size.height * 0.85,
      padding: EdgeInsets.only(bottom: media.viewInsets.bottom),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: BlocBuilder<NotificationBloc, NotificationState>(
        builder: (context, s) {
          return Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 10, bottom: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Text('پیام‌ها و اعلان‌ها',
                        style: sans(size: 16, weight: FontWeight.bold)),
                    const Spacer(),
                    if (s.unreadCount > 0)
                      TextButton(
                        onPressed: () => context
                            .read<NotificationBloc>()
                            .add(const NotificationAllRead()),
                        child: Text('خواندن همه', style: sans(size: 12)),
                      ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                child: AppSearchField(
                  hintText: 'جستجوی نام، شماره، مبلغ یا توضیحات',
                  autofocus: false,
                  isLoading: s.status == NotificationStatus.loading,
                  onChanged: (v) => context
                      .read<NotificationBloc>()
                      .add(NotificationQueryChanged(v)),
                ),
              ),
              _Filters(state: s),
              const Divider(height: 1),
              Expanded(child: _list(s)),
            ],
          );
        },
      ),
    );
  }

  Widget _list(NotificationState s) {
    if (s.status == NotificationStatus.initial ||
        (s.status == NotificationStatus.loading && s.items.isEmpty)) {
      return const Center(child: CircularProgressIndicator(color: kAccent));
    }

    if (s.status == NotificationStatus.failure && s.items.isEmpty) {
      return _Empty(
        icon: Icons.error_outline,
        text: s.error ?? 'خطا در دریافت اعلان‌ها',
        action: 'تلاش دوباره',
        onAction: () =>
            context.read<NotificationBloc>().add(const NotificationRefreshed()),
      );
    }

    if (s.items.isEmpty) {
      return _Empty(
        icon: s.hasActiveFilter ? Icons.search_off : Icons.notifications_none,
        text: s.hasActiveFilter
            ? 'نتیجه‌ای پیدا نشد'
            : 'اعلانی وجود ندارد. سررسیدهای نزدیک اینجا نمایش داده می‌شوند.',
      );
    }

    return RefreshIndicator(
      color: kAccent,
      onRefresh: () async {
        context.read<NotificationBloc>().add(const NotificationRefreshed());
        await Future<void>.delayed(const Duration(milliseconds: 600));
      },
      child: ListView.separated(
        controller: _scroll,
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: s.items.length + (s.isLoadingMore ? 1 : 0),
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, i) {
          if (i >= s.items.length) {
            return const Padding(
              padding: EdgeInsets.all(14),
              child: Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, color: kAccent),
                ),
              ),
            );
          }
          final n = s.items[i];
          return _Tile(
            n: n,
            unread: !s.readKeys.contains(n.key),
            onTap: () => _open(n),
          );
        },
      ),
    );
  }
}

// ───────────────────── فیلترها ─────────────────────
class _Filters extends StatelessWidget {
  final NotificationState state;
  const _Filters({required this.state});

  @override
  Widget build(BuildContext context) {
    final f = state.filter;
    final sm = state.summary;
    final bloc = context.read<NotificationBloc>();

    String c(String t, int n) => '$t (${fa('$n')})';

    Widget kind(String text, NotificationKindFilter k) => Padding(
          padding: const EdgeInsetsDirectional.only(end: 8),
          child: ChoiceChip(
            label: Text(text, style: sans(size: 12)),
            selected: f.kind == k,
            showCheckmark: false,
            selectedColor: kAccent.withValues(alpha: 0.15),
            onSelected: (_) => bloc.add(NotificationFilterChanged(f.copyWith(kind: k))),
          ),
        );

    Widget type(String text, String value) => Padding(
          padding: const EdgeInsetsDirectional.only(end: 8),
          child: FilterChip(
            label: Text(text, style: sans(size: 11)),
            selected: f.recordType == value,
            selectedColor: kAccent.withValues(alpha: 0.15),
            checkmarkColor: kAccent,
            visualDensity: VisualDensity.compact,
            onSelected: (_) => bloc.add(NotificationFilterChanged(
              f.recordType == value
                  ? f.copyWith(clearRecordType: true)
                  : f.copyWith(recordType: value),
            )),
          ),
        );

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Row(
        children: [
          kind(c('همه', sm.total), NotificationKindFilter.all),
          kind(c('معوق', sm.overdue), NotificationKindFilter.overdue),
          kind(c('امروز', sm.today), NotificationKindFilter.today),
          kind(c('به‌زودی', sm.soon), NotificationKindFilter.soon),
          Container(width: 1, height: 22, color: Colors.grey.shade300),
          const SizedBox(width: 8),
          type('بدهی', 'Debt'),
          type('طلب', 'Receivable'),
        ],
      ),
    );
  }
}

// ───────────────────── آیتم ─────────────────────
class _Tile extends StatelessWidget {
  final AppNotification n;
  final bool unread;
  final VoidCallback onTap;
  const _Tile({required this.n, required this.unread, required this.onTap});

  Color get _color => switch (n.kind) {
        NotificationKind.overdue => const Color(0xFFDC2626),
        NotificationKind.today => const Color(0xFFF97316),
        NotificationKind.soon => const Color(0xFFF59E0B),
      };

  IconData get _icon => switch (n.kind) {
        NotificationKind.overdue => Icons.warning_amber_rounded,
        NotificationKind.today => Icons.alarm,
        NotificationKind.soon => Icons.schedule,
      };

  String get _time {
    final d = n.endedDate;
    final date = d == null ? '' : jalaliDate(d);
    return switch (n.kind) {
      NotificationKind.overdue => '${fa('${n.daysLeft.abs()}')} روز معوق',
      NotificationKind.today => 'امروز',
      NotificationKind.soon => '${fa('${n.daysLeft}')} روز دیگر',
    } +
        (date.isEmpty ? '' : '  ·  $date');
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        color: unread ? const Color(0xFFF3F5FF) : Colors.transparent,
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _color.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(_icon, color: _color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          n.title,
                          style: sans(
                            size: 13,
                            weight: unread ? FontWeight.bold : FontWeight.w500,
                          ),
                        ),
                      ),
                      if (n.isStarred)
                        const Icon(Icons.star, size: 14, color: Colors.amber),
                      if (unread)
                        Container(
                          margin: const EdgeInsetsDirectional.only(start: 6),
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: kAccent,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(n.message,
                      style: sans(size: 12, color: Colors.grey.shade700)),
                  const SizedBox(height: 6),
                  Text(_time, style: sans(size: 11, color: _color)),
                ],
              ),
            ),
            const SizedBox(width: 4),
            Icon(Icons.chevron_left, size: 20, color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }
}

class _Empty extends StatelessWidget {
  final IconData icon;
  final String text;
  final String? action;
  final VoidCallback? onAction;
  const _Empty({required this.icon, required this.text, this.action, this.onAction});

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 44, color: Colors.grey.shade400),
              const SizedBox(height: 10),
              Text(text,
                  textAlign: TextAlign.center,
                  style: sans(size: 12, color: Colors.grey.shade600)),
              if (action != null) ...[
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: onAction,
                  child: Text(action!, style: sans(size: 12)),
                ),
              ],
            ],
          ),
        ),
      );
}