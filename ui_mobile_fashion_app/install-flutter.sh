#!/bin/bash
# 1. Cài đặt Flutter
git clone https://github.com/flutter/flutter.git -b stable $HOME/flutter
export PATH="$PATH:$HOME/flutter/bin"

# 2. TẠO FILE .env.dev TỪ BIẾN MÔI TRƯỜNG NETLIFY
# Netlify sẽ lấy các giá trị bạn đã nhập ở ô Environment Variables để điền vào đây
echo "API_BASE_URL=$API_BASE_URL" > .env.dev
echo "API_VERSION=$API_VERSION" >> .env.dev
echo "APP_NAME=$APP_NAME" >> .env.dev

# Kiểm tra xem file đã tạo thành công chưa (để debug)
ls -a

# 3. Build
flutter pub get
flutter build web --release -t lib/main_admin.dart --dart-define=FLAVOR=admin