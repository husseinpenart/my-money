import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';

import 'package:money/core/network/backend_message.dart';
import 'package:money/core/vault/vault_repository.dart';
import 'package:money/feature/auth/presentation/bloc/vault/vault_event.dart';
import 'package:money/feature/auth/presentation/bloc/vault/vault_state.dart';
import 'package:money/feature/model/vault/vault_models.dart';
import 'package:money/helper/utils/input_utils.dart';

class VaultBloc extends Bloc<VaultEvent, VaultState> {
  final VaultRepository repo;

  late final VoidCallback _listener;

  VaultBloc(this.repo) : super(const VaultState()) {
    on<VaultStarted>(_onStarted);

    on<VaultSetupSubmitted>(_onSetup, transformer: droppable());
    on<VaultUnlockSubmitted>(_onUnlock, transformer: droppable());

    on<VaultLocked>(_onLock);
    on<VaultRefreshed>(_onRefreshed, transformer: droppable());

    on<VaultQueryChanged>((e, emit) {
      emit(state.copyWith(query: e.query.trim()));
      _project(emit);
    });

    on<VaultCategoryChanged>((e, emit) {
      emit(
        e.category == null
            ? state.copyWith(clearCategory: true)
            : state.copyWith(category: e.category),
      );
      _project(emit);
    });

    on<VaultItemSaved>(_onSaved, transformer: sequential());
    on<VaultItemDeleted>(_onDeleted, transformer: sequential());

    on<VaultResetRequested>(_onReset, transformer: droppable());

    on<VaultRecoverSubmitted>(_onRecover, transformer: droppable());
    on<VaultPassphraseChangeSubmitted>(_onChangePass, transformer: droppable());
    on<VaultRecoveryRegenerated>(_onRegen, transformer: droppable());

    on<VaultRecoveryKeyAcknowledged>((e, emit) {
      emit(state.copyWith(clearRecoveryKey: true));
    });

    on<VaultRepoChanged>(_onRepoChanged);

    _listener = () {
      if (!isClosed) add(const VaultRepoChanged());
    };

    repo.addListener(_listener);
    repo.syncing.addListener(_listener);
  }

  String _msg(Object e) =>
      e is VaultApiException ? e.message : backendMessage(e);

  void _project(Emitter<VaultState> emit) {
    final all = repo.entries;

    final counts = <int, int>{};
    for (final e in all) {
      counts[e.category.id] = (counts[e.category.id] ?? 0) + 1;
    }

    final terms = normalizeDigits(
      state.query.toLowerCase(),
    ).split(' ').where((t) => t.isNotEmpty).toList();

    final list = all.where((e) {
      if (state.category != null && e.category != state.category) return false;
      if (terms.isEmpty) return true;

      final p = e.plain;
      final hay = normalizeDigits(
        '${p?.title ?? ''} ${p?.note ?? ''} '
                '${p?.fields['kind'] ?? ''} ${p?.fields['docType'] ?? ''}'
            .toLowerCase(),
      );

      return terms.every(hay.contains);
    }).toList();

    emit(
      state.copyWith(
        entries: list,
        counts: counts,
        total: all.length,
        pending: repo.pendingCount,
        syncing: repo.syncing.value,
        lastSyncedAt: repo.lastSyncedAt,
      ),
    );
  }

  Future<void> _onStarted(VaultStarted e, Emitter<VaultState> emit) async {
    emit(state.copyWith(status: VaultStatus.loading));

    try {
      final has = await repo.hasProfile();
      emit(
        state.copyWith(
          status: has ? VaultStatus.locked : VaultStatus.needsSetup,
        ),
      );
    } catch (err) {
      emit(state.copyWith(status: VaultStatus.failure, error: _msg(err)));
    }
  }

  Future<void> _onSetup(VaultSetupSubmitted e, Emitter<VaultState> emit) async {
    emit(state.copyWith(isBusy: true, clearFeedback: true));

    try {
      final key = await repo.setup(e.secret);
      emit(
        state.copyWith(
          status: VaultStatus.unlocked,
          isBusy: false,
          newRecoveryKey: key,
        ),
      );
      _project(emit);
    } catch (err) {
      emit(
        state.copyWith(isBusy: false, feedback: VaultFeedback.error(_msg(err))),
      );
    }
  }

  Future<void> _onUnlock(
    VaultUnlockSubmitted e,
    Emitter<VaultState> emit,
  ) async {
    emit(state.copyWith(isBusy: true, clearFeedback: true));

    try {
      await repo.unlock(e.secret);
      emit(state.copyWith(status: VaultStatus.unlocked, isBusy: false));
      _project(emit);
    } on VaultLockedOut catch (l) {
      emit(
        state.copyWith(
          isBusy: false,
          feedback: VaultFeedback.error(
            'تلاش‌های اشتباه زیاد بود. '
            '${l.remaining.inSeconds} ثانیه‌ی دیگر دوباره امتحان کن',
          ),
        ),
      );
    } on VaultWrongSecret catch (w) {
      emit(
        state.copyWith(
          isBusy: false,
          feedback: VaultFeedback.error(
            'رمز اشتباه است. ${w.triesLeft} تلاش تا قفل موقت',
          ),
        ),
      );
    } catch (err) {
      // رمز درست بود ولی دانلود اولیه شکست خورد؛ قفل باز می‌ماند.
      if (repo.isUnlocked) {
        emit(state.copyWith(status: VaultStatus.unlocked, isBusy: false));
        _project(emit);
      }

      emit(
        state.copyWith(isBusy: false, feedback: VaultFeedback.error(_msg(err))),
      );
    }
  }

