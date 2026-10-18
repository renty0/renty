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
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}

subprojects {
    val configureAction = Action<Project> {
        if (hasProperty("android")) {
            val android = extensions.getByName("android")
            try {
                val getNamespace = android.javaClass.getMethod("getNamespace")
                val namespace = getNamespace.invoke(android) as? String
                if (namespace.isNullOrEmpty()) {
                    val setNamespace = android.javaClass.getMethod("setNamespace", String::class.java)
                    val pkg = group.toString().ifEmpty { 
                        "com.yasser.renty.${name.replace("-", "_").replace(":", "_")}" 
                    }
                    setNamespace.invoke(android, pkg)
                }
            } catch (e: Exception) {}

            try {
                val compileOptions = android.javaClass.getMethod("getCompileOptions").invoke(android)
                val setSourceCompatibility = compileOptions.javaClass.getMethod("setSourceCompatibility", Any::class.java)
                val setTargetCompatibility = compileOptions.javaClass.getMethod("setTargetCompatibility", Any::class.java)
                val javaVersion17 = javaClass.classLoader.loadClass("org.gradle.api.JavaVersion").getField("VERSION_17").get(null)
                setSourceCompatibility.invoke(compileOptions, javaVersion17)
                setTargetCompatibility.invoke(compileOptions, javaVersion17)
            } catch (e: Exception) {}

            try {
                val kotlinOptions = android.javaClass.getMethod("getKotlinOptions").invoke(android)
                val setJvmTarget = kotlinOptions.javaClass.getMethod("setJvmTarget", String::class.java)
                setJvmTarget.invoke(kotlinOptions, "17")
            } catch (e: Exception) {}
        }
    }

    if (state.executed) {
        configureAction.execute(this)
    } else {
        afterEvaluate(configureAction)
    }

    tasks.withType<JavaCompile>().configureEach {
        sourceCompatibility = "17"
        targetCompatibility = "17"
    }

    tasks.configureEach {
        if (this.javaClass.name.contains("KotlinCompile")) {
            try {
                val kotlinOptions = this.javaClass.getMethod("getKotlinOptions").invoke(this)
                val setJvmTarget = kotlinOptions.javaClass.getMethod("setJvmTarget", String::class.java)
                setJvmTarget.invoke(kotlinOptions, "17")
            } catch (e: Exception) {}
        }
    }
}
