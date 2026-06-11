# Flutter specific
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

# Firebase
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }

# Drift / SQLite
-keep class * extends androidx.room.** { *; }
-dontwarn net.sqlcipher.**

# Keep serialization models
-keep class com.timbo.timbo_app.** { *; }

# Just Audio
-keep class com.ryanheise.audioservice.** { *; }

# Google Sign-In
-keep class com.google.android.gms.auth.** { *; }
