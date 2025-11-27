// // lib/customer/views/product/widgets/product_detail/body/color_selector.dart
// import 'package:flutter/material.dart';

// class ColorSelector extends StatefulWidget {
//   final List<Color> colors;
//   final Color initialColor;

//   const ColorSelector({super.key, required this.colors, this.initialColor = Colors.black});

//   @override
//   State<ColorSelector> createState() => _ColorSelectorState();
// }

// class _ColorSelectorState extends State<ColorSelector> {
//   late Color _selected;

//   @override
//   void initState() {
//     super.initState();
//     _selected = widget.initialColor;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         const Text('Color', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//         const SizedBox(height: 8),
//         Wrap(
//           spacing: 12,
//           children: widget.colors.map((color) {
//             final selected = color == _selected;
//             return GestureDetector(
//               onTap: () => setState(() => _selected = color),
//               child: Container(
//                 width: 28,
//                 height: 28,
//                 decoration: BoxDecoration(
//                   color: color,
//                   shape: BoxShape.circle,
//                   border: Border.all(color: selected ? Colors.black : Colors.transparent, width: selected ? 3 : 0),
//                 ),
//                 child: selected && color == Colors.white
//                     ? const Icon(Icons.check, size: 16, color: Colors.black)
//                     : null,
//               ),
//             );
//           }).toList(),
//         ),
//       ],
//     );
//   }
// }