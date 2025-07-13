# Lindungi SharedPreferences
-keep class android.content.SharedPreferences { *; }
-keep class android.content.SharedPreferences$Editor { *; }

# Firebase dan Firestore
-keep class com.google.firebase.** { *; }
-dontwarn com.google.firebase.**

# ML Kit (kalau kamu pakai)
-keep class com.google.mlkit.** { *; }
-dontwarn com.google.mlkit.**

# Cegah penghapusan kelas Flutter plugin
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.embedding.** { *; }

# Optional: Cegah penghapusan semua class milik app
-keep class com.example.dombaku.** { *; }
