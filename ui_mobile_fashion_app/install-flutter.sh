# file: ui_mobile_fashion_app/install-flutter.sh
#!/bin/bash

# 1. Cài Flutter nếu chưa có
if [ ! -d "$HOME/flutter" ]; then
  git clone https://github.com/flutter/flutter.git -b stable $HOME/flutter
fi

export PATH="$PATH:$HOME/flutter/bin"

# 2. Tạo thư mục assets và file .env
mkdir -p assets
echo "API_BASE_URL=$API_BASE_URL" > assets/.env.dev
echo "API_VERSION=$API_VERSION" >> assets/.env.dev
echo "APP_NAME=$APP_NAME" >> assets/.env.dev

# 3. Update Flutter và enable web (nếu cần)
flutter upgrade
flutter config --enable-web

# 4. Lấy dependencies
flutter pub get

# 5. Build web – KHÔNG dùng --web-renderer nữa
# Dùng --release và chỉ định entry-point nếu cần
flutter build web --release \
  -t lib/main_admin.dart \
  --dart-define=FLAVOR=admin