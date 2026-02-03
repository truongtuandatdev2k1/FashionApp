// // lib/admin/features/product/presentation/widgets/product_grid_view.dart
//
// import 'package:flutter/material.dart';
// import 'package:ui_mobile_fashion_app/admin/features/product/domain/entities/product_entity.dart';
// import 'package:ui_mobile_fashion_app/admin/features/product/presentation/widgets/product_card.dart';
//
// class ProductGridView extends StatelessWidget {
//   final List<ProductEntity> products;
//   final VoidCallback? onEdit;
//   final VoidCallback? onDelete;
//
//   const ProductGridView({
//     super.key,
//     required this.products,
//     this.onEdit,
//     this.onDelete,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return LayoutBuilder(
//       builder: (context, constraints) {
//         int crossAxisCount = constraints.maxWidth > 1200
//             ? 5
//             : (constraints.maxWidth > 800 ? 3 : 2);
//
//         return GridView.builder(
//           gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//             crossAxisCount: crossAxisCount,
//             childAspectRatio: 0.75,
//             crossAxisSpacing: 20,
//             mainAxisSpacing: 20,
//           ),
//           itemCount: products.length,
//           itemBuilder: (context, index) {
//             return Container(
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(12),
//                 border: Border.all(color: Colors.grey.shade300, width: 1),
//               ),
//               child: ProductCard(
//                 product: products[index],
//                 onEdit: onEdit ?? () {},
//                 onDelete: onDelete ?? () {},
//               ),
//             );
//           },
//         );
//       },
//     );
//   }
// }