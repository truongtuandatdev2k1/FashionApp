import 'package:flutter/material.dart';
// **QUAN TRỌNG:** Phải import file được tạo ra bởi FlutterGen
import 'package:ui_mobile_fashion_app/core/constants/assets.dart/assets.gen.dart';

// Đổi tên thành CartScreen
class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Kích thước của lớp phủ hình tròn (to hơn)
    const double circleSize = 200.0;
    // Kích thước của hình ảnh (nhỏ hơn, giữ nguyên)
    const double imageContentSize = 100.0; // Khoảng 60% của circleSize

    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              // 1. Hiển thị hình ảnh với lớp phủ hình tròn to
              Stack(
                alignment: Alignment.center,
                children: [
                  // Lớp phủ xám nhạt (Overlay) hình tròn to
                  Container(
                    width: circleSize,
                    height: circleSize,
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.15), // Màu xám nhạt
                      shape: BoxShape.circle,              // Hình tròn
                    ),
                  ),

                  // Hình ảnh happy_shopping.png (giữ nguyên kích thước cũ)
                  Assets.customer.images.happyShopping.image(
                    width: imageContentSize,
                    height: imageContentSize,
                    fit: BoxFit.contain,
                  ),
                ],
              ),

              const SizedBox(height: 30),

              // 2. Text thông báo giỏ hàng rỗng
              const Text(
                'Giỏ hàng của bạn\nhiện chưa có sản phẩm nào',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black54,
                ),
              ),

              const SizedBox(height: 20),

              // 3. Button "Tiếp tục mua sắm"
              SizedBox(
                width: double.infinity,
                height: 50,
                child: TextButton(
                  onPressed: () {
                    // TODO: Xử lý sự kiện khi nhấn nút
                    debugPrint('Tiếp tục mua sắm');
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20), // Bo góc tròn 20
                    ),
                  ),
                  child: const Text(
                    'Tiếp tục mua sắm',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}