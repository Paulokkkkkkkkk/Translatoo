plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.translatoo.app"
    compileSdk = flutter.compileSdkVersion
    // whisper_ggml exige NDK 29.0.13113456, acima do padrao do Flutter.
    // NDKs sao retrocompativeis: fixamos o maior exigido pelos plugins.
    ndkVersion = "29.0.13113456"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        applicationId = "com.translatoo.app"
        // PRD §4: Android 6.0+ (requisito dos plugins ML Kit / Vosk / TFLite).
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        // Uses the version code from pubspec.yaml. When using split APKs, 1000 * ABI_VERSION
        // is added automatically by Flutter. (https://developer.android.com/studio/build/configure-apk-splits#configure-APK-versions)
        // You can force using the value of versionCode by specifying the `-P force-version-code-ignoring-abi=true`
        // flag during build.
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    // F2.1b - PRD 4.7: duas variantes de tamanho. O modelo ggml embarcado em
    // cada uma e selecionado pelos `flavors:` do pubspec; aqui fica so a
    // dimensao de build e o sufixo que permite as duas lado a lado no device.
    flavorDimensions += "models"
    productFlavors {
        create("lite") {
            dimension = "models"
            applicationIdSuffix = ".lite"
            versionNameSuffix = "-lite"
        }
        create("full") {
            dimension = "models"
        }
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro",
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
