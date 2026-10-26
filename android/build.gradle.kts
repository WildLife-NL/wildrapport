import org.gradle.api.tasks.compile.JavaCompile

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}

subprojects {
    tasks.withType<JavaCompile>().configureEach {
        // Suppress obsolete source/target 8 warnings from older transitive plugins.
        options.compilerArgs.add("-Xlint:-options")
    }
}

// AGP 9 + android.builtInKotlin=false: many Flutter plugins skip applying KGP when
// agpMajor >= 9, then crash configuring KotlinAndroidProjectExtension. Apply KGP
// ourselves as soon as the Android library plugin is applied.
subprojects {
    pluginManager.withPlugin("com.android.library") {
        if (!pluginManager.hasPlugin("org.jetbrains.kotlin.android") &&
            !pluginManager.hasPlugin("kotlin-android")
        ) {
            pluginManager.apply("org.jetbrains.kotlin.android")
        }
    }
}

// Old Flutter plugins (e.g. geocoding_android) still pin compileSdk 33 while
// androidx dependencies require 34+. Force a modern compileSdk for all Android modules.
// Must register this BEFORE evaluationDependsOn(":app"), otherwise :app is already
// evaluated and afterEvaluate throws.
subprojects {
    fun Project.forceCompileSdk36() {
        val androidExt = extensions.findByName("android") ?: return
        try {
            val setCompileSdk = androidExt.javaClass.methods
                .firstOrNull { it.name == "setCompileSdk" && it.parameterCount == 1 }
            if (setCompileSdk != null) {
                setCompileSdk.invoke(androidExt, 36)
            } else {
                androidExt.javaClass.methods
                    .firstOrNull { it.name == "setCompileSdkVersion" && it.parameterCount == 1 }
                    ?.invoke(androidExt, 36)
            }
        } catch (_: Exception) {
            // Non-Android subprojects or incompatible AGP extension — ignore.
        }
    }

    if (state.executed) {
        forceCompileSdk36()
    } else {
        afterEvaluate { forceCompileSdk36() }
    }
}

subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
