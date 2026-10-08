import 'package:flutter/material.dart';
import 'package:money/core/network/app_config.dart';
import 'package:money/feature/model/DebtReceviable/cover_image.dart';

class CoverImageView extends StatelessWidget {
  final CoverImage image;
  final BoxFit fit;
  const CoverImageView({
    super.key,
    required this.image,
    this.fit = BoxFit.cover,
  });

  @override
  Widget build(BuildContext context) {
    if (image.bytes != null) {
      return Image.memory(image.bytes!, fit: fit, gaplessPlayback: true);
    }
    return Image.network(
      resolveFileUrl(image.url ?? ''),
      fit: fit,
      loadingBuilder: (context, child, progress) => progress == null
          ? child
          : const Center(
              child: SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
      errorBuilder: (_, __, ___) => Container(
        color: Colors.grey.shade200,
        child: Icon(Icons.broken_image_outlined, color: Colors.grey.shade500),
      ),
    );
  }
}
