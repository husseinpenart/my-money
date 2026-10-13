import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:money/feature/auth/presentation/bloc/vault/vault_bloc.dart';
import 'package:money/feature/auth/presentation/bloc/vault/vault_event.dart';
import 'package:money/feature/auth/presentation/bloc/vault/vault_state.dart';
import 'package:money/feature/model/vault/vault_models.dart';
import 'package:money/widgets/contact/contact_style.dart';
import 'package:money/widgets/global/app_search_field.dart';
import 'package:money/widgets/global/sync_bar.dart';
import 'package:money/widgets/report/report_format.dart';
import 'package:money/widgets/vault/vault_detail_sheet.dart';
import 'package:money/widgets/vault/vault_fields.dart';
import 'package:money/widgets/vault/vault_form_sheet.dart';
import 'package:money/widgets/vault/vault_lock_views.dart';
import 'package:money/widgets/vault/vault_recovery_views.dart'; // 👈 جدید

class VaultPage extends StatelessWidget {
  const VaultPage({super.key});

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) => GetIt.I<VaultBloc>()..add(const VaultStarted()),
    child: const _View(),
  );
}

class _View extends StatefulWidget {
  const _View();
  @override
  State<_View> createState() => _ViewState();
}

class _ViewState extends State<_View> with WidgetsBindingObserver {
  DateTime? _hiddenAt;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  /// قفل خودکار: اگر بیش از ۶۰ ثانیه از صفحه دور شدی
  @override
  void didChangeAppLifecycleState(AppLifecycleState s) {
    if (s == AppLifecycleState.paused || s == AppLifecycleState.hidden) {
      _hiddenAt ??= DateTime.now();
    } else if (s == AppLifecycleState.resumed) {
      final t = _hiddenAt;
      _hiddenAt = null;
      if (t != null &&
          DateTime.now().difference(t) > const Duration(seconds: 60)) {
        context.read<VaultBloc>().add(const VaultLocked());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'گاوصندوق امن',
          style: sans(size: 16, weight: FontWeight.bold),
        ),
        actions: [
          BlocBuilder<VaultBloc, VaultState>(
            buildWhen: (p, c) => p.status != c.status,
            builder: (context, s) => s.status == VaultStatus.unlocked
                ? Row(
                    children: [
                      IconButton(
                        tooltip: 'قفل کردن',
                        icon: const Icon(Icons.lock_outline_rounded),
                        onPressed: () =>
                            context.read<VaultBloc>().add(const VaultLocked()),
                      ),
                      // 👈 منوی سه‌گزینه‌ای
                      PopupMenuButton<String>(
                        onSelected: (v) {
                          switch (v) {
                            case 'pass':
                              showVaultChangePassphrase(context);
                            case 'rec':
                              showVaultRegenerateRecovery(context);
                            case 'reset':
                              confirmVaultReset(context);
                          }
                        },
                        itemBuilder: (_) => [
                          PopupMenuItem(
                            value: 'pass',
                            child: Text(
                              'تغییر رمز گاوصندوق',
                              style: sans(size: 13),
                            ),
                          ),
                          PopupMenuItem(
                            value: 'rec',
                            child: Text(
                              'ساخت کلید بازیابی جدید',
                              style: sans(size: 13),
                            ),
                          ),
                          const PopupMenuDivider(),
                          PopupMenuItem(
                            value: 'reset',
                            child: Text(
                              'پاک کردن همه‌ی اطلاعات',
                              style: sans(size: 13, color: Colors.red.shade400),
                            ),
                          ),
                        ],
                      ),
                    ],
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
      body: BlocListener<VaultBloc, VaultState>(
        // 👈 نمایش یک‌باره‌ی کلید بازیابی (setup / recover / regenerate)
        listenWhen: (p, c) =>
            c.newRecoveryKey != null && p.newRecoveryKey != c.newRecoveryKey,
        listener: (context, s) async {
          final bloc = context.read<VaultBloc>();
          await showVaultRecoveryKeyDialog(context, s.newRecoveryKey!);
          bloc.add(const VaultRecoveryKeyAcknowledged());
        },
        child: BlocListener<VaultBloc, VaultState>(
          // 👈 snackbar فقط برای feedback داخل گاوصندوق؛ قفل/ساخت inline‌اند
          listenWhen: (p, c) =>
              c.feedback != null &&
              !identical(p.feedback, c.feedback) &&
              c.status == VaultStatus.unlocked,
          listener: (context, s) {
            final fb = s.feedback!;
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(
                  behavior: SnackBarBehavior.floating,
                  backgroundColor: fb.isError
                      ? Colors.red.shade400
                      : Colors.green.shade600,
                  content: Text(
                    fb.message,
                    style: sans(size: 13, color: Colors.white),
                  ),
                ),
              );
          },
          child: BlocBuilder<VaultBloc, VaultState>(
            buildWhen: (p, c) => p.status != c.status,
            builder: (context, s) => switch (s.status) {
              VaultStatus.initial => const Center(
                child: CircularProgressIndicator(color: kAccent),
              ),
              VaultStatus.loading => const Center(
                child: CircularProgressIndicator(color: kAccent),
              ),
              VaultStatus.needsSetup => const VaultSetupView(),
              VaultStatus.locked => const VaultUnlockView(),
              VaultStatus.failure => Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      s.error ?? 'خطا',
                      style: sans(size: 13, color: Colors.red.shade400),
                    ),
                    const SizedBox(height: 10),
                    OutlinedButton(
                      onPressed: () =>
                          context.read<VaultBloc>().add(const VaultStarted()),
                      child: Text('تلاش دوباره', style: sans(size: 12)),
                    ),
                  ],
                ),
              ),
              VaultStatus.unlocked => const _ListView(),
            },
          ),
        ),
      ),
      floatingActionButton: BlocBuilder<VaultBloc, VaultState>(
        buildWhen: (p, c) => p.status != c.status,
        builder: (context, s) => s.status == VaultStatus.unlocked
            ? FloatingActionButton.extended(
                backgroundColor: kAccent,
                foregroundColor: Colors.white,
                onPressed: () => showVaultFormSheet(context),
                icon: const Icon(Icons.add),
                label: Text('آیتم جدید', style: sans(size: 13)),
              )
            : const SizedBox.shrink(),
      ),
    );
  }
}

