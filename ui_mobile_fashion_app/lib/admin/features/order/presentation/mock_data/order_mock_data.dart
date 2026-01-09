// lib/admin/features/order/mock_data/order_mock_data.dart
class OrderMock {
  final String id;
  final String customer;
  final String phone;
  final String time; // Ví dụ: '08:30'
  final String date; // Định dạng DD/MM/YYYY
  final int quantity;
  final String status; // trạng thái đơn hàng
  final String paymentStatus; // ← Thêm: "Đã thanh toán" hoặc "Chưa thanh toán"
  final double totalAmount;

  OrderMock({
    required this.id,
    required this.customer,
    required this.phone,
    required this.time,
    required this.date,
    required this.quantity,
    required this.status,
    required this.paymentStatus, // ← required
    required this.totalAmount,
  });
}

final List<OrderMock> mockOrders = [
  OrderMock(
    id: '#ORD-1017',
    customer: 'Cao Thị S',
    phone: '0987651234',
    time: '08:10',
    date: '05/01/2026',
    quantity: 2,
    status: 'Đang giao',
    paymentStatus: 'Đã thanh toán',
    totalAmount: 1700000.0,
  ),
  OrderMock(
    id: '#ORD-1018',
    customer: 'Tô Văn T',
    phone: '0932109876',
    time: '10:50',
    date: '04/01/2026',
    quantity: 3,
    status: 'Chờ xác nhận',
    paymentStatus: 'Chưa thanh toán',
    totalAmount: 2100000.0,
  ),
  OrderMock(
    id: '#ORD-1019',
    customer: 'Hà Thị U',
    phone: '0912340987',
    time: '13:15',
    date: '04/01/2026',
    quantity: 4,
    status: 'Hoàn thành',
    paymentStatus: 'Đã thanh toán',
    totalAmount: 3400000.0,
  ),
  OrderMock(
    id: '#ORD-1020',
    customer: 'Võ Minh V',
    phone: '0967890123',
    time: '18:25',
    date: '03/01/2026',
    quantity: 1,
    status: 'Đã hủy',
    paymentStatus: 'Chưa thanh toán',
    totalAmount: 1450000.0,
  ),
  OrderMock(
    id: '#ORD-1021',
    customer: 'Đoàn Thị X',
    phone: '0945678901',
    time: '07:40',
    date: '03/01/2026',
    quantity: 2,
    status: 'Đang giao',
    paymentStatus: 'Đã thanh toán',
    totalAmount: 1900000.0,
  ),
  OrderMock(
    id: '#ORD-1022',
    customer: 'Khúc Văn Y',
    phone: '0978901234',
    time: '11:00',
    date: '02/01/2026',
    quantity: 5,
    status: 'Hoàn thành',
    paymentStatus: 'Đã thanh toán',
    totalAmount: 3750000.0,
  ),
  OrderMock(
    id: '#ORD-1023',
    customer: 'Nguyễn Thị Z',
    phone: '0923456781',
    time: '15:20',
    date: '02/01/2026',
    quantity: 3,
    status: 'Chờ xác nhận',
    paymentStatus: 'Chưa thanh toán',
    totalAmount: 2400000.0,
  ),
  OrderMock(
    id: '#ORD-1024',
    customer: 'Trần Văn AA',
    phone: '0987654322',
    time: '09:30',
    date: '01/01/2026',
    quantity: 2,
    status: 'Đang giao',
    paymentStatus: 'Đã thanh toán',
    totalAmount: 1650000.0,
  ),
  OrderMock(
    id: '#ORD-1025',
    customer: 'Lê Thị BB',
    phone: '0934567890',
    time: '12:45',
    date: '01/01/2026',
    quantity: 4,
    status: 'Hoàn thành',
    paymentStatus: 'Đã thanh toán',
    totalAmount: 3200000.0,
  ),
  OrderMock(
    id: '#ORD-1026',
    customer: 'Phạm Minh CC',
    phone: '0909876544',
    time: '17:10',
    date: '31/12/2025',
    quantity: 1,
    status: 'Đã hủy',
    paymentStatus: 'Chưa thanh toán',
    totalAmount: 1100000.0,
  ),
];
