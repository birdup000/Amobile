import 'package:flutter/material.dart';
import '../utils/gravatar.dart';

class GravatarImage extends StatelessWidget {
  final String email;
  final double size;
  final BoxShape shape;
  final BorderRadius? borderRadius;

  const GravatarImage({
    super.key,
    required this.email,
    this.size = 40,
    this.shape = BoxShape.circle,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: shape,
        borderRadius: shape == BoxShape.rectangle
            ? (borderRadius ?? BorderRadius.circular(8))
            : null,
        image: DecorationImage(
          image: NetworkImage(
            GravatarUtils.getGravatarUrl(
              email,
              size: (size * MediaQuery.of(context).devicePixelRatio).round(),
              defaultImage: 'identicon', // Use identicon as fallback
            ),
          ),
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
