#!/bin/bash
# 1. Cài đặt Flutter
FLUTTER_DIR="$HOME/flutter"
if [ ! -d "$FLUTTER_DIR" ]; then
    git clone https://github.com/flutter/flutter.git -b stable $FLUTTER_DIR
fi
export PATH="$PATH:$FLUTTER_DIR/bin"

# 2. TẠO FILE .env.dev Ở THƯ MỤC GỐC
# Quan trọng: Ghi đè hoặc tạo mới file ở thư mục gốc dự án
echo "API_BASE_URL=$API_BASE_URL" > .env.dev
echo "API_VERSION=$API_VERSION" >> .env.dev
echo "APP_NAME=$APP_NAME" >> .env.dev

# 3. Thực hiện build
flutter config --enable-web
flutter pub get
# Thêm cờ --no-tree-shake-icons để tránh lỗi icon nếu có
flutter build web --release -t lib/main_admin.dart --dart-define=FLAVOR=admin --no-wasm-dry-run --no-tree-shake-icons