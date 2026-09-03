plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "ai.djaber.djaber_mobile"

    // Pinned rather than `flutter.compileSdkVersion`: flutter_secure_storage 11
    // requires its consumers to compile against API 37 or later.
    compileSdk = 37
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        applicationId = "ai.djaber.djaber_mobile"

        // API 24 (Android 7.0) is Flutter's floor and covers the low-end
        // Xiaomi / Oppo / Infinix / Tecno handsets that dominate this market.
        minSdk = 24
        targetSdk = flutter.targetSdkVersion

        versionCode = flutter.versionCode
        versionName = flutter.versionName

        // The app ships Arabic, French and English. Dropping every other
        // locale from the bundled AndroidX resources trims the APK, which
        // matters on metered mobile data.
        resourceConfigurations += listOf("en", "fr", "ar")
    }

    buildTypes {
        release {
            // TODO: replace with a real signing config before store submission.
            // Signing with the debug keys for now, so `flutter run --release`
            // works. Blocked on the same ship checklist as the IP-based
            // backend hostname (brief Q12).
            signingConfig = signingConfigs.getByName("debug")

            // R8 with Flutter's own rules. APK size is a real constraint here:
            // merchants install over mobile data, often on a device with very
            // little free storage.
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro",
            )
        }
    }

    packaging {
        resources {
            excludes += setOf(
                "META-INF/DEPENDENCIES",
                "META-INF/LICENSE*",
                "META-INF/NOTICE*",
            )
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}
