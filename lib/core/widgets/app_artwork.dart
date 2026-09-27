import 'package:flutter/material.dart';

class AppArtwork extends StatelessWidget {
  const AppArtwork({super.key, required this.asset, required this.height});
  static const opening = 'assets/clay/shield.png';
  static const search = 'assets/clay/search.png';
  static const splash = 'assets/ımage/splash.png';
  final String asset;
  final double height;

  @override
  Widget build(BuildContext context) {
    final image = Image.asset(
      asset,
      height: height,
      fit: BoxFit.contain,
      filterQuality: FilterQuality.medium,
      excludeFromSemantics: true,
    );
    if (asset == splash) return image;
    return Center(
      child: SizedBox.square(
        dimension: height,
        child: ShaderMask(
          blendMode: BlendMode.dstIn,
          shaderCallback: (bounds) => const RadialGradient(
            colors: [Colors.white, Colors.white, Colors.transparent],
            stops: [0, .72, 1],
            radius: .65,
          ).createShader(bounds),
          child: image,
        ),
      ),
    );
  }
}
