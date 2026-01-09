#!/bin/bash
# Tải Flutter SDK (Nhánh stable)
git clone https://github.com/flutter/flutter.git -b stable $HOME/flutter

# Thêm Flutter vào PATH
export PATH="$PATH:$HOME/flutter/bin"

# Chạy tiền kiểm tra và tải các build tools cần thiết
flutter doctor

# Chạy lệnh build của bạn
flutter build web --release -t lib/main_admin.dart --dart-define=FLAVOR=admin