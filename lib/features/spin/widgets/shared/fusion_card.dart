import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../models/pokemon.dart';
import '../../../../providers/pokedex_provider.dart';
import '../../../../core/constants/pokedex_constants.dart';
import '../../../../core/network/fusion_image_proxy.dart';

class FusionCard extends StatelessWidget {
  final Pokemon p1;
  final Pokemon p2;
  final String autoGenUrl;
  final BallType ball;
  final FusionModifier? modifier;

  const FusionCard({
    super.key,
    required this.p1,
    required this.p2,
    required this.autoGenUrl,
    required this.ball,
    required this.modifier,
  });

  /// --------------------------------------------------
  /// PROBABILITY FORMAT: "1 in N" (ROUNDED)
  /// --------------------------------------------------
  String _formatOneIn(double probability) {
    if (probability <= 0) return '∞';

    final raw = 1 / probability;
    final magnitude = pow(10, (log(raw) / ln10).floor());
    final rounded = (raw / magnitude).round() * magnitude;

    return '1 in ${rounded.toInt()}';
  }

  String _fusionName() {
    final half1 = (p1.name.length / 2).ceil();
    final half2 = (p2.name.length / 2).ceil();
    return (p1.name.substring(0, half1) +
            p2.name.substring(p2.name.length - half2))
        .toUpperCase();
  }

  Widget _imageUnavailable(double width) {
    return SizedBox(
      width: width,
      height: width,
      child: const Icon(
        Icons.broken_image_outlined,
        color: Colors.white54,
        size: 42,
      ),
    );
  }

  Widget _networkImage({
    required String url,
    required double width,
    Widget Function()? onError,
  }) {
    return Image.network(
      url,
      width: width,
      webHtmlElementStrategy: WebHtmlElementStrategy.prefer,
      errorBuilder: (_, _, _) =>
          onError == null ? _imageUnavailable(width) : onError(),
    );
  }

  Widget _buildFusionSprite({
    required String primaryUrl,
    required String secondaryUrl,
    required double width,
  }) {
    final primaryProxyUrl = resolveFusionImageUrl(primaryUrl);
    final secondaryProxyUrl = resolveFusionImageUrl(secondaryUrl);

    Widget secondaryDirect = _networkImage(
      url: secondaryUrl,
      width: width,
      onError: () => _imageUnavailable(width),
    );

    Widget secondary = secondaryProxyUrl == secondaryUrl
        ? secondaryDirect
        : _networkImage(
            url: secondaryProxyUrl,
            width: width,
            onError: () => secondaryDirect,
          );

    Widget primaryDirect = _networkImage(
      url: primaryUrl,
      width: width,
      onError: () => secondary,
    );

    return primaryProxyUrl == primaryUrl
        ? primaryDirect
        : _networkImage(
            url: primaryProxyUrl,
            width: width,
            onError: () => primaryDirect,
          );
  }

  @override
  Widget build(BuildContext context) {
    final pokedex = context.read<PokedexProvider>();
    final modifierColor = modifier == null
        ? null
        : fusionModifierColors[modifier!];
    final modifierLabel = modifier == null
        ? null
        : fusionModifierLabels[modifier!];

    final fusionProbability = pokedex.probabilityOfFusion(
      p1: p1,
      p2: p2,
      ball: BallType.poke,
    );

    final customUrl =
        'https://fusioncalc.com/wp-content/themes/twentytwentyone/'
        'pokemon/custom-fusion-sprites-main/CustomBattlers/'
        '${p1.fusionId}.${p2.fusionId}.png';
    return Card(
      elevation: 0,
      color: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF111C33), Color(0xFF182647)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: (modifierColor ?? const Color(0xFF00D1FF))
                .withOpacity(0.45),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: (modifierColor ?? const Color(0xFF00D1FF))
                  .withOpacity(0.25),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
            if (modifierColor != null)
              BoxShadow(
                color: modifierColor.withOpacity(0.35),
                blurRadius: 26,
                spreadRadius: 2,
              ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (modifierColor != null && modifierLabel != null)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: modifierColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: modifierColor.withOpacity(0.85),
                  ),
                ),
                child: Text(
                  modifierLabel.toUpperCase(),
                  style: TextStyle(
                    color: modifierColor,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.1,
                  ),
                ),
              ),
            if (modifierColor != null) const SizedBox(height: 10),
            modifierColor == null
                ? _buildFusionSprite(
                    primaryUrl: customUrl,
                    secondaryUrl: autoGenUrl,
                    width: 160,
                  )
                : ColorFiltered(
                    colorFilter: ColorFilter.mode(
                      modifierColor.withOpacity(0.45),
                      BlendMode.srcATop,
                    ),
                    child: _buildFusionSprite(
                      primaryUrl: customUrl,
                      secondaryUrl: autoGenUrl,
                      width: 160,
                    ),
                  ),
            const SizedBox(height: 12),
            Text(
              _fusionName(),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Rareza de fusión: ${_formatOneIn(fusionProbability)}',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.white70,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
