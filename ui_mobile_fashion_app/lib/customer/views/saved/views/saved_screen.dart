import 'package:flutter/material.dart';
// **QUAN TRỌNG:** Phải import file được tạo ra bởi FlutterGen
import 'package:ui_mobile_fashion_app/core/constants/assets.dart/assets.gen.dart';

class SavedScreen extends StatelessWidget {
  const SavedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Kích thước của lớp phủ hình tròn (Dùng lại kích thước bạn thích)
    const double circleSize = 200.0;
    // Kích thước của hình ảnh (Dùng lại kích thước bạn thích)
    const double imageContentSize = 100.0;

    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              // 1. Hiển thị hình ảnh với lớp phủ hình tròn to (friendship.png)
              Stack(
                alignment: Alignment.center,
                children: [
                  // Lớp phủ xám nhạt (Overlay) hình tròn
                  Container(
                    width: circleSize,
                    height: circleSize,
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.15), // Màu xám nhạt
                      shape: BoxShape.circle,
                    ),
                  ),

                  // Hình ảnh friendship.png
                  Assets.customer.images.friendship.image( // <--- ĐÃ THAY BẰNG friendship.png
                    width: imageContentSize,
                    height: imageContentSize,
                    fit: BoxFit.contain,
                  ),
                ],
              ),

              const SizedBox(height: 30),

              // 2. Text thông báo danh sách rỗng
              const Text(
                'Bạn chưa có sản phẩm nào được lưu\nHãy tìm kiếm những món đồ yêu thích!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black54,
                ),
              ),

              const SizedBox(height: 20),

              // 3. Button "Khám phá ngay"
              SizedBox(
                width: double.infinity,
                height: 50,
                child: TextButton(
                  onPressed: () {
                    // TODO: Xử lý sự kiện khi nhấn nút (ví dụ: điều hướng đến trang Khám phá/Home)
                    debugPrint('Khám phá ngay');
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20), // Bo góc tròn 20
                    ),
                  ),
                  child: const Text(
                    'Khám phá ngay', // Đổi text phù hợp hơn với màn Saved/Yêu thích
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