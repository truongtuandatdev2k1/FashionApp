// lib/customer/views/splash/customer_splash_screen.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:ui_mobile_fashion_app/core/constants/assets.dart/assets.gen.dart';

class CustomerSplashScreen extends StatefulWidget {
  const CustomerSplashScreen({super.key});

  @override
  State<CustomerSplashScreen> createState() => _CustomerSplashScreenState();
}

class _CustomerSplashScreenState extends State<CustomerSplashScreen> {
  final List<String> backgroundImages = [
    'https://mir-s3-cdn-cf.behance.net/project_modules/disp/7ade7a174318897.64a0285b0d52b.png',
    'https://mir-s3-cdn-cf.behance.net/project_modules/disp/713e06173470997.649106d760451.jpg',
    'https://mir-s3-cdn-cf.behance.net/project_modules/fs_webp/456164174318897.64a028687fa1c.png',
  ];

  int _currentIndex = 0;

  void _navigateToLogin() {
    context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 1. CAROUSEL NỀN
          CarouselSlider(
            options: CarouselOptions(
              height: MediaQuery.of(context).size.height,
              viewportFraction: 1.0,
              autoPlay: true,
              autoPlayInterval: const Duration(seconds: 4),
              autoPlayAnimationDuration: const Duration(milliseconds: 800),
              enlargeCenterPage: false,
              enableInfiniteScroll: true,
              scrollPhysics: const BouncingScrollPhysics(),
              onPageChanged: (index, reason) {
                setState(() {
                  _currentIndex = index;
                });
              },
            ),
            items: backgroundImages.map((i) {
              return Builder(
                builder: (BuildContext context) {
                  return CachedNetworkImage(
                    imageUrl: i,
                    fit: BoxFit.cover,
                    width: MediaQuery.of(context).size.width,
                    placeholder: (context, url) => Container(color: Colors.grey.shade200),
                    errorWidget: (context, url, error) => const Icon(Icons.error),
                  );
                },
              );
            }).toList(),
          ),

          // GRADIENT TRẮNG DƯỚI
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [Colors.white, Colors.transparent],
                stops: [0.0, 0.40],
              ),
            ),
          ),

          // NỘI DUNG CHÍNH
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25.0),
              child: Column(
                children: [
                  // Logo
                  Padding(
                    padding: const EdgeInsets.only(top: 30.0),
                    child: Assets.logoFas.image(
                      width: 80,
                      fit: BoxFit.contain,
                    ),
                  ),

                  const Spacer(),

                  // CHẤM + TEXT + NÚT – SÁT DƯỚI GẦN NÚT
                  Column(
                    children: [
                      // CHẤM TRANG
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: backgroundImages.asMap().entries.map((entry) {
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            margin: const EdgeInsets.symmetric(horizontal: 4.0),
                            height: 8.0,
                            width: _currentIndex == entry.key ? 20.0 : 8.0,
                            decoration: BoxDecoration(
                              color: _currentIndex == entry.key
                                  ? Colors.black
                                  : Colors.grey.shade400,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          );
                        }).toList(),
                      ),

                      const SizedBox(height: 12), // GIẢM KHOẢNG CÁCH → GẦN TEXT HƠN

                      // TEXT TRUYỀN CẢM HỨNG
                      const Text(
                        'Tự tin tỏa sáng theo phong cách\nriêng của bạn.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 20,
                          fontWeight: FontWeight.w400,
                          height: 1.3,
                        ),
                      ),

                      const SizedBox(height: 20), // GIỮ KHOẢNG CÁCH VỪA PHẢI ĐẾN NÚT

                      // NÚT BẮT ĐẦU
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: TextButton(
                          onPressed: _navigateToLogin,
                          style: TextButton.styleFrom(
                            backgroundColor: Colors.black,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(40),
                            ),
                          ),
                          child: const Text(
                            'Bắt đầu mua sắm',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20), // ĐỆM DƯỚI ĐỂ KHÔNG BỊ DÍNH MÉP
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}