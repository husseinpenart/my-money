/// یک بخش از متن سیاست/قوانین.
///
/// این مدل مستقل از UI است تا هم PolicyContent و هم PolicyBottomSheet
/// از همان یک نوع استفاده کنند.
class PolicySection {
  final String title;
  final String content;

  const PolicySection({required this.title, required this.content});

  /// سازنده‌ی جایگزین برای کدهای قدیمی‌تر که heading/body استفاده می‌کردند.
  const PolicySection.headingBody({
    required String heading,
    required String body,
  }) : title = heading,
       content = body;

  /// Getterهای سازگاری برای کدهایی که هنوز section.heading یا section.body می‌خوانند.
  String get heading => title;
  String get body => content;
}
