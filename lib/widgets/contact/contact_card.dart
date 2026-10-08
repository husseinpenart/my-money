import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:money/feature/model/contact/contact_model.dart';
import 'package:money/feature/model/search_models/search_models.dart';
import 'package:money/helper/utils/input_utils.dart';
import 'package:money/widgets/contact/contact_style.dart';


class ContactCard extends StatefulWidget {
  final ContactModel contact;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const ContactCard({
    super.key,
    required this.contact,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  State<ContactCard> createState() => _ContactCardState();
}

class _ContactCardState extends State<ContactCard> {
  bool _expanded = false;

  static const _palette = [
    Colors.purple,
    Colors.teal,
    Colors.indigo,
    Colors.orange,
    Colors.pink,
    Colors.blueGrey,
    Colors.green,
  ];

  Color get _avatarColor =>
      _palette[widget.contact.contactId.hashCode.abs() % _palette.length];

  @override
  Widget build(BuildContext context) {
    final c = widget.contact;
    final balance = c.balance;
    final amountColor = c.unpaidCount == 0
        ? Colors.grey
        : (balance >= 0 ? Colors.green : Colors.red.shade400);

    final (chipText, chipBg, chipFg) = _chip(c);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            blurRadius: 10,
            color: Colors.black.withValues(alpha: 0.1),
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  color: _avatarColor,
                ),
                child: Center(
                  child: Text(
                    c.name.isEmpty ? '?' : c.name.characters.first,
                    style: sans(size: 15, color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      c.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: sans(size: 14, weight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      c.phoneNumber,
                      style: sans(size: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    c.unpaidCount == 0 ? '—' : formatAmount(balance),
                    style: sans(
                      size: 14,
                      weight: FontWeight.bold,
                      color: amountColor,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                    decoration: BoxDecoration(
                      color: chipBg,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Text(chipText, style: sans(size: 11, color: chipFg)),
                  ),
                ],
              ),
              const SizedBox(width: 10),
              InkWell(
                onTap: () => setState(() => _expanded = !_expanded),
                borderRadius: BorderRadius.circular(100),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: Color(0xFFEEF2FF),
                    shape: BoxShape.circle,
                  ),
                  child: Transform.rotate(
                    angle: _expanded ? (90 * math.pi / 180) : 0,
                    child: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      size: 14,
                      color: Color(0xFFA9AEBC),
                    ),
                  ),
                ),
              ),
            ],
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            alignment: Alignment.topCenter,
            child: _expanded
                ? _ExpandedSection(
                    contact: c,
                    onEdit: widget.onEdit,
                    onDelete: widget.onDelete,
                  )
                : const SizedBox(width: double.infinity),
          ),
        ],
      ),
    );
  }

  (String, Color, Color) _chip(ContactModel c) {
    if (c.debts.isEmpty) {
      return ('بدون سابقه', Colors.grey.shade200, Colors.grey.shade700);
    }
    if (c.unpaidCount == 0) {
      return ('تسویه‌شده', Colors.green.shade50, Colors.green.shade700);
    }
    return c.balance >= 0
        ? ('طلبکار', Colors.green.shade50, Colors.green.shade700)
        : ('بدهکار', Colors.red.shade50, Colors.red.shade400);
  }
}

class _ExpandedSection extends StatelessWidget {
  final ContactModel contact;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ExpandedSection({
    required this.contact,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color.fromRGBO(236, 236, 238, 0.345),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        children: [
          if (contact.debts.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                'بدهی یا طلبی برای این مخاطب ثبت نشده است',
                style: sans(size: 12, color: Colors.grey.shade600),
              ),
            )
          else
            for (final d in contact.debts) _DebtRow(debt: d),
          const Divider(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              TextButton.icon(
                onPressed: onEdit,
                icon: const Icon(Icons.edit_outlined, size: 18, color: kAccent),
                label: Text('ویرایش', style: sans(size: 12, color: kAccent)),
              ),
              TextButton.icon(
                onPressed: onDelete,
                icon: Icon(Icons.delete_outline,
                    size: 18, color: Colors.red.shade400),
                label: Text('حذف',
                    style: sans(size: 12, color: Colors.red.shade400)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DebtRow extends StatelessWidget {
  final SearchDebt debt;
  const _DebtRow({required this.debt});

  @override
  Widget build(BuildContext context) {
    final color = debt.isDebt ? Colors.red.shade400 : Colors.green.shade600;
    final desc = (debt.description ?? '').trim();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Icon(
            debt.isDebt ? Icons.arrow_upward : Icons.arrow_downward,
            size: 16,
            color: color,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              desc.isEmpty ? (debt.isDebt ? 'بدهی' : 'طلب') : desc,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: sans(size: 12),
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                amountText(debt.wholePrice),
                style: sans(size: 12, weight: FontWeight.bold, color: color),
              ),
              Text(
                debt.payStatus ? 'پرداخت‌شده' : 'پرداخت‌نشده',
                style: sans(
                  size: 10,
                  color: debt.payStatus
                      ? Colors.green.shade600
                      : Colors.orange.shade700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}