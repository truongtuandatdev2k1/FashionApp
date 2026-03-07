// lib/customer/views/home/widgets/utility_access_bar.dart

import 'package:flutter/material.dart';
import 'package:ui_mobile_fashion_app/core/config/app_config.dart';
import 'package:ui_mobile_fashion_app/customer/logic/brand/brand_api.dart';
import 'package:ui_mobile_fashion_app/customer/models/brand_model.dart';
import 'package:ui_mobile_fashion_app/customer/views/product/product_list_screen.dart';

/// Widget hiển thị danh sách brand từ API (dạng thanh cuộn ngang)
class UtilityAccessBar extends StatefulWidget {
  const UtilityAccessBar({super.key});

  @override
  State<UtilityAccessBar> createState() => _UtilityAccessBarState();
}

class _UtilityAccessBarState extends State<UtilityAccessBar> {
  final BrandApi _brandApi = BrandApi();

  late Future<List<BrandModel>> _brandsFuture;

  @override
  void initState() {
    super.initState();
    _brandsFuture = _brandApi.getBrands();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Thương hiệu',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 14),
          FutureBuilder<List<BrandModel>>(
            future: _brandsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SizedBox(
                  height: 80,
                  child: Center(
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                );
              }

              if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
                return const SizedBox.shrink();
              }

              final brands = snapshot.data!;

              return SizedBox(
                height: 80,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: brands.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (context, index) {
                    return _BrandItem(brand: brands[index]);
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _BrandItem extends StatelessWidget {
  final BrandModel brand;

  const _BrandItem({required this.brand});

  @override
  Widget build(BuildContext context) {
    final imageUrl = '${AppConfig.imageBaseUrl}${brand.logoUrl}';

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProductListScreen(
              title: brand.name,
              filter: 'all',
              brandId: brand.id,
            ),
          ),
        );
      },
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            padding: const EdgeInsets.all(6),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                imageUrl,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => const Icon(
                  Icons.image_not_supported_outlined,
                  size: 20,
                  color: Colors.grey,
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),
          SizedBox(
            width: 60,
            child: Text(
              brand.name,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}