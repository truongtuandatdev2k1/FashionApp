# file: ui_mobile_fashion_app/install-flutter.sh
#!/bin/bash

# 1. Kiểm tra và cài đặt Flutter (tránh lỗi đã tồn tại thư mục)
if [ ! -d "$HOME/flutter" ]; then
    git clone https://github.com/flutter/flutter.git -b stable $HOME/flutter
fi

export PATH="$PATH:$HOME/flutter/bin"

# 2. Tạo thư mục assets và file env
mkdir -p assets
echo "API_BASE_URL=$API_BASE_URL" > assets/.env.dev
echo "API_VERSION=$API_VERSION" >> assets/.env.dev
echo "APP_NAME=$APP_NAME" >> assets/.env.dev

# 3. Nâng cấp và chuẩn bị
flutter upgrade
flutter config --enable-web

# 4. Build (Sửa lại thứ tự tham số để tránh lỗi Option)
flutter pub get
flutter build web --release \
  --web-renderer html \
  --target lib/main_admin.dart \
  --dart-define=FLAVOR=admin