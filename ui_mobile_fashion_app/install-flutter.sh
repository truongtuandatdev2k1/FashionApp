# file: ui_mobile_fashion_app/install-flutter.sh
#!/bin/bash
# 1. Cài đặt Flutter
git clone https://github.com/flutter/flutter.git -b stable $HOME/flutter
export PATH="$PATH:$HOME/flutter/bin"

# 2. TẠO THƯ MỤC ASSETS VÀ FILE .env.dev
mkdir -p assets
echo "API_BASE_URL=$API_BASE_URL" > assets/.env.dev
echo "API_VERSION=$API_VERSION" >> assets/.env.dev
echo "APP_NAME=$APP_NAME" >> assets/.env.dev

# 3. Build
flutter pub get
flutter build web --release -t lib/main_admin.dart --dart-define=FLAVOR=admin