import 'package:flutter/material.dart';

class AppLogo extends StatelessWidget {
  final double size;

  const AppLogo({super.key, this.size = 120});

  @override
  Widget build(BuildContext context) {
    // TODO: Add logo images to assets/logos/ folder
    // Expected files: logo-light.png (for light mode) and logo-dark.png (for dark mode)
    // Until then, using icon fallback
    return Icon(
      Icons.waves,
      size: size,
      color: Theme.of(context).colorScheme.primary,
    );
  }
}
