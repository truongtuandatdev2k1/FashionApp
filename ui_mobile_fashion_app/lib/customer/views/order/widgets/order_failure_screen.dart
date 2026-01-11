import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class OrderFailureScreen extends StatelessWidget {
  final String errorMessage;
  // Thêm tham số tùy chọn
  final String? orderId;
  final double? totalAmount;

  const OrderFailureScreen({
    super.key,
    required this.errorMessage,
    this.orderId,
    this.totalAmount,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');
    final isVNPay = orderId != null;

    print('-----------------------------------------');
    print('LỖI ĐẶT HÀNG: $errorMessage');
    print('-----------------------------------------');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kết quả thanh toán'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 1. Icon
              const CircleAvatar(
                radius: 50,
                backgroundColor: Colors.red,
                child: Icon(Icons.close, size: 60, color: Colors.white),
              ),
              const SizedBox(height: 30),

              // 2. Tiêu đề
              Text(
                isVNPay ? 'Thanh toán thất bại' : 'Lỗi đặt hàng',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 10),

              // 3. Thông tin chi tiết (Chỉ hiện nếu là VNPay / có orderId)
              if (isVNPay) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    children: [
                      _buildInfoRow('Mã đơn hàng', orderId!),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8.0),
                        child: Divider(),
                      ),
                      _buildInfoRow(
                        'Tổng thanh toán',
                        currencyFormat.format(totalAmount ?? 0),
                        isBold: true,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],

              // 4. Chi tiết lỗi
              Text(
                errorMessage,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey[700]),
              ),
              const SizedBox(height: 40),

              // 5. Nút Quay về trang chủ
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    // Yêu cầu là quay về trang chủ
                    context.go('/home');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Quay về trang chủ',
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

  Widget _buildInfoRow(String label, String value, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.grey, fontSize: 14),
        ),
        Text(
          value,
          style: TextStyle(
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: Colors.black87,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}