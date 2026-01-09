# file: ui_mobile_fashion_app/install-flutter.sh
#!/bin/bash

# 1. Cấu hình PATH
export PATH="$PATH:$HOME/flutter/bin"

# 2. Cài đặt Flutter nếu chưa có (Dùng cache Netlify)
if [ ! -d "$HOME/flutter" ]; then
    git clone https://github.com/flutter/flutter.git -b stable $HOME/flutter
fi

# 3. TẠO FILE TRONG THƯ MỤC ASSETS (Bắt buộc để build web không lỗi 404)
mkdir -p assets
echo "API_BASE_URL=$API_BASE_URL" > assets/.env.dev
echo "API_VERSION=$API_VERSION" >> assets/.env.dev
echo "APP_NAME=$APP_NAME" >> assets/.env.dev

# 4. Build
flutter config --enable-web
flutter pub get
# Bỏ renderer gây lỗi, để Flutter tự quyết định
flutter build web --release -t lib/main_admin.dart --dart-define=FLAVOR=admin
  --dart-define=FLAVOR=admin