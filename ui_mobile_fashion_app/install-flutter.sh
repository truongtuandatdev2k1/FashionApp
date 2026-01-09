# file: ui_mobile_fashion_app/install-flutter.sh
#!/bin/bash
# 1. Cài đặt Flutter
git clone https://github.com/flutter/flutter.git -b stable $HOME/flutter
export PATH="$PATH:$HOME/flutter/bin"

# 2. Đảm bảo thư mục assets tồn tại và tạo file env
mkdir -p assets
echo "API_BASE_URL=$API_BASE_URL" > assets/.env.dev
echo "API_VERSION=$API_VERSION" >> assets/.env.dev
echo "APP_NAME=$APP_NAME" >> assets/.env.dev

# 3. Cài đặt dependencies và Build
flutter pub get
# Sử dụng --web-renderer html để tương thích tốt nhất trên trình duyệt web
flutter build web --release --web-renderer html -t lib/main_admin.dart --dart-define=FLAVOR=admin