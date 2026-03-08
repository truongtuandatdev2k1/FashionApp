// lib/customer/views/profile/widgets/profile_header.dart
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:ui_mobile_fashion_app/core/utils/image_url_helper.dart';
import 'package:ui_mobile_fashion_app/customer/views/profile/views/profile_edit_screen.dart';

const Color kPrimaryColor = Colors.black;

class ProfileHeader extends StatelessWidget {
  final Map<String, dynamic>? userData;

  const ProfileHeader({super.key, required this.userData});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 30),
        _buildAvatar(context, userData?['ImgURL']),
        const SizedBox(height: 10),
        _buildFullName(userData?['FullName']),
        const SizedBox(height: 6),
        _buildEditButton(context),
        const SizedBox(height: 20),
        _buildInfoCard(),
        const SizedBox(height: 10),
      ],
    );
  }

  // ─── AVATAR ──────────────────────────────────────────────────────────────────
  Widget _buildAvatar(BuildContext context, String? imgUrl) {
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
                width: 115,
                height: 115,
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
                onPressed: () => _goToEditScreen(context),
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

  // ─── TÊN ─────────────────────────────────────────────────────────────────────
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

  // ─── NÚT CHỈNH SỬA ───────────────────────────────────────────────────────────
  Widget _buildEditButton(BuildContext context) {
    return GestureDetector(
      onTap: () => _goToEditScreen(context),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(LucideIcons.pencil, size: 13, color: Colors.grey[500]),
          const SizedBox(width: 4),
          Text(
            'Chỉnh sửa hồ sơ',
            style: TextStyle(fontSize: 13, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  // ─── INFO CARD ────────────────────────────────────────────────────────────────
  Widget _buildInfoCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F6F9),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          children: [
            _buildInfoRow(
              icon: LucideIcons.calendarDays,
              label: 'Tuổi',
              value:
              userData?['Age'] != null
                  ? '${userData!['Age']} tuổi'
                  : '—',
            ),
            const Divider(height: 20, color: Color(0xFFE0E0E0)),
            _buildInfoRow(
              icon: LucideIcons.userRound,
              label: 'Giới tính',
              value: _formatGender(userData?['Gender']),
            ),
            const Divider(height: 20, color: Color(0xFFE0E0E0)),
            _buildInfoRow(
              icon: LucideIcons.mapPin,
              label: 'Địa chỉ',
              value: userData?['Address'] ?? '—',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, size: 18, color: kPrimaryColor),
        const SizedBox(width: 12),
        Text(
          label,
          style: const TextStyle(fontSize: 14, color: Colors.grey),
        ),
        const Spacer(),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: kPrimaryColor,
            ),
          ),
        ),
      ],
    );
  }

  String _formatGender(String? gender) {
    if (gender == null) return '—';
    switch (gender.toLowerCase()) {
      case 'nam':
        return 'Nam';
      case 'nu':
      case 'nữ':
        return 'Nữ';
      default:
        return gender;
    }
  }

  // ─── NAVIGATION ───────────────────────────────────────────────────────────────
  void _goToEditScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ProfileEditScreen()),
    );
  }
}