import 'package:flutter/material.dart';
import 'package:money/feature/model/vault/vault_models.dart';

class VaultField {
  final String key, label;
  final IconData icon;
  final bool secret, numeric, multiline;
  final Map<String, String>? options;
  const VaultField(
    this.key,
    this.label,
    this.icon, {
    this.secret = false,
    this.numeric = false,
    this.multiline = false,
    this.options,
  });
}

const kVaultFields = <VaultCategory, List<VaultField>>{
  VaultCategory.asset: [
    VaultField(
      'kind',
      'نوع دارایی',
      Icons.category_outlined,
      options: {
        'gold': 'طلا',
        'coin': 'سکه',
        'currency': 'ارز',
        'other': 'سایر',
      },
    ),
    VaultField('amount', 'مقدار', Icons.scale_outlined, numeric: true),
    VaultField('unit', 'واحد (گرم، عدد، دلار…)', Icons.straighten_outlined),
    VaultField('purity', 'عیار', Icons.auto_awesome_outlined, numeric: true),
    VaultField('count', 'تعداد', Icons.tag_outlined, numeric: true),
  ],
  VaultCategory.document: [
    VaultField(
      'docType',
      'نوع سند',
      Icons.category_outlined,
      options: {
        'check': 'چک',
        'invoice': 'فاکتور',
        'deed': 'سند و قرارداد',
        'other': 'سایر',
      },
    ),
  ],
  VaultCategory.secret: [
    VaultField(
      'kind',
      'نوع',
      Icons.category_outlined,
      options: {'note': 'یادداشت محرمانه', 'card': 'کارت بانکی'},
    ),
    VaultField('bank', 'بانک', Icons.account_balance_outlined),
    VaultField('holder', 'نام دارنده', Icons.person_outline),
    VaultField(
      'cardNumber',
      'شماره کارت',
      Icons.credit_card,
      secret: true,
      numeric: true,
    ),
    VaultField('expiry', 'تاریخ انقضا', Icons.event_outlined),
    VaultField(
      'secretText',
      'متن محرمانه',
      Icons.key_outlined,
      secret: true,
      multiline: true,
    ),
  ],
};

String vaultSummary(VaultCategory c, VaultPlain p) {
  final f = p.fields;
  String opt(String key) {
    final field = kVaultFields[c]!.firstWhere(
      (x) => x.key == key,
      orElse: () => const VaultField('', '', Icons.circle),
    );
    final v = f[key] ?? '';
    return field.options?[v] ?? v;
  }

  switch (c) {
    case VaultCategory.asset:
      return [
        opt('kind'),
        if ((f['amount'] ?? '').isNotEmpty)
          '${f['amount']} ${f['unit'] ?? ''}'.trim(),
        if ((f['purity'] ?? '').isNotEmpty) 'عیار ${f['purity']}',
        if ((f['count'] ?? '').isNotEmpty) 'تعداد ${f['count']}',
      ].where((s) => s.isNotEmpty).join(' · ');
    case VaultCategory.document:
      return opt('docType');
    case VaultCategory.secret:
      final n = f['cardNumber'] ?? '';
      return [
        opt('kind'),
        if (n.length >= 4) '•••• ${n.substring(n.length - 4)}',
      ].where((s) => s.isNotEmpty).join(' · ');
  }
}
