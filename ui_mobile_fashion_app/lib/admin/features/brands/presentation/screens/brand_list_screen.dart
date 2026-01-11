// lib/admin/features/brands/presentation/screens/brand_list_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart'; // Đảm bảo đã có import này
import 'package:ui_mobile_fashion_app/admin/features/brands/presentation/widgets/add_brand_dialog.dart';
import '../../data/brand_api.dart';
import '../../data/models/brand_model.dart';

class BrandListScreen extends StatefulWidget {
  const BrandListScreen({super.key});

  @override
  State<BrandListScreen> createState() => _BrandListScreenState();
}

class _BrandListScreenState extends State<BrandListScreen> {
  late Future<BrandListResponse> _brandsFuture;

  @override
  void initState() {
    super.initState();
    _refreshBrands();
  }

  void _refreshBrands() {
    setState(() {
      _brandsFuture = BrandApi.getBrands();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F3F4),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // Header: Tiêu đề và nút thêm mới
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.1,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Quản lý nhãn hàng",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  ElevatedButton.icon(
                    onPressed: () async {
                      final result = await showDialog<bool>(
                        context: context,
                        builder: (context) => const AddBrandDialog(),
                      );
                      if (result == true) {
                        _refreshBrands();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    icon: const Icon(Icons.add),
                    label: const Text("Thêm nhãn hàng"),
                  ),
                ],
              ),
            ),

            // Danh sách nhãn hàng
            Expanded(
              child: FutureBuilder<BrandListResponse>(
                future: _brandsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator(color: Colors.black));
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Lỗi: ${snapshot.error}'));
                  }

                  final brands = snapshot.data?.brands ?? [];

                  if (brands.isEmpty) {
                    return const Center(child: Text("Chưa có nhãn hàng nào"));
                  }

                  return GridView.builder(
                    gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 400,
                      mainAxisExtent: 100,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    itemCount: brands.length,
                    itemBuilder: (context, index) {
                      return _BrandCard(brand: brands[index]);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BrandCard extends StatelessWidget {
  final Brand brand;

  const _BrandCard({required this.brand});

  @override
  Widget build(BuildContext context) {
    return Container(
      // Đổ bóng nhẹ để Card nổi bật trên nền xám của Admin
      decoration: BoxDecoration(
        color: Colors.white, // Nền màu trắng theo yêu cầu
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        hoverColor: Colors.grey[50], // Hiệu ứng đổi màu nhẹ khi di chuột qua
        onTap: () {
          context.push('/brands/products/${brand.id}?name=${brand.name}');
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Row(
            children: [
              // 1. Khung chứa Logo
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    'https://api.caibang.online${brand.logoUrl}',
                    width: 56,
                    height: 56,
                    fit: BoxFit.contain, // Dùng contain để logo không bị mất hình
                    errorBuilder: (_, __, ___) => Container(
                      width: 56,
                      height: 56,
                      color: Colors.grey[50],
                      child: const Icon(Icons.broken_image_outlined,
                          color: Colors.grey, size: 24),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),

              // 2. Thông tin nhãn hàng
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      brand.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        color: Colors.black87,
                        letterSpacing: 0.3,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    // Badge hiển thị số lượng sản phẩm
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '${brand.counts} sản phẩm',
                        style: TextStyle(
                          color: Colors.blue.shade700,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // 3. Icon chỉ hướng
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14,
                color: Colors.grey.shade400,
              ),
            ],
          ),
        ),
      ),
    );
  }
}