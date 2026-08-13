plugins {
    id("com.android.application")
    id("kotlin-android")
    // إضافة الإضافة الخاصة بالفلاتر
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.generator_app" // قم باستبداله باسم الباكيج الخاص بمشروعك إذا كان مختلفًا
    compileSdk = 34

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_1_8
        targetCompatibility = JavaVersion.VERSION_1_8
    }

    kotlinOptions {
        jvmTarget = "1.8"
    }

    defaultConfig {
        applicationId = "com.example.generator_app" // قم باستبداله باسم الباكيج الخاص بك
        minSdk = 21
        targetSdk = 34
        versionCode = 1
        versionName = "1.0.0"
    }

    buildTypes {
        release {
            // التوقيع الافتراضي للبناء النسبي
            signingConfig = signingConfigs.getByName("debug")
            isMinifyEnabled = false
            isShrinkResources = false
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    implementation("org.jetbrains.kotlin:kotlin-stdlib-jdk7")
}
