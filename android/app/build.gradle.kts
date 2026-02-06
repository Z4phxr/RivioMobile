import java.util.Properties

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.rivio.habits"
    compileSdk = 36

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = "17"
    }

    sourceSets {
        getByName("main").java.srcDirs("src/main/kotlin")
    }

    defaultConfig {
        applicationId = "com.rivio.habits"
        minSdk = flutter.minSdkVersion
        targetSdk = 36
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    // Helper function to safely get signing config
    fun getSigningConfig(): String {
        // Priority 1: Environment variables (GitHub Actions)
        val keystoreFile = System.getenv("KEYSTORE_FILE")
        if (keystoreFile != null && keystoreFile.isNotEmpty()) {
            return "release"
        }

        // Priority 2: key.properties file (local development)
        val propertiesFile = rootProject.file("android/key.properties")
        if (propertiesFile.exists()) {
            return "release"
        }

        // Priority 3: Fallback to debug keystore
        return "debug"
    }

    signingConfigs {
        create("release") {
            val keystoreFile = System.getenv("KEYSTORE_FILE")
            
            if (keystoreFile != null && keystoreFile.isNotEmpty()) {
                // CI/CD environment: use env vars
                storeFile = file(keystoreFile)
                storePassword = System.getenv("KEYSTORE_PASSWORD")
                keyAlias = System.getenv("KEY_ALIAS")
                keyPassword = System.getenv("KEY_PASSWORD")
            } else {
                // Local development: try key.properties
                val propertiesFile = rootProject.file("android/key.properties")
                if (propertiesFile.exists()) {
                    val properties = Properties()
                    properties.load(propertiesFile.inputStream())
                    storeFile = file(properties.getProperty("storeFile", ""))
                    storePassword = properties.getProperty("storePassword", "")
                    keyAlias = properties.getProperty("keyAlias", "")
                    keyPassword = properties.getProperty("keyPassword", "")
                }
            }
        }
    }

    buildTypes {
        release {
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
            
            // Use the appropriate signing config
            signingConfig = signingConfigs.getByName(getSigningConfig())
        }
        
        debug {
            applicationIdSuffix = ".debug"
            versionNameSuffix = "-debug"
        }
    }
}

flutter {
    source = "../.."
}