class _ListView extends StatelessWidget {
  const _ListView();

  Future<void> _refresh(BuildContext context) {
    final done = Completer<void>();
    context.read<VaultBloc>().add(VaultRefreshed(done: done));
    return done.future;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Column(
        children: [
          BlocBuilder<VaultBloc, VaultState>(
            buildWhen: (p, c) =>
                p.lastSyncedAt != c.lastSyncedAt ||
                p.syncing != c.syncing ||
                p.pending != c.pending,
            builder: (context, s) => Column(
              children: [
                SyncBar(
                  syncedAt: s.lastSyncedAt,
                  busy: s.syncing,
                  onRefresh: () =>
                      context.read<VaultBloc>().add(const VaultRefreshed()),
                ),
                if (s.pending > 0)
                  Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        '${fa('${s.pending}')} تغییر در انتظار ارسال به سرور',
                        style: sans(size: 11, color: Colors.orange.shade800),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          AppSearchField(
            autofocus: false,
            hintText: 'جستجو در عنوان و توضیحات...',
            onChanged: (v) =>
                context.read<VaultBloc>().add(VaultQueryChanged(v)),
          ),
          const SizedBox(height: 10),
          BlocBuilder<VaultBloc, VaultState>(
            buildWhen: (p, c) =>
                p.category != c.category ||
                p.counts != c.counts ||
                p.total != c.total,
            builder: (context, s) => SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  Padding(
                    padding: const EdgeInsetsDirectional.only(end: 8),
                    child: ChoiceChip(
                      label: Text(
                        'همه (${fa('${s.total}')})',
                        style: sans(size: 12),
                      ),
                      selected: s.category == null,
                      showCheckmark: false,
                      selectedColor: kAccent.withValues(alpha: 0.15),
                      onSelected: (_) => context.read<VaultBloc>().add(
                        const VaultCategoryChanged(null),
                      ),
                    ),
                  ),
                  for (final c in VaultCategory.values)
                    Padding(
                      padding: const EdgeInsetsDirectional.only(end: 8),
                      child: ChoiceChip(
                        avatar: Icon(c.icon, size: 15, color: c.color),
                        label: Text(
                          '${c.label} (${fa('${s.counts[c.id] ?? 0}')})',
                          style: sans(size: 12),
                        ),
                        selected: s.category == c,
                        showCheckmark: false,
                        selectedColor: c.color.withValues(alpha: 0.15),
                        onSelected: (_) => context.read<VaultBloc>().add(
                          VaultCategoryChanged(s.category == c ? null : c),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 6),
          Expanded(
            child: BlocBuilder<VaultBloc, VaultState>(
              buildWhen: (p, c) => p.entries != c.entries || p.total != c.total,
              builder: (context, s) {
                if (s.entries.isEmpty) {
                  return RefreshIndicator(
                    color: kAccent,
                    onRefresh: () => _refresh(context),
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        const SizedBox(height: 80),
                        Icon(
                          s.total == 0
                              ? Icons.shield_moon_outlined
                              : Icons.search_off_rounded,
                          size: 48,
                          color: Colors.grey.shade300,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          s.total == 0
                              ? 'گاوصندوق خالی است. طلا، اسناد یا اطلاعات '
                                    'محرمانه‌ات را اضافه کن.'
                              : 'موردی پیدا نشد',
                          textAlign: TextAlign.center,
                          style: sans(size: 13, color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  );
                }
                return RefreshIndicator(
                  color: kAccent,
                  onRefresh: () => _refresh(context),
                  child: ListView.separated(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.only(bottom: 100),
                    itemCount: s.entries.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, i) => _Tile(entry: s.entries[i]),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  final VaultEntry entry;
  const _Tile({required this.entry});

  @override
  Widget build(BuildContext context) {
    final c = entry.category;
    final p = entry.plain;
    final sub = p == null ? 'رمزگشایی نشد' : vaultSummary(c, p);
    final pending = entry.record.pending || entry.record.pendingAttachments > 0;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEEF0F4)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => showVaultDetailSheet(context, entry.id),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: c.color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(c.icon, color: c.color, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: sans(
                        size: 14,
                        weight: FontWeight.bold,
                        color: entry.corrupt ? Colors.red.shade400 : null,
                      ),
                    ),
                    if (sub.isNotEmpty) ...[
                      const SizedBox(height: 3),
                      Text(
                        sub,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: sans(size: 11.5, color: Colors.grey.shade600),
                      ),
                    ],
                  ],
                ),
              ),
              if (entry.visibleAttachments > 0) ...[
                Icon(
                  Icons.attach_file_rounded,
                  size: 16,
                  color: Colors.grey.shade500,
                ),
                Text(
                  fa('${entry.visibleAttachments}'),
                  style: sans(size: 11, color: Colors.grey.shade600),
                ),
                const SizedBox(width: 6),
              ],
              if (pending)
                Tooltip(
                  message: 'در انتظار همگام‌سازی',
                  child: Icon(
                    Icons.cloud_upload_outlined,
                    size: 18,
                    color: Colors.orange.shade700,
                  ),
                ),
              Icon(Icons.chevron_left, size: 18, color: Colors.grey.shade400),
            ],
          ),
        ),
      ),
    );
  }
}
