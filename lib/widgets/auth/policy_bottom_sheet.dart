import 'package:flutter/material.dart';

/// One heading + body block inside a policy document.
class PolicySection {
  final String heading;
  final String body;

  const PolicySection({required this.heading, required this.body});
}

/// Shows a draggable bottom sheet with a title and a list of [PolicySection]s.
/// Used for both "شرایط استفاده" and "سیاست حریم خصوصی".
class PolicyBottomSheet {
  PolicyBottomSheet._();

  static Future<void> show(
    BuildContext context, {
    required String title,
    required List<PolicySection> sections,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _PolicySheetContent(title: title, sections: sections),
    );
  }
}

class _PolicySheetContent extends StatelessWidget {
  final String title;
  final List<PolicySection> sections;

  const _PolicySheetContent({required this.title, required this.sections});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.65,
      minChildSize: 0.4,
      maxChildSize: 0.92,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          padding: const EdgeInsets.fromLTRB(22, 0, 22, 26),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 5,
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE2E5EC),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(title, style: const TextStyle(fontSize: 16.5, fontWeight: FontWeight.w800)),
                  _CloseButton(onTap: () => Navigator.of(context).pop()),
                ],
              ),
              const SizedBox(height: 14),
              Expanded(
                child: ListView.separated(
                  controller: scrollController,
                  itemCount: sections.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 14),
                  itemBuilder: (context, index) {
                    final section = sections[index];
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(section.heading, style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 6),
                        Text(
                          section.body,
                          style: const TextStyle(fontSize: 13.5, height: 2.0, color: Color(0xFF535A6B), fontWeight: FontWeight.w500),
                        ),
                      ],
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
}

class _CloseButton extends StatelessWidget {
  final VoidCallback onTap;
  const _CloseButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 30,
        height: 30,
        decoration: const BoxDecoration(color: Color(0xFFF0F2F6), shape: BoxShape.circle),
        child: const Icon(Icons.close_rounded, size: 16, color: Color(0xFF6B7280)),
      ),
    );
  }
}
