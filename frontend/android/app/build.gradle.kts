import java.util.Properties
import java.io.FileInputStream
import org.gradle.api.GradleException

plugins {
    id("com.android.application")
    // START: FlutterFire Configuration
    id("com.google.gms.google-services")
    // END: FlutterFire Configuration
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
val hasReleaseKeystore = keystorePropertiesFile.exists()
if (hasReleaseKeystore) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

// Google Maps API key — injected into the manifest at build time, never committed.
// Resolved from (in order): the GOOGLE_MAPS_API_KEY environment variable (CI), then the
// project's .env file (the same file flutter_dotenv loads at runtime).
val mapsApiKey: String = run {
    System.getenv("GOOGLE_MAPS_API_KEY")?.takeIf { it.isNotBlank() }?.let { return@run it }
    val envFile = rootProject.file("../.env")
    if (envFile.exists()) {
        val envProps = Properties()
        envFile.inputStream().use { envProps.load(it) }
        (envProps.getProperty("GOOGLE_MAPS_API_KEY"))?.takeIf { it.isNotBlank() }?.let { return@run it }
    }
    ""
}

android {
    namespace = "com.safetyalrt.alrt"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
        // Required by flutter_local_notifications >= 18 (java.time backport).
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.safetyalrt.alrt"
        minSdk = flutter.minSdkVersion
        targetSdk = 35 // Play requires >= 35; pinned per Aug 2026 audit
        versionCode = flutter.versionCode
        versionName = flutter.versionName

        // Substituted into com.google.android.geo.API_KEY in AndroidManifest.xml.
        manifestPlaceholders["MAPS_API_KEY"] = mapsApiKey
    }

    // Only define the release signing config when key.properties is present.
    // Without it (e.g. a fresh machine missing the upload keystore), release builds
    // fall back to debug signing so local device testing still works — but such a
    // build is NOT accepted by the Play Store.
    signingConfigs {
        if (hasReleaseKeystore) {
            create("release") {
                keyAlias = keystoreProperties["keyAlias"] as String
                keyPassword = keystoreProperties["keyPassword"] as String
                storeFile = keystoreProperties["storeFile"]?.let { file(it) }
                storePassword = keystoreProperties["storePassword"] as String
            }
        }
    }

    flavorDimensions += "default"
    productFlavors {
        create("dev") {
            dimension = "default"
            resValue("string", "app_name", "[Dev] ALRT")
            applicationIdSuffix = ".dev"
        }
        create("prod") {
            dimension = "default"
            resValue("string", "app_name", "ALRT")
            applicationIdSuffix = ""
        }
    }

    buildTypes {
        release {
            signingConfig = if (hasReleaseKeystore) {
                signingConfigs.getByName("release")
            } else {
                signingConfigs.getByName("debug")
            }
        }
    }
}

// Local fail-safe: a 'prod' flavour release build must never silently ship
// debug-signed. CI (android-release.yml) already refuses to run at all
// without the real signing secrets, before Gradle is even invoked - this
// closes the same gap for anyone building `--flavor prod --release`
// directly on a machine without android/key.properties, where the
// buildTypes block above would otherwise fall back to debug signing with
// no warning. The 'dev' flavour is deliberately unaffected:
// android-apk.yml and android-test.yml both build a debug-signed 'dev'
// release on purpose, for TEST/QR-code installs.
afterEvaluate {
    tasks.matching { task ->
        task.name.contains("Prod") &&
            task.name.contains("Release") &&
            (task.name.startsWith("assemble") || task.name.startsWith("bundle"))
    }.configureEach {
        doFirst {
            if (!hasReleaseKeystore) {
                throw GradleException(
                    "Refusing to build a 'prod' flavour release: the real upload " +
                        "keystore is not configured (android/key.properties is " +
                        "missing). This build would otherwise silently fall back to " +
                        "debug signing under the real com.safetyalrt.alrt app id - " +
                        "not acceptable for anything beyond local device testing. " +
                        "See .github/workflows/android-release.yml's header comment " +
                        "for how to create/configure the real upload keystore."
                )
            }
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.5")
}
