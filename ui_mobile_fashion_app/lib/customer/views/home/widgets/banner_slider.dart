import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';

class BannerSlider extends StatelessWidget {
  const BannerSlider({super.key});

  // DỮ LIỆU FIX CỨNG – BẠN SẼ THAY SAU
  static const List<String> _bannerImages = [
    'https://i.pinimg.com/736x/3f/50/dc/3f50dc11de0c352f8ef7d5e046e476ee.jpg',
    'https://i.pinimg.com/1200x/1d/26/4c/1d264c988391a6b743cfbd299b381170.jpg',
    'https://i.pinimg.com/736x/15/e5/76/15e576eb881239357dcff6505d4c0091.jpg',
    'https://i.pinimg.com/1200x/d8/d1/75/d8d175be6190e05d652b2cd60524a0f4.jpg',
    'https://i.pinimg.com/1200x/6d/47/fe/6d47fec6215b2f198388c29cd416575b.jpg',
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: CarouselSlider(
        options: CarouselOptions(
          height: 160,
          autoPlay: true,
          autoPlayInterval: const Duration(seconds: 4),
          autoPlayAnimationDuration: const Duration(milliseconds: 800),
          autoPlayCurve: Curves.fastOutSlowIn,
          enlargeCenterPage: true,
          enlargeFactor: 0.25,
          viewportFraction: 1.0,
          aspectRatio: 16 / 9,
          enableInfiniteScroll: true,
        ),
        items: _bannerImages.map((imageUrl) {
          return ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: Container(
              width: double.infinity,
              color: Colors.grey[300],
              child: Image.network(
                imageUrl,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return const Center(
                    child: CircularProgressIndicator(strokeWidth: 2),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return const Center(
                    child: Icon(Icons.broken_image, color: Colors.grey),
                  );
                },
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}