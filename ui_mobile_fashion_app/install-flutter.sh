#!/bin/bash

# 1. Định nghĩa thư mục cài đặt
FLUTTER_DIR="$HOME/flutter"

# 2. Clone Flutter nếu chưa có (Netlify Cache có thể làm mất PATH nhưng còn thư mục)
if [ ! -d "$FLUTTER_DIR" ]; then
    git clone https://github.com/flutter/flutter.git -b stable $FLUTTER_DIR
fi

# 3. THIẾT LẬP LẠI PATH (Bắt buộc phải có dòng này để chạy lệnh flutter)
export PATH="$PATH:$FLUTTER_DIR/bin"

# 4. Tạo file env ở thư mục gốc (Khớp với pubspec.yaml đã sửa)
echo "API_BASE_URL=$API_BASE_URL" > .env.dev
echo "API_VERSION=$API_VERSION" >> .env.dev
echo "APP_NAME=$APP_NAME" >> .env.dev

# Kiểm tra file đã tồn tại chưa
ls -a .env.dev

# 5. Thực hiện build
flutter config --enable-web
flutter pub get
flutter build web --release -t lib/main_admin.dart --dart-define=FLAVOR=admin --no-wasm-dry-run