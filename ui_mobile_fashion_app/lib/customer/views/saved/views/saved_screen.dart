// lib/customer/views/saved/saved_screen.dart

import 'package:flutter/material.dart';
import 'package:ui_mobile_fashion_app/core/constants/assets.dart/assets.gen.dart';
import 'package:ui_mobile_fashion_app/core/utils/extensions.dart';
import 'package:ui_mobile_fashion_app/customer/logic/saved/saved_api.dart';
import 'package:ui_mobile_fashion_app/customer/views/common/navigation_helper.dart';
import 'package:ui_mobile_fashion_app/customer/views/saved/widgets/saved_product_item.dart';

class SavedScreen extends StatefulWidget {
  const SavedScreen({super.key});

  @override
  State<SavedScreen> createState() => _SavedScreenState();
}

class _SavedScreenState extends State<SavedScreen> {
  late Future<WishlistResponse> _wishlistFuture;

  @override
  void initState() {
    super.initState();
    _wishlistFuture = SavedApi.getWishlist();
  }

  void _refresh() {
    setState(() {
      _wishlistFuture = SavedApi.getWishlist();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Sản phẩm yêu thích',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.3,
          ),
        ),
        centerTitle: true,
      ),
      body: FutureBuilder<WishlistResponse>(
        future: _wishlistFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: Colors.black,
                strokeWidth: 1.5,
              ),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.wifi_off_rounded,
                    size: 44,
                    color: Colors.black26,
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'Không thể tải dữ liệu',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[500],
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextButton(
                    onPressed: _refresh,
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: const Text(
                      'Thử lại',
                      style: TextStyle(color: Colors.white, fontSize: 14),
                    ),
                  ),
                ],
              ),
            );
          }

          final items = snapshot.data!.items;

          if (items.isEmpty) {
            return _buildEmptyState(context);
          }

          return _buildWishlistList(items);
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async => _refresh(),
      color: Colors.black,
      strokeWidth: 1.5,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.75,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: 200,
                          height: 200,
                          decoration: BoxDecoration(
                            color: Colors.grey.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                        ),
                        Assets.customer.images.friendship.image(
                          width: 100,
                          height: 100,
                          fit: BoxFit.contain,
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),
                    const Text(
                      'Chưa có sản phẩm yêu thích',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Hãy khám phá và lưu những món đồ\nbạn yêu thích vào đây nhé!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[500],
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 28),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: TextButton(
                        onPressed: () => context.go('/home'),
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: const Text(
                          'Khám phá ngay',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWishlistList(List<WishlistProduct> items) {
    return RefreshIndicator(
      onRefresh: () async => _refresh(),
      color: Colors.black,
      strokeWidth: 1.5,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: items.length,
        itemBuilder: (context, index) {
          return SavedProductItem(
            product: items[index],
            onTap: () => NavigationHelper.toProductDetail(
              context,
              productId: items[index].id,
            ),
          );
        },
      ),
    );
  }
}