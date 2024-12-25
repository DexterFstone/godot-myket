import com.android.build.gradle.internal.tasks.factory.dependsOn

plugins {
    id("com.android.library")
//    id("org.jetbrains.kotlin.android")
}

// TODO: Update value to your plugin's name.
val pluginName = "GodotMyket"

// TODO: Update value to match your plugin's package name.
val pluginPackageName = "com.example.godotmyket"

android {
    namespace = pluginPackageName
    compileSdk = 33

    buildFeatures {
        buildConfig = true
    }

    defaultConfig {
        minSdk = 24

        manifestPlaceholders["godotPluginName"] = pluginName
        manifestPlaceholders["godotPluginPackageName"] = pluginPackageName
        buildConfigField("String", "GODOT_PLUGIN_NAME", "\"${pluginName}\"")
        setProperty("archivesBaseName", pluginName)
//        val marketApplicationId = "ir.mservices.market"
//        val marketBindAddress = "ir.mservices.market.InAppBillingService.BIND"
//        manifestPlaceholders.apply {
//            this["marketApplicationId"] = marketApplicationId
//            this["marketBindAddress"] = marketBindAddress
//            this["marketPermission"] = "${marketApplicationId}.BILLING"
//        }
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }
//    kotlinOptions {
//        jvmTarget = "17"
//    }
}

dependencies {
    implementation("org.godotengine:godot:4.2.0.stable")
    // TODO: Additional dependencies should be added to export_plugin.gd as well.
    implementation("com.github.myketstore:myket-billing-client:1.6")

    testImplementation("junit:junit:4.13.2")
}