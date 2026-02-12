import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/fusion_entry.dart';
import '../../../providers/fusion_pedia_provider.dart';
import '../../../providers/game_provider.dart';
import 'fusion_summary_modal.dart';
import 'fusion_dialog_layer_guard.dart';
import '../../../core/network/fusion_image_proxy.dart';

class PediaFusionTile extends StatefulWidget {
  final FusionEntry fusion;

  const PediaFusionTile({
    super.key,
    required this.fusion,
  });

  @override
  State<PediaFusionTile> createState() => _PediaFusionTileState();
}

class _PediaFusionTileState extends State<PediaFusionTile> {
  Widget _imageUnavailable() {
    return const Center(
      child: Icon(
        Icons.broken_image_outlined,
        color: Colors.white54,
        size: 28,
      ),
    );
  }

  Widget _networkImage({
    required String url,
    Widget Function()? onError,
  }) {
    return Image.network(
      resolveFusionImageUrl(url),
      fit: BoxFit.contain,
      webHtmlElementStrategy: WebHtmlElementStrategy.prefer,
      errorBuilder: (_, _, _) => onError == null ? _imageUnavailable() : onError(),
    );
  }

  Widget _fusionImage() {
    final secondary = _networkImage(
      url: widget.fusion.autoGenFusionUrl,
      onError: _imageUnavailable,
    );
    return _networkImage(
      url: widget.fusion.customFusionUrl,
      onError: () => secondary,
    );
  }

  @override
  Widget build(BuildContext context) {
    final fusion = widget.fusion;
    final isPending = fusion.claimPending;
    return GestureDetector(
      onTap: () async {
        if (FusionDialogLayerGuard.isDialogOpen.value) return;
        FusionDialogLayerGuard.isDialogOpen.value = true;
        await showDialog(
          context: context,
          builder: (_) => FusionSummaryModal(fusion: fusion),
        );
        FusionDialogLayerGuard.isDialogOpen.value = false;
      },
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF111C33), Color(0xFF182647)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: const Color(0xFF00D1FF).withOpacity(0.35),
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF00D1FF).withOpacity(0.12),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(4),
              child: ValueListenableBuilder<bool>(
                valueListenable: FusionDialogLayerGuard.isDialogOpen,
                builder: (_, dialogOpen, __) {
                  if (dialogOpen) return const SizedBox.expand();
                  return _fusionImage();
                },
              ),
            ),
            if (isPending)
              const Positioned(
                top: 6,
                right: 6,
                child: SizedBox(
                  width: 8,
                  height: 8,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: Color(0xFFFF2D95),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
            if (isPending)
              Positioned(
                left: 6,
                right: 6,
                bottom: 4,
                child: ElevatedButton(
                  onPressed: () {
                    final pedia =
                        context.read<FusionPediaProvider>();
                    final game = context.read<GameProvider>();

                    if (pedia.claimFusion(fusion)) {
                      game.addDiamonds(1);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF2D95),
                    foregroundColor: Colors.white,
                    padding:
                        const EdgeInsets.symmetric(vertical: 2),
                    minimumSize: const Size(0, 24),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    textStyle: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  child: const Text('Reclamar'),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
