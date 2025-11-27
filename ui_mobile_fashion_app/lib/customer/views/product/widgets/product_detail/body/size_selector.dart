// // lib/customer/views/product/widgets/product_detail/body/size_selector.dart
// import 'package:flutter/material.dart';

// class SizeSelector extends StatefulWidget {
//   final List<String> sizes;
//   final String initialSize;

//   const SizeSelector({super.key, required this.sizes, this.initialSize = ''});

//   @override
//   State<SizeSelector> createState() => _SizeSelectorState();
// }

// class _SizeSelectorState extends State<SizeSelector> {
//   late String _selected;

//   @override
//   void initState() {
//     super.initState();
//     _selected = widget.initialSize.isNotEmpty ? widget.initialSize : widget.sizes[0];
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         const Text('Size', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//         const SizedBox(height: 8),
//         Wrap(
//           spacing: 8,
//           children: widget.sizes.map((size) {
//             final selected = size == _selected;
//             return GestureDetector(
//               onTap: () => setState(() => _selected = size),
//               child: Container(
//                 padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//                 decoration: BoxDecoration(
//                   color: selected ? Colors.black : Colors.white,
//                   border: Border.all(color: selected ? Colors.black : Colors.grey.shade300),
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 child: Text(size,
//                     style: TextStyle(color: selected ? Colors.white : Colors.black, fontWeight: FontWeight.bold)),
//               ),
//             );
//           }).toList(),
//         ),
//       ],
//     );
//   }
// }