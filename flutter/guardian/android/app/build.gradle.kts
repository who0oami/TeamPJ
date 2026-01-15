plugins {
    id("com.android.application")
    // Firebase (google-services.json 사용)
    id("com.google.gms.google-services")
    id("kotlin-android")
    // Flutter Gradle Plugin
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.a"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    defaultConfig {
        applicationId = "com.example.a"
        minSdk = flutter.minSdkVersion   // ⚠️ 반드시 21 이상
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
        // 🔥 이게 핵심 (없으면 flutter_local_notifications 에러)
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
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

dependencies {
    // 🔥 core library desugaring 필수
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.4")
}
