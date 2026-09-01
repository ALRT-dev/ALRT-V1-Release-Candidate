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

// A separate, dedicated TEST-only signing identity for the 'dev' flavour -
// deliberately a different file from key.properties (the real Play Store
// upload keystore) so the two can never be confused or accidentally
// swapped. Decoded by CI from repo secrets distinct from the real upload
// key's (see .github/workflows/android-test.yml); absent on every local
// machine and on any CI run that hasn't configured it, in which case the
// 'dev' flavour keeps falling back to the plain Android debug keystore
// exactly as before this existed - this is purely additive.
val testKeystoreProperties = Properties()
val testKeystorePropertiesFile = rootProject.file("test-key.properties")
val hasTestKeystore = testKeystorePropertiesFile.exists()
if (hasTestKeystore) {
    testKeystoreProperties.load(FileInputStream(testKeystorePropertiesFile))
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
        // Stable TEST-only identity: a real (but low-stakes, TEST-only)
        // keystore so the 'dev' flavour's signing SHA-1 stays constant
        // across CI runs, instead of a fresh one every build from the
        // default Android debug keystore - needed so a Google Maps key can
        // ever be safely restricted to this app's fingerprint in TEST.
        if (hasTestKeystore) {
            create("devTest") {
                keyAlias = testKeystoreProperties["keyAlias"] as String
                keyPassword = testKeystoreProperties["keyPassword"] as String
                // rootProject.file(), not file(): the decode step in
                // android-test.yml writes test-keystore.jks into
                // frontend/android/ (this project's rootProject), not into
                // frontend/android/app/ (this build.gradle.kts's own
                // project directory, which is what a bare file(it) call
                // resolves relative to). Using file(it) here failed the
                // very first real build against this signingConfig with
                // "Keystore file '.../app/test-keystore.jks' not found for
                // signing config 'devTest'" - devRelease had never
                // actually reached this far before (it was silently
                // signing with the debug keystore instead, per the fix
                // above this one), so the mismatched path went unnoticed
                // until now.
                storeFile = testKeystoreProperties["storeFile"]?.let { rootProject.file(it) }
                storePassword = testKeystoreProperties["storePassword"] as String
            }
        }
    }

    flavorDimensions += "default"
    productFlavors {
        create("dev") {
            dimension = "default"
            resValue("string", "app_name", "[Dev] ALRT")
            applicationIdSuffix = ".dev"
            // Set here, not in buildTypes.release below - see the comment
            // on that (now-empty) block for why. Falls back to plain debug
            // signing when test-key.properties isn't present (local
            // machines, android-apk.yml's CI environment) - unchanged,
            // intentional behaviour for that workflow's QR-code installs.
            signingConfig = if (hasTestKeystore) {
                signingConfigs.getByName("devTest")
            } else {
                signingConfigs.getByName("debug")
            }
        }
        create("prod") {
            dimension = "default"
            resValue("string", "app_name", "ALRT")
            applicationIdSuffix = ""
            // Set here, not in buildTypes.release below - see the comment
            // on that (now-empty) block. Identical condition/fallback as
            // before this moved - no behaviour change for this flavour.
            signingConfig = if (hasReleaseKeystore) {
                signingConfigs.getByName("release")
            } else {
                signingConfigs.getByName("debug")
            }
        }
    }

    buildTypes {
        release {
            // Deliberately does NOT set signingConfig - each flavour above
            // sets its own. AGP's variant merge gives a buildType's
            // signingConfig priority over a productFlavor's when both set
            // one, so setting it here (as this file used to) silently
            // discarded productFlavors.dev's devTest signingConfig on
            // every devRelease build in the android-test.yml CI
            // environment (where hasReleaseKeystore is always false, so
            // this always resolved to plain debug) - the app was never
            // actually using the stable TEST keystore despite the secrets
            // being configured and the guard step passing, which is why
            // its SHA-1 kept changing between builds. Do not reintroduce a
            // signingConfig assignment here.
        }
    }
}

// Local fail-safe: a 'prod' flavour release build must never silently ship
// debug-signed. CI (android-release.yml) already refuses to run at all
// without the real signing secrets, before Gradle is even invoked - this
// closes the same gap for anyone building `--flavor prod --release`
// directly on a machine without android/key.properties, where
// productFlavors.prod above would otherwise fall back to debug signing
// with no warning. The 'dev' flavour is deliberately unaffected by this guard:
// android-apk.yml still ships a plain debug-signed 'dev' build on purpose
// (QR-code installs), and android-test.yml now enforces its own separate
// requirement in CI (see the productFlavors.dev block above and that
// workflow's own signing-secret guard) - a local `--flavor dev --release`
// build with neither key.properties nor test-key.properties present is
// unaffected and keeps falling back to plain debug signing, same as always.
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
