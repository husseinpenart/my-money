plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.money"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID
        // https://developer.android.com/studio/build/application-id.html
        applicationId = "com.example.money"

        // 👇 security-crypto معمولاً حداقل API 23 می‌خواهد
        minSdk = maxOf(flutter.minSdkVersion, 23)

        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // فعلاً با debug sign می‌شود تا flutter run --release کار کند.
            // برای انتشار واقعی حتماً keystore/release sign را جایگزین کن.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

// 👇 این بخش مشکل Could not find androidx.security:security-crypto:1.1.0 را حل می‌کند
configurations.all {
    resolutionStrategy {
        force("androidx.security:security-crypto:1.1.0-alpha06")
    }
}

flutter {
    source = "../.."
}