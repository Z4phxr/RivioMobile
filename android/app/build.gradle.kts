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

    // Build Flavors for Development and Production
    flavorDimensions += "environment"
    
    productFlavors {
        create("dev") {
            dimension = "environment"
            applicationIdSuffix = ".dev"
            versionNameSuffix = "-dev"
        }
        
        create("prod") {
            dimension = "environment"
            // No suffix for production - this is the main app
        }
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
                // CI/CD environment: use env vars with absolute path
                val keystoreFile_obj = file(keystoreFile)
                if (keystoreFile_obj.exists()) {
                    storeFile = keystoreFile_obj
                    storePassword = System.getenv("KEYSTORE_PASSWORD")
                    keyAlias = System.getenv("KEY_ALIAS")
                    keyPassword = System.getenv("KEY_PASSWORD")
                } else {
                    // For debug builds, use debug keystore; for release, this would fail later
                    println("Warning: Keystore file not found at: $keystoreFile")
                }
            } else {
                // Local development: try key.properties
                val propertiesFile = rootProject.file("key.properties")
                if (propertiesFile.exists()) {
                    val properties = Properties()
                    properties.load(propertiesFile.inputStream())
                    val storeFilePath = properties.getProperty("storeFile", "")
                    if (storeFilePath.isNotEmpty() && file(storeFilePath).exists()) {
                        storeFile = file(storeFilePath)
                        storePassword = properties.getProperty("storePassword", "")
                        keyAlias = properties.getProperty("keyAlias", "")
                        keyPassword = properties.getProperty("keyPassword", "")
                    } else {
                        // For debug builds, this is OK - will use debug keystore
                        println("Warning: Keystore file not found. Using debug keystore for debug builds.")
                    }
                } else {
                    // For debug builds, this is OK - will use debug keystore
                    println("Warning: key.properties not found. Using debug keystore for debug builds.")
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
            
            // Use the appropriate signing config for release builds only
            val signingConfigName = getSigningConfig()
            if (signingConfigName == "release") {
                signingConfig = signingConfigs.getByName("release")
            }
            // Otherwise, use default debug signing
        }
        
        debug {
            // Debug suffix is handled by flavor
            isDebuggable = true
            // Debug builds always use debug keystore (no custom signing required)
        }
    }
}

flutter {
    source = "../.."
}
