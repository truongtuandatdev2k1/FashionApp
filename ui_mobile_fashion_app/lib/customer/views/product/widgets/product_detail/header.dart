// lib/customer/views/product/widgets/product_detail/header.dart
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class ProductDetailHeader extends StatelessWidget {
  final VoidCallback? onBack;
  final VoidCallback? onFavorite;

  const ProductDetailHeader({
    super.key,
    this.onBack,
    this.onFavorite,
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
              onPressed: onBack ?? () => Navigator.pop(context),
            ),
            // Favorite Button
            _buildIconButton(
              icon: LucideIcons.heart,
              onPressed: onFavorite ?? () {},
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIconButton({
    required IconData icon,
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
        icon: Icon(icon, color: Colors.black, size: 20),
        onPressed: onPressed,
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(),
      ),
    );
  }
}