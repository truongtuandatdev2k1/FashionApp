// lib/customer/views/address/views/address_form_screen.dart
import 'package:flutter/material.dart';
import 'package:ui_mobile_fashion_app/customer/logic/address/address_service.dart';
import 'package:ui_mobile_fashion_app/customer/models/address.dart';

class AddressFormScreen extends StatefulWidget {
  final Address? address;
  const AddressFormScreen({super.key, this.address});

  @override
  State<AddressFormScreen> createState() => _AddressFormScreenState();
}

class _AddressFormScreenState extends State<AddressFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameCtrl,
      _phoneCtrl,
      _cityCtrl,
      _districtCtrl,
      _wardCtrl,
      _detailCtrl;
  bool _isDefaultWhenCreate = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final a = widget.address;
    _nameCtrl = TextEditingController(text: a?.recipientName ?? '');
    _phoneCtrl = TextEditingController(text: a?.phoneNumber ?? '');
    _cityCtrl = TextEditingController(
      text: a != null ? _extractCity(a.fullAddress) : 'Hà Nội',
    );
    _districtCtrl = TextEditingController(
      text: a != null ? _extractDistrict(a.fullAddress) : '',
    );
    _wardCtrl = TextEditingController(
      text: a != null ? _extractWard(a.fullAddress) : '',
    );
    _detailCtrl = TextEditingController(
      text: a != null ? _extractDetail(a.fullAddress) : '',
    );
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _cityCtrl.dispose();
    _districtCtrl.dispose();
    _wardCtrl.dispose();
    _detailCtrl.dispose();
    super.dispose();
  }

  // Helper tách địa chỉ khi sửa
  String _extractCity(String s) => s.split(', ').last.trim();
  String _extractDistrict(String s) => s
      .split(', ')
      .reversed
      .skip(1)
      .first
      .replaceAll(RegExp(r'^(Quận|Huyện)\s+'), '');
  String _extractWard(String s) => s
      .split(', ')
      .reversed
      .skip(2)
      .first
      .replaceAll(RegExp(r'^(Phường|Xã)\s+'), '');
  String _extractDetail(String s) {
    final parts = s.split(', ');
    return parts.length >= 4
        ? parts.sublist(0, parts.length - 3).join(', ')
        : s;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final detailParts = _detailCtrl.text.trim().split(', ');
      final line1 = detailParts.first;
      final line2 =
          detailParts.length > 1 ? detailParts.sublist(1).join(', ') : null;

      if (widget.address == null) {
        await AddressService.createAddress(
          recipientName: _nameCtrl.text.trim(),
          phoneNumber: _phoneCtrl.text.trim(),
          city: _cityCtrl.text.trim(),
          district: _districtCtrl.text.trim(),
          ward: _wardCtrl.text.trim(),
          addressLine1: line1,
          addressLine2: line2,
          addressType: "home", // ← TỰ ĐỘNG GỬI "home"
        );
      } else {
        await AddressService.updateAddress(
          id: widget.address!.id,
          recipientName: _nameCtrl.text.trim(),
          phoneNumber: _phoneCtrl.text.trim(),
          city: _cityCtrl.text.trim(),
          district: _districtCtrl.text.trim(),
          ward: _wardCtrl.text.trim(),
          addressLine1: line1,
          addressLine2: line2,
          addressType: "home", // ← TỰ ĐỘNG GỬI "home"
        );
      }

      if (!mounted) return;
      Navigator.pop(context, true);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Lưu địa chỉ thành công!")));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Lỗi: $e")));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        leading: const CloseButton(),
        title: Text(
          widget.address == null ? "Thêm địa chỉ mới" : "Sửa địa chỉ",
        ),
        actions: [
          _isLoading
              ? const Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(strokeWidth: 2),
              )
              : TextButton(
                onPressed: _save,
                child: const Text(
                  "Lưu",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(labelText: "Họ và tên *"),
                validator: (v) => v!.trim().isEmpty ? "Bắt buộc" : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneCtrl,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(labelText: "Số điện thoại *"),
                validator: (v) => v!.length < 10 ? "SĐT không hợp lệ" : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _cityCtrl,
                decoration: const InputDecoration(
                  labelText: "Tỉnh/Thành phố *",
                ),
                validator: (v) => v!.trim().isEmpty ? "Bắt buộc" : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _districtCtrl,
                decoration: const InputDecoration(labelText: "Quận/Huyện *"),
                validator: (v) => v!.trim().isEmpty ? "Bắt buộc" : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _wardCtrl,
                decoration: const InputDecoration(labelText: "Phường/Xã *"),
                validator: (v) => v!.trim().isEmpty ? "Bắt buộc" : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _detailCtrl,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: "Địa chỉ chi tiết (số nhà, đường...) *",
                ),
                validator: (v) => v!.trim().isEmpty ? "Bắt buộc" : null,
              ),
              const SizedBox(height: 24),

              // Checkbox "Đặt làm mặc định" – chỉ hiện khi thêm mới
              if (widget.address == null)
                Row(
                  children: [
                    Checkbox(
                      value: _isDefaultWhenCreate,
                      onChanged:
                          (v) => setState(() => _isDefaultWhenCreate = v!),
                    ),
                    const Text("Đặt làm địa chỉ mặc định"),
                  ],
                ),
              const SizedBox(height: 50),
            ],
          ),
        ),
      ),
    );
  }
}
