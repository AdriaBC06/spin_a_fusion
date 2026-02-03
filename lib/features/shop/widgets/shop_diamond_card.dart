import 'package:flutter/material.dart';

class ShopDiamondCard extends StatelessWidget {
  final String title;
  final int? price;
  final bool enabled;
  final bool locked;
  final String? buttonLabel;
  final VoidCallback? onBuy;

  const ShopDiamondCard({
    super.key,
    required this.title,
    this.price,
    this.enabled = false,
    this.locked = false,
    this.buttonLabel,
    this.onBuy,
  });

  @override
  Widget build(BuildContext context) {
    final borderColor =
        locked ? const Color(0xFF4B5A73) : const Color(0xFF00D1FF);
    final glowColor =
        locked ? Colors.black.withOpacity(0.2) : const Color(0xFF00D1FF);
    final titleColor =
        locked ? Colors.white54 : Colors.white;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            locked
                ? const Color(0xFF1A2238)
                : const Color(0xFF0C1A2E),
            locked
                ? const Color(0xFF111826)
                : const Color(0xFF0B1020),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: glowColor.withOpacity(0.25),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (locked)
            const Icon(
              Icons.lock,
              color: Colors.white54,
              size: 28,
            )
          else
            const Icon(
              Icons.auto_awesome,
              color: Color(0xFF7DE7FF),
              size: 28,
            ),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: titleColor,
            ),
          ),
          if (price != null)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.4),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: borderColor.withOpacity(0.6),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.diamond,
                    size: 14,
                    color: Color(0xFF7DE7FF),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    price.toString(),
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            )
          else
            const Text(
              'Próximamente',
              style: TextStyle(
                fontSize: 12,
                color: Colors.white54,
                fontWeight: FontWeight.w600,
              ),
            ),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: enabled ? onBuy : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: locked
                    ? const Color(0xFF2A3345)
                    : const Color(0xFF00D1FF),
                foregroundColor: Colors.black,
                disabledBackgroundColor: const Color(0xFF2A3345),
                disabledForegroundColor: Colors.white54,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(vertical: 6),
                minimumSize: const Size(0, 32),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                locked ? 'Bloqueado' : (buttonLabel ?? 'Comprar'),
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
