import 'package:flutter/material.dart';

class IllustrationSlot extends StatelessWidget {
  const IllustrationSlot({
    super.key,
    required this.width,
    required this.height,
    this.imagePath,
    this.shape = BoxShape.rectangle,
    this.borderRadius = 16.0,
    this.opacity = 1.0,
    this.fit = BoxFit.cover,
    this.placeholderIcon = Icons.image_outlined,
    this.placeholderLabel = 'Illustration',
    this.onLight = false,
  });

  final double width;
  final double height;
  final String? imagePath;
  final BoxShape shape;
  final double borderRadius;
  final double opacity;
  final BoxFit fit;
  final IconData placeholderIcon;
  final String placeholderLabel;
  final bool onLight;

  @override
  Widget build(BuildContext context) {
    final radius = shape == BoxShape.circle
        ? BorderRadius.circular(width / 2)
        : BorderRadius.circular(borderRadius);

    if (imagePath != null && imagePath!.isNotEmpty) {
      return Opacity(
        opacity: opacity,
        child: ClipRRect(
          borderRadius: radius,
          child: Image.asset(
            imagePath!,
            width: width,
            height: height,
            fit: fit,
          ),
        ),
      );
    }

    final fg = onLight ? Colors.black : Colors.white;
    final bg = fg.withValues(alpha: onLight ? 0.04 : 0.10);
    final border = fg.withValues(alpha: onLight ? 0.12 : 0.28);
    final iconColor = fg.withValues(alpha: onLight ? 0.25 : 0.45);
    final labelColor = fg.withValues(alpha: onLight ? 0.45 : 0.60);

    return Opacity(
      opacity: opacity,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: bg,
          shape: shape,
          borderRadius: shape == BoxShape.rectangle ? radius : null,
          border: Border.all(color: border, width: 1.2),
        ),
        alignment: Alignment.center,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              placeholderIcon,
              size: width * 0.28,
              color: iconColor,
            ),
            SizedBox(height: width * 0.04),
            Text(
              placeholderLabel,
              style: TextStyle(
                fontSize: 10.0,
                letterSpacing: 1.5,
                color: labelColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
