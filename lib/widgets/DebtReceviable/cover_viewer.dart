import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:money/feature/model/DebtReceviable/cover_image.dart';
import 'package:money/widgets/DebtReceviable/cover_image_view.dart';
import 'package:money/widgets/contact/contact_style.dart';


Future<void> showCoverViewer(
  BuildContext context, {
  required CoverController controller,
  int initialIndex = 0,
  bool editable = true,
}) {
  return Navigator.of(context, rootNavigator: true).push(
    MaterialPageRoute<void>(
      fullscreenDialog: true,
      builder: (_) => CoverViewerPage(
        controller: controller,
        initialIndex: initialIndex,
        editable: editable,
      ),
    ),
  );
}

class CoverViewerPage extends StatefulWidget {
  final CoverController controller;
  final int initialIndex;
  final bool editable;

  const CoverViewerPage({
    super.key,
    required this.controller,
    this.initialIndex = 0,
    this.editable = true,
  });

  @override
  State<CoverViewerPage> createState() => _CoverViewerPageState();
}

class _CoverViewerPageState extends State<CoverViewerPage> {
  static const double _maxScale = 8;

  late final PageController _page;
  final Map<String, TransformationController> _tcs = {};
  final FocusNode _focus = FocusNode();

  int _index = 0;
  bool _zoomed = false;
  Size _viewport = Size.zero;
  Offset _tapPos = Offset.zero;

  CoverController get _c => widget.controller;

  TransformationController _tc(String id) =>
      _tcs.putIfAbsent(id, () => TransformationController());

  @override
  void initState() {
    super.initState();
    _index = widget.initialIndex.clamp(0, math.max(0, _c.value.length - 1));
    _page = PageController(initialPage: _index);
    _c.addListener(_onListChanged);
  }

