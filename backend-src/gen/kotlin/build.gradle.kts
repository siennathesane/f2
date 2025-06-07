plugins {
    kotlin("jvm") version "2.1.20"
    idea
}

group = "dev.f2"
version = "1.0-SNAPSHOT"

repositories {
    mavenCentral()
}

dependencies {
    implementation("com.google.protobuf:protobuf-java:4.30.2")
    implementation("com.google.protobuf:protobuf-kotlin:4.30.2")
    testImplementation(kotlin("test"))
}

tasks.test {
    useJUnitPlatform()
}

kotlin {
    jvmToolchain(23)
}

sourceSets {
    main {
        kotlin {
            srcDir("src/main/proto")
        }
    }
}

idea {
    module {
        sourceDirs.addAll(files("src/main/kotlin"))
    }
}