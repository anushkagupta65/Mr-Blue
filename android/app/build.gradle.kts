import java.util.Properties

plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

val keystorePropertiesFile = file("../key.properties")
val keystoreProperties = Properties().apply {
    if (keystorePropertiesFile.exists()) {
        load(keystorePropertiesFile.inputStream())
    }
}

println("Keystore File: ${keystoreProperties.getProperty("storeFile")}")
println("Store Password: ${keystoreProperties.getProperty("storePassword")}")
println("Key Alias: ${keystoreProperties.getProperty("keyAlias")}")
println("Key Password: ${keystoreProperties.getProperty("keyPassword")}")


android {
    namespace = "com.mrblue"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.mrblue"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        create("release") {
            storeFile = file(keystoreProperties.getProperty("storeFile"))
            storePassword = keystoreProperties.getProperty("storePassword")
            keyAlias = keystoreProperties.getProperty("keyAlias")
            keyPassword = keystoreProperties.getProperty("keyPassword")
        }
    }

    buildTypes {
        named("release") {
            signingConfig = signingConfigs.getByName("release")
            isMinifyEnabled = true           // or false if you don't want shrinking
            isShrinkResources = true         // or false if you're skipping shrinking
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }

}

flutter {
    source = "../.."
}

dependencies {
    implementation("com.google.android.gms:play-services-maps:18.2.0")
}