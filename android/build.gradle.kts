allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    // tflite_flutter ainda fixa compileSdkVersion 31, abaixo do minimo exigido
    // por dependencias transitivas (androidx.window.extensions.core 1.0.0 pede
    // 33+). Alinha todo plugin ao compileSdk do :app. Registrado antes do
    // evaluationDependsOn abaixo, que ja deixa :app avaliado.
    afterEvaluate {
        val android = extensions.findByType<com.android.build.api.dsl.LibraryExtension>()
        if (android != null && (android.compileSdk ?: 0) < 36) {
            android.compileSdk = 36
        }
    }

    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
