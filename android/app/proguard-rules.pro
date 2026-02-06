# Flutter Proguard Rules
# Keep all Flutter classes
-keep class io.flutter.** { *; }
-keep class io.flutter.embedding.** { *; }
-dontwarn io.flutter.**

# Keep Dart classes used via reflection
-keep class * extends io.flutter.embedding.android.FlutterActivity { *; }
-keep class * extends io.flutter.embedding.android.FlutterFragment { *; }

# Dio (HTTP client)
-keepattributes Signature
-keepattributes *Annotation*
-keep class com.google.gson.** { *; }
-keep class retrofit2.** { *; }

# Gson (JSON serialization)
-keepattributes Signature
-keep class sun.misc.Unsafe { *; }
-keep class com.google.gson.stream.** { *; }

# Keep model classes (adjust package name as needed)
-keep class com.rivio.habits.** { *; }

# FlutterSecureStorage
-keep class com.it_nomads.fluttersecurestorage.** { *; }

# Prevent obfuscation of serialized classes
-keepclassmembers class * {
  @com.google.gson.annotations.SerializedName <fields>;
}

# Keep native methods
-keepclasseswithmembernames class * {
    native <methods>;
}

# Preserve line numbers for debugging
-keepattributes SourceFile,LineNumberTable
-renamesourcefileattribute SourceFile