  void _onLock(VaultLocked e, Emitter<VaultState> emit) {
    repo.lock();

    emit(
      state.copyWith(
        status: VaultStatus.locked,
        entries: const [],
        counts: const {},
        query: '',
        clearCategory: true,
        clearRecoveryKey: true,
        clearFeedback: true,
      ),
    );
  }

  Future<void> _onRefreshed(VaultRefreshed e, Emitter<VaultState> emit) async {
    try {
      final r = await repo.sync();
      emit(state.copyWith(feedback: VaultFeedback.success(r.message)));
    } catch (err) {
      emit(state.copyWith(feedback: VaultFeedback.error(_msg(err))));
    } finally {
      if (e.done != null && !e.done!.isCompleted) e.done!.complete();
    }
  }

  Future<void> _onSaved(VaultItemSaved e, Emitter<VaultState> emit) async {
    emit(state.copyWith(isBusy: true, clearFeedback: true));

    try {
      final id = await repo.save(
        id: e.id,
        category: e.category,
        plain: e.plain,
      );

      for (final a in e.removedAttachmentIds) {
        await repo.removeAttachment(id, a);
      }

      final failed = <String>[];

      for (final f in e.newFiles) {
        try {
          await repo.addAttachment(id, f.name, f.bytes);
        } on VaultApiException catch (x) {
          failed.add(x.message);
        }
      }

      emit(
        state.copyWith(
          isBusy: false,
          feedback: failed.isEmpty
              ? VaultFeedback.success('ذخیره شد')
              : VaultFeedback.error('ذخیره شد، ولی: ${failed.join('؛ ')}'),
        ),
      );
    } catch (err) {
      emit(
        state.copyWith(isBusy: false, feedback: VaultFeedback.error(_msg(err))),
      );
    }
  }

  Future<void> _onDeleted(VaultItemDeleted e, Emitter<VaultState> emit) async {
    emit(state.copyWith(clearFeedback: true));

    try {
      await repo.delete(e.id);
      emit(state.copyWith(feedback: VaultFeedback.success('حذف شد')));
    } catch (err) {
      emit(state.copyWith(feedback: VaultFeedback.error(_msg(err))));
    }
  }

  Future<void> _onReset(VaultResetRequested e, Emitter<VaultState> emit) async {
    emit(state.copyWith(isBusy: true, clearFeedback: true));

    try {
      await repo.reset(e.accountPassword);

      emit(
        state.copyWith(
          status: VaultStatus.needsSetup,
          isBusy: false,
          entries: const [],
          counts: const {},
          clearCategory: true,
          clearRecoveryKey: true,
          feedback: VaultFeedback.success(
            'گاوصندوق بازنشانی شد. می‌توانی رمز تازه بسازی',
          ),
        ),
      );
    } catch (err) {
      emit(
        state.copyWith(isBusy: false, feedback: VaultFeedback.error(_msg(err))),
      );
    }
  }

  Future<void> _onRecover(
    VaultRecoverSubmitted e,
    Emitter<VaultState> emit,
  ) async {
    emit(state.copyWith(isBusy: true, clearFeedback: true));

    try {
      final key = await repo.recover(
        e.recoveryKey,
        e.newPass,
        e.accountPassword,
      );

      emit(
        state.copyWith(
          status: VaultStatus.unlocked,
          isBusy: false,
          newRecoveryKey: key,
          feedback: VaultFeedback.success('گاوصندوق باز شد و رمز جدید ثبت شد'),
        ),
      );

      _project(emit);
    } catch (err) {
      emit(
        state.copyWith(isBusy: false, feedback: VaultFeedback.error(_msg(err))),
      );
    }
  }

  Future<void> _onChangePass(
    VaultPassphraseChangeSubmitted e,
    Emitter<VaultState> emit,
  ) async {
    emit(state.copyWith(isBusy: true, clearFeedback: true));

    try {
      await repo.changePassphrase(e.oldPass, e.newPass, e.accountPassword);

      emit(
        state.copyWith(
          isBusy: false,
          feedback: VaultFeedback.success('رمز گاوصندوق تغییر کرد'),
        ),
      );
    } catch (err) {
      emit(
        state.copyWith(isBusy: false, feedback: VaultFeedback.error(_msg(err))),
      );
    }
  }

  Future<void> _onRegen(
    VaultRecoveryRegenerated e,
    Emitter<VaultState> emit,
  ) async {
    emit(state.copyWith(isBusy: true, clearFeedback: true));

    try {
      final key = await repo.regenerateRecovery(e.accountPassword);

      emit(state.copyWith(isBusy: false, newRecoveryKey: key));
    } catch (err) {
      emit(
        state.copyWith(isBusy: false, feedback: VaultFeedback.error(_msg(err))),
      );
    }
  }

  Future<void> _onRepoChanged(
    VaultRepoChanged e,
    Emitter<VaultState> emit,
  ) async {
    if (state.status != VaultStatus.unlocked) return;

    if (!repo.isUnlocked) {
      // مثلاً بازنشانی از دستگاه دیگر
      emit(
        state.copyWith(
          status: VaultStatus.loading,
          entries: const [],
          counts: const {},
          clearRecoveryKey: true,
        ),
      );
      add(const VaultStarted());
      return;
    }

    _project(emit);
  }

  @override
  Future<void> close() {
    repo.removeListener(_listener);
    repo.syncing.removeListener(_listener);
    repo.lock(); // خروج از صفحه = قفل شدن
    return super.close();
  }
}
