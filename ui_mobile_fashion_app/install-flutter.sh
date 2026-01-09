#!/bin/bash
# ... (phần clone flutter giữ nguyên)

# SỬA TẠI ĐÂY: Tạo file ở ngay thư mục gốc của dự án
echo "API_BASE_URL=$API_BASE_URL" > .env.dev
echo "API_VERSION=$API_VERSION" >> .env.dev
echo "APP_NAME=$APP_NAME" >> .env.dev

# Kiểm tra file tồn tại
ls -a .env.dev

# Build (nhớ dùng --no-wasm-dry-run để tránh lỗi warning)
flutter config --enable-web
flutter pub get
flutter build web --release -t lib/main_admin.dart --dart-define=FLAVOR=admin --no-wasm-dry-run