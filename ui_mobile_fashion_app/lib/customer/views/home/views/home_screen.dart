// lib/customer/views/home/views/home_screen.dart
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:ui_mobile_fashion_app/core/constants/assets.dart/assets.gen.dart';
import 'package:ui_mobile_fashion_app/customer/views/home/widgets/banner_slider.dart';
import 'package:ui_mobile_fashion_app/customer/views/home/widgets/sidebar_overlay_manager.dart';
import 'package:ui_mobile_fashion_app/customer/views/home/widgets/utility_access_bar.dart';
import '../data/product_sections.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(LucideIcons.menu, color: Colors.black),
          onPressed: () => SidebarOverlayManager.open(context),
        ),
        title: Assets.logoFas.image(height: 20, fit: BoxFit.contain),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.bell, color: Colors.black),
            onPressed: () => print('Mở Thông báo'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: FutureBuilder<List<Widget>>(
        future: Future.wait(homeProductSections),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.black),
            );
          }

          final sections = snapshot.data ?? [];

          return SingleChildScrollView(
            child: Column(
              children: [
                _buildSearchBar(),
                const BannerSlider(),
                const UtilityAccessBar(),
                ...sections,
                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Tìm kiếm sản phẩm...',
          prefixIcon: const Icon(LucideIcons.search, color: Colors.grey),
          filled: true,
          fillColor: Colors.grey[100],
          contentPadding: const EdgeInsets.symmetric(vertical: 0),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.black, width: 1.5),
          ),
        ),
        onSubmitted: (value) => print('Tìm kiếm: $value'),
      ),
    );
  }
}