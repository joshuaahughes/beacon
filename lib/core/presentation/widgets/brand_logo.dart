import 'package:flutter/material.dart';

class BrandLogo extends StatelessWidget {
  final double size;
  final bool circular;

  const BrandLogo({
    super.key,
    this.size = 100,
    this.circular = true,
  });

  @override
  Widget build(BuildContext context) {
    Widget image = Image.asset(
      'assets/brand/icon.png',
      width: size,
      height: size,
      fit: BoxFit.contain,
    );

    if (circular) {
      return Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
        child: ClipOval(child: image),
      );
    }

    return image;
  }
}
