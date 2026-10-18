plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")
}

android {
    namespace = "com.safetyalrt.alrt.wear"
    compileSdk = 35

    defaultConfig {
        // Same application id as the phone app: the Wear Data Layer only
        // delivers a phone app's data to the watch app with the same id.
        applicationId = "com.safetyalrt.alrt"
        minSdk = 30
        targetSdk = 35
        versionCode = 1
        versionName = "1.0.0"
    }

    flavorDimensions += "default"
    productFlavors {
        create("dev") {
            dimension = "default"
            applicationIdSuffix = ".dev"
            resValue("string", "app_name", "ALRT Dev")
        }
        create("prod") {
            dimension = "default"
            resValue("string", "app_name", "ALRT")
        }
    }

    buildTypes {
        release {
            isMinifyEnabled = false
        }
    }
    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }
    kotlinOptions {
        jvmTarget = "17"
    }
}

dependencies {
    implementation("com.google.android.gms:play-services-wearable:19.0.0")
    implementation("androidx.wear:wear:1.3.0")
    implementation("androidx.core:core-ktx:1.15.0")
}
