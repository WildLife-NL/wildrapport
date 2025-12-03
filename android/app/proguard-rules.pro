-keep class com.example.wildrapport.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.embedding.** { *; }

-dontwarn io.flutter.embedding.**
-dontwarn android.**

# Keep ALL classes - aggressive but will fix the issue
-dontobfuscate
-optimizations !code/simplification/arithmetic,!code/simplification/cast,!field/*,!class/merging/*

# Keep flutter_map and related classes
-keep class net.tlalka.flutter.map.** { *; }
-keep class com.mapbox.** { *; }

# Keep Geolocator
-keep class com.baseflow.geolocator.** { *; }

# Keep HTTP and networking classes
-keep class okhttp3.** { *; }
-keep class okio.** { *; }
-dontwarn okhttp3.**
-dontwarn okio.**

# Keep JSON serialization
-keepattributes Signature
-keepattributes *Annotation*
-keepattributes EnclosingMethod
-keepattributes InnerClasses

# Keep all model classes for JSON deserialization
-keep class ** implements android.os.Parcelable { *; }
-keepclassmembers class * {
    @com.google.gson.annotations.SerializedName <fields>;
}

# Preserve line numbers for debugging
-keepattributes SourceFile,LineNumberTable
-renamesourcefileattribute SourceFile