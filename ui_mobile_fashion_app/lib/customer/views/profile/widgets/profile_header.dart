// lib/customer/views/profile/widgets/profile_header.dart
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:ui_mobile_fashion_app/core/utils/image_url_helper.dart';

const Color kPrimaryColor = Colors.black;

class ProfileHeader extends StatelessWidget {
  final Map<String, dynamic>? userData;

  const ProfileHeader({super.key, required this.userData});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 30),
        _buildAvatar(userData?['ImgURL']),
        const SizedBox(height: 10),
        _buildFullName(userData?['FullName']),
        const SizedBox(height: 30),
      ],
    );
  }

  Widget _buildAvatar(String? imgUrl) {
    final String displayUrl = ImageUrlHelper.build(imgUrl);
    const String defaultAvatarUrl =
        'https://i.pinimg.com/736x/bc/43/98/bc439871417621836a0eeea768d60944.jpg';
    final String finalUrl =
        displayUrl.isNotEmpty ? displayUrl : defaultAvatarUrl;

    return SizedBox(
      height: 115,
      width: 115,
      child: Stack(
        fit: StackFit.expand,
        clipBehavior: Clip.none,
        children: [
          CircleAvatar(
            radius: 57.5,
            backgroundColor: Colors.grey[200],
            child: ClipOval(
              child: CachedNetworkImage(
                imageUrl: finalUrl,
                fit: BoxFit.cover,
                placeholder:
                    (context, url) => Container(
                      color: Colors.grey[300],
                      child: const CircularProgressIndicator(strokeWidth: 2),
                    ),
                errorWidget:
                    (context, url, error) => Container(
                      color: Colors.grey[300],
                      child: const Icon(
                        Icons.person,
                        size: 50,
                        color: Colors.grey,
                      ),
                    ),
              ),
            ),
          ),
          Positioned(
            right: -16,
            bottom: 0,
            child: SizedBox(
              height: 46,
              width: 46,
              child: TextButton(
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50),
                    side: const BorderSide(color: Colors.white),
                  ),
                  backgroundColor: const Color(0xFFF5F6F9),
                ),
                onPressed: () {},
                child: const Icon(
                  LucideIcons.camera,
                  color: kPrimaryColor,
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFullName(String? fullName) {
    return Text(
      fullName ?? 'Người dùng',
      style: const TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: kPrimaryColor,
      ),
    );
  }
}
