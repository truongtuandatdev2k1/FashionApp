// lib/customer/views/home/data/best_sellers.dart

import 'package:ui_mobile_fashion_app/customer/models/product_data.dart';
import '../widgets/horizontal_product_section.dart';

final bestSellersSection = HorizontalProductSection(
  title: 'Bán chạy nhất',
  products: [
    ProductData(
      imageUrl: 'https://mir-cdn.behance.net/v1/rendition/project_modules/max_632/91a70b171865541.6475fbc8ab229.jpg',
      name: 'Áo thun Basic Tee',
      price: 299000,
      discountPct: 25,
      priceAfter: 224250, // 299000 × 0.75
    ),
    ProductData(
      imageUrl: 'https://mir-s3-cdn-cf.behance.net/project_modules/disp/b3b6f2171865541.6475fbca67b16.jpg',
      name: 'Giày Nike Air Max',
      price: 2590000,
      discountPct: 30,
      priceAfter: 1813000, // 2590000 × 0.70
    ),
    ProductData(
      imageUrl: 'https://mir-s3-cdn-cf.behance.net/project_modules/disp/454c24171865541.6475fbd9da81f.jpg',
      name: 'Quần jeans slim fit',
      price: 799000,
      discountPct: 20,
      priceAfter: 639200, // 799000 × 0.80
    ),
    ProductData(
      imageUrl: 'https://mir-s3-cdn-cf.behance.net/project_modules/disp/b3b6f2171865541.6475fbca67b16.jpg',
      name: 'Áo khoác bomber',
      price: 1199000,
      discountPct: 15,
      priceAfter: 1019150, // 1199000 × 0.85
    ),
  ],
);