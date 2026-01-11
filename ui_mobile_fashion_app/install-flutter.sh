# file: ui_mobile_fashion_app/install-flutter.sh dùng cho build bên netlify trước đó, nếu bạn cần
#!/bin/bash

# 1. Cài đặt Flutter
FLUTTER_DIR="$HOME/flutter"
if [ ! -d "$FLUTTER_DIR" ]; then
    git clone https://github.com/flutter/flutter.git -b stable $FLUTTER_DIR
fi
export PATH="$PATH:$FLUTTER_DIR/bin"

# 2. Thực hiện build (Bỏ phần echo tạo file .env)
flutter config --enable-web
flutter pub get
flutter build web --release -t lib/main_admin.dart --dart-define=FLAVOR=admin --no-wasm-dry-run --no-tree-shake-icons