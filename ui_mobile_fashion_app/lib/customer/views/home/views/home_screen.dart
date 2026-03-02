// lib/customer/views/home/views/home_screen.dart
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:ui_mobile_fashion_app/core/constants/assets.dart/assets.gen.dart';
import 'package:ui_mobile_fashion_app/customer/views/home/widgets/banner_slider.dart';
import 'package:ui_mobile_fashion_app/customer/views/home/widgets/sidebar_overlay_manager.dart';
import 'package:ui_mobile_fashion_app/customer/views/home/widgets/utility_access_bar.dart';
import '../data/product_sections.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
  GlobalKey<RefreshIndicatorState>();
  List<Widget> _sections = [];
  bool _isLoading = true;
  int _refreshCount = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    print('🔄 HomeScreen: Bắt đầu load data...');
    setState(() => _isLoading = true);

    try {
      // ✅ GỌI HÀM getHomeProductSections() để tạo Future MỚI
      final sections = await Future.wait(getHomeProductSections());
      if (mounted) {
        setState(() {
          _sections = sections;
          _isLoading = false;
        });
        print('✅ HomeScreen: Load data thành công - ${sections.length} sections');
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
      print('❌ HomeScreen: Lỗi khi load data: $e');
    }
  }

  Future<void> _handleRefresh() async {
    _refreshCount++;
    print('🔄 HomeScreen: Refresh lần $_refreshCount');

    await _loadData();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Đã làm mới! (Lần $_refreshCount)'),
          duration: const Duration(seconds: 1),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.black87,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        centerTitle: true,
        // leading: IconButton(
        //   icon: const Icon(LucideIcons.menu, color: Colors.black),
        //   onPressed: () => SidebarOverlayManager.open(context),
        // ),
        title: Assets.logoFas.image(height:30, fit: BoxFit.contain),
        // actions: [
        //   IconButton(
        //     icon: const Icon(LucideIcons.bell, color: Colors.black),
        //     onPressed: () => print('Mở Thông báo'),
        //   ),
        //   const SizedBox(width: 8),
        // ],
      ),
      body: RefreshIndicator(
        key: _refreshIndicatorKey,
        onRefresh: _handleRefresh,
        color: Colors.black,
        backgroundColor: Colors.white,
        child: _isLoading
            ? ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: const [
            SizedBox(
              height: 400,
              child: Center(
                child: CircularProgressIndicator(color: Colors.black),
              ),
            ),
          ],
        )
            : SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              _buildSearchBar(),
              const BannerSlider(),
              const UtilityAccessBar(),
              ..._sections,
              const SizedBox(height: 20),
            ],
          ),
        ),
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