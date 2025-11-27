// lib/customer/views/address/views/address_form_screen.dart
import 'package:flutter/material.dart';

class AddressFormScreen extends StatefulWidget {
  final bool isEdit;
  const AddressFormScreen({Key? key, this.isEdit = false}) : super(key: key);

  @override
  State<AddressFormScreen> createState() => _AddressFormScreenState();
}

class _AddressFormScreenState extends State<AddressFormScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isDefault = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        title: Text(widget.isEdit ? "Sửa Địa Chỉ" : "Thêm Địa Chỉ Mới"),
        actions: [
          TextButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                // TODO: Lưu địa chỉ
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Đã lưu địa chỉ thành công!")),
                );
              }
            },
            child: const Text("Lưu", style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(decoration: const InputDecoration(labelText: "Họ và tên"), validator: (v) => v!.isEmpty ? "Vui lòng nhập tên" : null),
              const SizedBox(height: 16),
              TextFormField(decoration: const InputDecoration(labelText: "Số điện thoại"), validator: (v) => v!.length < 10 ? "SĐT không hợp lệ" : null),
              const SizedBox(height: 16),
              TextFormField(decoration: const InputDecoration(labelText: "Tỉnh/Thành phố"), validator: (v) => v!.isEmpty ? "Bắt buộc" : null),
              const SizedBox(height: 16),
              TextFormField(decoration: const InputDecoration(labelText: "Quận/Huyện"), validator: (v) => v!.isEmpty ? "Bắt buộc" : null),
              const SizedBox(height: 16),
              TextFormField(decoration: const InputDecoration(labelText: "Phường/Xã"), validator: (v) => v!.isEmpty ? "Bắt buộc" : null),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(labelText: "Địa chỉ chi tiết (số nhà, đường...)"),
                maxLines: 3,
                validator: (v) => v!.isEmpty ? "Bắt buộc" : null,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Checkbox(value: _isDefault, onChanged: (v) => setState(() => _isDefault = v!)),
                  const Text("Đặt làm địa chỉ mặc định"),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}