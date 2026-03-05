// lib/customer/views/product/widgets/product_detail/header.dart
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class ProductDetailHeader extends StatelessWidget {
  final VoidCallback? onBack;
  final VoidCallback? onFavorite;
  final bool isFavorited;

  const ProductDetailHeader({
    super.key,
    this.onBack,
    this.onFavorite,
    this.isFavorited = false,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        height: kToolbarHeight,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Back Button
            _buildIconButton(
              icon: LucideIcons.chevronLeft,
              iconColor: Colors.black,
              onPressed: onBack ?? () => Navigator.pop(context),
            ),
            // Favorite Button
            _buildIconButton(
              icon: isFavorited ? Icons.favorite_rounded : Icons.favorite_border_rounded,
              iconColor: isFavorited ? const Color(0xFFE57373) : Colors.black,
              onPressed: onFavorite ?? () {},
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIconButton({
    required IconData icon,
    required Color iconColor,
    required VoidCallback onPressed,
  }) {
    return Container(
      width: 40,
      height: 40,
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(icon, color: iconColor, size: 20),
        onPressed: onPressed,
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(),
      ),
    );
  }
}