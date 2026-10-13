import 'dart:async';

import 'package:money/feature/model/vault/vault_models.dart';

abstract class VaultEvent {
  const VaultEvent();
}

class VaultStarted extends VaultEvent {
  const VaultStarted();
}

class VaultSetupSubmitted extends VaultEvent {
  final String secret;
  const VaultSetupSubmitted(this.secret);
}

class VaultUnlockSubmitted extends VaultEvent {
  final String secret;
  const VaultUnlockSubmitted(this.secret);
}

class VaultLocked extends VaultEvent {
  const VaultLocked();
}

class VaultRefreshed extends VaultEvent {
  final Completer<void>? done;
  const VaultRefreshed({this.done});
}

class VaultQueryChanged extends VaultEvent {
  final String query;
  const VaultQueryChanged(this.query);
}

class VaultCategoryChanged extends VaultEvent {
  final VaultCategory? category;
  const VaultCategoryChanged(this.category);
}

class VaultItemSaved extends VaultEvent {
  final String? id;
  final VaultCategory category;
  final VaultPlain plain;
  final List<VaultNewFile> newFiles;
  final List<String> removedAttachmentIds;

  const VaultItemSaved({
    this.id,
    required this.category,
    required this.plain,
    this.newFiles = const [],
    this.removedAttachmentIds = const [],
  });
}

class VaultItemDeleted extends VaultEvent {
  final String id;
  const VaultItemDeleted(this.id);
}

class VaultResetRequested extends VaultEvent {
  final String accountPassword;
  const VaultResetRequested(this.accountPassword);
}

class VaultRecoverSubmitted extends VaultEvent {
  final String recoveryKey;
  final String newPass;
  final String accountPassword;

  const VaultRecoverSubmitted(
    this.recoveryKey,
    this.newPass,
    this.accountPassword,
  );
}

class VaultPassphraseChangeSubmitted extends VaultEvent {
  final String oldPass;
  final String newPass;
  final String accountPassword;

  const VaultPassphraseChangeSubmitted(
    this.oldPass,
    this.newPass,
    this.accountPassword,
  );
}

class VaultRecoveryRegenerated extends VaultEvent {
  final String accountPassword;
  const VaultRecoveryRegenerated(this.accountPassword);
}

class VaultRecoveryKeyAcknowledged extends VaultEvent {
  const VaultRecoveryKeyAcknowledged();
}

class VaultRepoChanged extends VaultEvent {
  const VaultRepoChanged();
}