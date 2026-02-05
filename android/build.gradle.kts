import org.gradle.api.tasks.Delete
import java.io.File

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir = File(rootProject.projectDir, "../build")
rootProject.buildDir = newBuildDir

subprojects {
    buildDir = File(rootProject.buildDir, project.name)
}

subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.buildDir)
}
