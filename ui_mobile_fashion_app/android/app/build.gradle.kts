plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.ui_mobile_fashion_app"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    // Định nghĩa flavor dimensions (yêu cầu cho multi-flavor)
    flavorDimensions.add("default")

    // Định nghĩa 2 flavors: customer và admin
    productFlavors {
        create("customer") {
            dimension = "default"
            applicationId = "com.example.ui_mobile_fashion_app.customer"  // Bundle ID riêng cho customer
            resValue("string", "app_name", "Fashion App Customer")  // Tên app động (hiển thị trên device)
            // Thêm config khác nếu cần, ví dụ: versionCode = 1, versionName = "1.0-customer"
        }
        create("admin") {
            dimension = "default"
            applicationId = "com.example.ui_mobile_fashion_app.admin"  // Bundle ID riêng cho admin
            resValue("string", "app_name", "Fashion App Admin")  // Tên app động
            // Thêm config khác nếu cần
        }
    }

    // Config sourceSets để tách code/res per flavor
    sourceSets {
        getByName("main").apply {
            // Config chung (nếu cần, ví dụ: java.srcDirs("src/main/kotlin"))
        }

        getByName("customer").apply {
            manifest.srcFile("src/customer/AndroidManifest.xml")  // Bỏ comment: Sử dụng manifest riêng cho customer
            java.srcDirs("src/customer/kotlin", "src/debug/kotlin")
            res.srcDirs("src/customer/res")
            resources.srcDirs("src/customer/resources")
            assets.srcDirs("src/customer/assets")
        }

        getByName("admin").apply {
            manifest.srcFile("src/admin/AndroidManifest.xml")  // Bỏ comment: Sử dụng manifest riêng cho admin
            java.srcDirs("src/admin/kotlin", "src/debug/kotlin")
            res.srcDirs("src/admin/res")
            resources.srcDirs("src/admin/resources")
            assets.srcDirs("src/admin/assets")
        }
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.example.ui_mobile_fashion_app"  // Default, sẽ override bởi flavor
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        debug {
            // Explicit debug để tránh cross-flavor build
            applicationIdSuffix = ".debug"
            signingConfig = signingConfigs.getByName("debug")
        }
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }

    // Rename output APK để Flutter tìm thấy (workaround cho flavors)
    applicationVariants.all {
        outputs.all {
            val variant = this@all
            val output = this
            val outputImpl = output as com.android.build.gradle.internal.api.BaseVariantOutputImpl
            when (variant.name) {
                "customerDebug", "adminDebug" -> {
                    outputImpl.outputFileName = "app-debug.apk"
                }
                "customerRelease", "adminRelease" -> {
                    outputImpl.outputFileName = "app-release.apk"
                }
            }
        }
    }
}

flutter {
    source = "../.."
}
