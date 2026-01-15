plugins {
    id("com.android.application")
    id("com.google.gms.google-services")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.a"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    // 🔥 핵심 1: desugaring 활성화
    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
        isCoreLibraryDesugaringEnabled = true   // ⭐ 이 줄 추가
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        applicationId = "com.example.a"

        // 🔥 핵심 2: minSdk는 반드시 21 이상
        minSdk = flutter.minSdkVersion   // ⭐ flutter.minSdkVersion 쓰지 말고 직접 21로
        targetSdk = flutter.targetSdkVersion

        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}

// 🔥 핵심 3: desugaring 라이브러리 추가
dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.4")
}