  @override
  void dispose() {
    _c.removeListener(_onListChanged);
    for (final t in _tcs.values) {
      t.dispose();
    }
    _page.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _onListChanged() {
    final ids = _c.value.map((e) => e.id).toSet();
    final stale = _tcs.keys.where((k) => !ids.contains(k)).toList();
    for (final k in stale) {
      _tcs.remove(k)?.dispose();
    }

    if (_c.value.isEmpty) {
      if (mounted) Navigator.of(context).maybePop();
      return;
    }
    if (_index >= _c.value.length) {
      _index = _c.value.length - 1;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_page.hasClients) _page.jumpToPage(_index);
      });
    }
  }

  // ───────── زوم ─────────
  void _syncZoom(TransformationController tc) {
    final z = tc.value.getMaxScaleOnAxis() > 1.01;
    if (z != _zoomed) setState(() => _zoomed = z);
  }

  void _toggleZoom(TransformationController tc) {
    if (tc.value.getMaxScaleOnAxis() > 1.01) {
      tc.value = Matrix4.identity();
    } else {
      const s = 3.0;
      final tx = (-_tapPos.dx * (s - 1))
          .clamp(_viewport.width * (1 - s), 0.0)
          .toDouble();
      final ty = (-_tapPos.dy * (s - 1))
          .clamp(_viewport.height * (1 - s), 0.0)
          .toDouble();
      tc.value = Matrix4.identity()
        ..setEntry(0, 0, s)
        ..setEntry(1, 1, s)
        ..setEntry(0, 3, tx)
        ..setEntry(1, 3, ty);
    }
    _syncZoom(tc);
  }

  void _zoomBy(double factor) {
    final list = _c.value;
    if (list.isEmpty) return;
    final tc = _tc(list[_index.clamp(0, list.length - 1)].id);

    final cur = tc.value.getMaxScaleOnAxis();
    final target = (cur * factor).clamp(1.0, _maxScale).toDouble();
    if (target <= 1.01) {
      tc.value = Matrix4.identity();
    } else {
      final k = target / cur;
      final cx = _viewport.width / 2, cy = _viewport.height / 2;
      final m = Matrix4.identity()
        ..setEntry(0, 0, k)
        ..setEntry(1, 1, k)
        ..setEntry(0, 3, cx * (1 - k))
        ..setEntry(1, 3, cy * (1 - k));
      tc.value = m * tc.value;
    }
    _syncZoom(tc);
  }

  void _reset() {
    final list = _c.value;
    if (list.isEmpty) return;
    final tc = _tc(list[_index.clamp(0, list.length - 1)].id);
    tc.value = Matrix4.identity();
    _syncZoom(tc);
  }

  // ───────── ناوبری ─────────
  void _goTo(int i) {
    final n = _c.value.length;
    if (i < 0 || i >= n) return;
    _page.animateToPage(
      i,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
    );
  }

  void _onPageChanged(int i) {
    final list = _c.value;
    if (_index < list.length) {
      _tcs[list[_index].id]?.value = Matrix4.identity();
    }
    setState(() {
      _index = i;
      _zoomed = false;
    });
  }

  KeyEventResult _onKey(FocusNode node, KeyEvent e) {
    if (e is! KeyDownEvent && e is! KeyRepeatEvent)
      return KeyEventResult.ignored;
    final k = e.logicalKey;
    final rtl = Directionality.of(context) == TextDirection.rtl;

    if (k == LogicalKeyboardKey.escape) {
      Navigator.of(context).maybePop();
    } else if (k == LogicalKeyboardKey.arrowRight) {
      _goTo(_index + (rtl ? -1 : 1));
    } else if (k == LogicalKeyboardKey.arrowLeft) {
      _goTo(_index + (rtl ? 1 : -1));
    } else if (k == LogicalKeyboardKey.equal ||
        k == LogicalKeyboardKey.add ||
        k == LogicalKeyboardKey.numpadAdd) {
      _zoomBy(1.5);
    } else if (k == LogicalKeyboardKey.minus ||
        k == LogicalKeyboardKey.numpadSubtract) {
      _zoomBy(1 / 1.5);
    } else if (k == LogicalKeyboardKey.digit0 ||
        k == LogicalKeyboardKey.numpad0) {
      _reset();
    } else {
      return KeyEventResult.ignored;
    }
    return KeyEventResult.handled;
  }

  // ───────── عملیات ─────────
  Future<void> _add() async {
    final before = _c.value.length;
    final msg = await _c.pickAndAdd();
    if (!mounted) return;
    if (msg != null) _snack(msg);
    if (_c.value.length > before) _goTo(_c.value.length - 1);
  }

  Future<void> _replace(CoverImage cur) async {
    final msg = await _c.pickAndReplace(cur.id);
    if (mounted && msg != null) _snack(msg);
  }

  Future<void> _delete(CoverImage cur) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          'حذف تصویر',
          style: sans(size: 15, weight: FontWeight.bold),
        ),
        content: Text('این تصویر از لیست حذف شود؟', style: sans(size: 13)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('انصراف', style: sans(size: 13)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              'حذف',
              style: sans(size: 13, color: Colors.red.shade400),
            ),
          ),
        ],
      ),
    );
    if (ok == true) _c.remove(cur.id);
  }

  void _snack(String m) => ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(m, style: sans(size: 12, color: Colors.white)),
      ),
    );

  // ───────── UI ─────────
  @override
  Widget build(BuildContext context) {
    return Focus(
      focusNode: _focus,
      autofocus: true,
      onKeyEvent: _onKey,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          child: ValueListenableBuilder<List<CoverImage>>(
            valueListenable: _c,
            builder: (context, list, _) {
              if (list.isEmpty) return const SizedBox.shrink();
              final i = _index.clamp(0, list.length - 1);
              final cur = list[i];

              return Column(
                children: [
                  _topBar(cur, i, list.length),
                  Expanded(
                    child: Stack(
                      children: [
                        LayoutBuilder(
                          builder: (context, cons) {
                            _viewport = cons.biggest;
                            return PageView.builder(
                              controller: _page,
                              physics: _zoomed
                                  ? const NeverScrollableScrollPhysics()
                                  : const PageScrollPhysics(),
                              itemCount: list.length,
                              onPageChanged: _onPageChanged,
                              itemBuilder: (context, idx) {
                                final img = list[idx];
                                final tc = _tc(img.id);
                                return GestureDetector(
                                  onDoubleTapDown: (d) =>
                                      _tapPos = d.localPosition,
                                  onDoubleTap: () => _toggleZoom(tc),
                                  child: InteractiveViewer(
                                    transformationController: tc,
                                    minScale: 1,
                                    maxScale: _maxScale,
                                    onInteractionEnd: (_) => _syncZoom(tc),
                                    child: SizedBox.expand(
                                      child: CoverImageView(
                                        image: img,
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                        if (list.length > 1) ...[
                          if (i > 0)
                            PositionedDirectional(
                              start: 8,
                              top: 0,
                              bottom: 0,
                              child: _NavButton(
                                icon: Icons.arrow_back_ios_new_rounded,
                                onTap: () => _goTo(i - 1),
                              ),
                            ),
                          if (i < list.length - 1)
                            PositionedDirectional(
                              end: 8,
                              top: 0,
                              bottom: 0,
                              child: _NavButton(
                                icon: Icons.arrow_forward_ios_rounded,
                                onTap: () => _goTo(i + 1),
                              ),
                            ),
                        ],
                      ],
                    ),
                  ),
                  if (list.length > 1) _thumbs(list, i),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _topBar(CoverImage cur, int i, int n) {
    final name = cur.name.isNotEmpty
        ? cur.name
        : (cur.url ?? '').split('/').last;

    Widget btn(IconData icon, String tip, VoidCallback onTap) => IconButton(
      tooltip: tip,
      onPressed: onTap,
      icon: Icon(icon, color: Colors.white, size: 22),
    );

    return Container(
      color: Colors.black87,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        children: [
          btn(Icons.close, 'بستن', () => Navigator.of(context).maybePop()),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: sans(size: 12, color: Colors.white),
                ),
                Text(
                  '${i + 1} / $n',
                  style: sans(size: 11, color: Colors.white60),
                ),
              ],
            ),
          ),
          btn(Icons.zoom_out, 'کوچک‌نمایی  ( - )', () => _zoomBy(1 / 1.5)),
          btn(Icons.zoom_in, 'بزرگ‌نمایی  ( + )', () => _zoomBy(1.5)),
          btn(Icons.fit_screen_outlined, 'اندازه‌ی اصلی  ( 0 )', _reset),
          if (widget.editable) ...[
            btn(Icons.add_photo_alternate_outlined, 'افزودن تصویر', _add),
            btn(Icons.swap_horiz, 'جایگزینی این تصویر', () => _replace(cur)),
            btn(Icons.delete_outline, 'حذف', () => _delete(cur)),
          ],
        ],
      ),
    );
  }

  Widget _thumbs(List<CoverImage> list, int selected) {
    return Container(
      height: 72,
      color: Colors.black87,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.all(8),
        itemCount: list.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, i) => GestureDetector(
          onTap: () => _goTo(i),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: 56,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: i == selected ? kAccent : Colors.transparent,
                width: 2,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: CoverImageView(image: list[i]),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _NavButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) => Center(
    child: Material(
      color: Colors.black45,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Icon(icon, color: Colors.white, size: 18),
        ),
      ),
    ),
  );
}
