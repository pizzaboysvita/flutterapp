plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after Android and Kotlin plugins
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services") // Firebase plugin
}

android {
    namespace = "com.example.pizza_boys" // Your app package name
    compileSdk = flutter.compileSdkVersion // Compile SDK version from Flutter config
    ndkVersion = flutter.ndkVersion // Optional: NDK version from Flutter config

    defaultConfig {
        applicationId = "com.example.pizza_boys" // App ID
        minSdk = 23 // Minimum supported Android version
        targetSdk = 35
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    // Java & Kotlin options
    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
        // Required for flutter_local_notifications and AndroidX libraries
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    buildTypes {
        release {
            // Signing config for release builds
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.." // Path to Flutter project
}

dependencies {
    // Firebase BoM
    implementation(platform("com.google.firebase:firebase-bom:34.3.0"))

    // Local notifications
    implementation("androidx.core:core-ktx:1.12.0")

    // ✅ Updated desugar_jdk_libs version to 2.1.4 or higher
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")

    // Firebase products
    implementation("com.google.firebase:firebase-analytics")
}



