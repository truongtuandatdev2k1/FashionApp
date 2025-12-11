import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class OrderFailureScreen extends StatelessWidget {
  final String errorMessage;

  const OrderFailureScreen({super.key, required this.errorMessage});

  @override
  Widget build(BuildContext context) {
    // In lỗi ra terminal (theo yêu cầu)
    print('-----------------------------------------');
    print('LỖI ĐẶT HÀNG: $errorMessage');
    print('-----------------------------------------');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lỗi đặt hàng'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Hình tròn đỏ
              const CircleAvatar(
                radius: 50,
                backgroundColor: Colors.red,
                child: Icon(Icons.close, size: 60, color: Colors.white),
              ),
              const SizedBox(height: 30),

              // Tiêu đề
              const Text(
                'Lỗi đặt hàng',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 10),

              // Chi tiết lỗi
              Text(
                errorMessage,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey[700]),
              ),
              const SizedBox(height: 40),

              // Nút thử lại
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    // Quay lại màn hình OrderScreen (Pop 1 lần)
                    context.pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Quay lại & Thử lại',
                    style: TextStyle(fontSize: 16, color: Colors.white),
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
