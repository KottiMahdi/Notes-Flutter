# Flutter and Firebase ship their own consumer rules; keep only what reflection needs.
-keep class io.flutter.** { *; }
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }
-dontwarn com.google.android.play.core.**
-keepattributes Signature,*Annotation*,EnclosingMethod,InnerClasses
