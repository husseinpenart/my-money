import 'package:flutter/material.dart';
import 'package:money/feature/model/DebtReceviable/cover_image.dart';
import 'package:money/widgets/DebtReceviable/cover_image_view.dart';
import 'package:money/widgets/DebtReceviable/cover_viewer.dart';
import 'package:money/widgets/contact/contact_style.dart';


class CoverGalleryField extends StatefulWidget {
  final CoverController controller;
  const CoverGalleryField({super.key, required this.controller});

  @override
  State<CoverGalleryField> createState() => _CoverGalleryFieldState();
}

class _CoverGalleryFieldState extends State<CoverGalleryField> {
  String? _note;

  Future<void> _add() async {
    final msg = await widget.controller.pickAndAdd();
    if (mounted) setState(() => _note = msg);
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<CoverImage>>(
      valueListenable: widget.controller,
      builder: (context, list, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('تصاویر و مدارک',
                    style: sans(size: 12, color: Colors.grey[500])),
                const Spacer(),
                Text('${list.length}/${CoverController.maxImages}',
                    style: sans(size: 11, color: Colors.grey[500])),
              ],
            ),
            const SizedBox(height: 10),
            if (list.isEmpty)
              _EmptyBox(onTap: _add)
            else
              SizedBox(
                height: 88,
                child: Row(
                  children: [
                    _AddTile(onTap: _add),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ReorderableListView.builder(
                        scrollDirection: Axis.horizontal,
                        buildDefaultDragHandles: false,
                        itemCount: list.length,
                        onReorder: widget.controller.move,
                        itemBuilder: (context, i) {
                          final img = list[i];
                          return ReorderableDelayedDragStartListener(
                            key: ValueKey(img.id),
                            index: i,
                            child: Padding(
                              padding: const EdgeInsetsDirectional.only(end: 8),
                              child: _Thumb(
                                image: img,
                                index: i,
                                onOpen: () => showCoverViewer(
                                  context,
                                  controller: widget.controller,
                                  initialIndex: i,
                                ),
                                onRemove: () => widget.controller.remove(img.id),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            if (list.length > 1) ...[
              const SizedBox(height: 6),
              Text('برای تغییر ترتیب، تصویر را نگه دار و بکش',
                  style: sans(size: 10, color: Colors.grey.shade500)),
            ],
            if (_note != null) ...[
              const SizedBox(height: 6),
              Text(_note!, style: sans(size: 11, color: Colors.orange.shade800)),
            ],
          ],
        );
      },
    );
  }
}

class _EmptyBox extends StatelessWidget {
  final VoidCallback onTap;
  const _EmptyBox({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 22),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color.fromARGB(255, 211, 205, 205)),
          color: Colors.grey.shade50,
        ),
        child: Column(
          children: [
            const Icon(Icons.add_photo_alternate_outlined,
                size: 30, color: kAccent),
            const SizedBox(height: 6),
            Text('افزودن تصویر (چندتایی)', style: sans(size: 12)),
            Text('JPG ، PNG ، WEBP ، GIF  |  حداکثر ۵ مگابایت',
                style: sans(size: 10, color: Colors.grey.shade500)),
          ],
        ),
      ),
    );
  }
}

class _AddTile extends StatelessWidget {
  final VoidCallback onTap;
  const _AddTile({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 88,
        height: 88,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: kAccent.withValues(alpha: 0.08),
          border: Border.all(color: kAccent.withValues(alpha: 0.4)),
        ),
        child: const Icon(Icons.add, color: kAccent),
      ),
    );
  }
}

class _Thumb extends StatelessWidget {
  final CoverImage image;
  final int index;
  final VoidCallback onOpen;
  final VoidCallback onRemove;
  const _Thumb({
    required this.image,
    required this.index,
    required this.onOpen,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 88,
      height: 88,
      child: Stack(
        fit: StackFit.expand,
        children: [
          GestureDetector(
            onTap: onOpen,
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: CoverImageView(image: image),
              ),
            ),
          ),
          PositionedDirectional(
            top: 4,
            start: 4,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text('${index + 1}',
                  style: sans(size: 10, color: Colors.white)),
            ),
          ),
          PositionedDirectional(
            top: 2,
            end: 2,
            child: InkWell(
              onTap: onRemove,
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.all(3),
                decoration: const BoxDecoration(
                  color: Colors.black54,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close, size: 14, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}