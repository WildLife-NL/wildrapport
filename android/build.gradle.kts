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
    project.evaluationDependsOn(":app")
}

subprojects {
    tasks.withType<JavaCompile>().configureEach {
        // Suppress obsolete source/target 8 warnings from older transitive plugins.
        options.compilerArgs.add("-Xlint:-options")
    }
}

// Old Flutter plugins (e.g. geocoding_android) still pin compileSdk 33 while
// androidx dependencies require 34+. Force a modern compileSdk for all Android modules.
subprojects {
    afterEvaluate {
        val androidExt = extensions.findByName("android") ?: return@afterEvaluate
        try {
            val compileSdkField = androidExt.javaClass.methods
                .firstOrNull { it.name == "setCompileSdk" && it.parameterCount == 1 }
            if (compileSdkField != null) {
                compileSdkField.invoke(androidExt, 36)
            } else {
                val legacy = androidExt.javaClass.methods
                    .firstOrNull { it.name == "setCompileSdkVersion" && it.parameterCount == 1 }
                legacy?.invoke(androidExt, 36)
            }
        } catch (_: Exception) {
            // Non-Android subprojects or incompatible AGP extension — ignore.
        }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
