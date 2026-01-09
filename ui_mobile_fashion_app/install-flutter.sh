#!/bin/bash

# 1. Cấu hình PATH và thư mục
FLUTTER_DIR="$HOME/flutter"
if [ ! -d "$FLUTTER_DIR" ]; then
    git clone https://github.com/flutter/flutter.git -b stable $FLUTTER_DIR
fi
export PATH="$PATH:$FLUTTER_DIR/bin"

# 2. TẠO FILE .env.dev Ở THƯ MỤC GỐC (Root)
# Không để vào thư mục assets/ để tránh lỗi assets/assets/
echo "API_BASE_URL=$API_BASE_URL" > .env.dev
echo "API_VERSION=$API_VERSION" >> .env.dev
echo "APP_NAME=$APP_NAME" >> .env.dev

# 3. Thực hiện build
flutter config --enable-web
flutter pub get

# Build với cờ tránh lỗi Wasm và icons
flutter build web --release -t lib/main_admin.dart \
  --dart-define=FLAVOR=admin \
  --no-wasm-dry-run \
  --no-tree-shake-icons