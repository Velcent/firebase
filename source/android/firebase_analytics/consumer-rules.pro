####################################
# Firebase
####################################
-keep class com.google.firebase.** { *; }
-dontwarn com.google.firebase.**

####################################
# Google Play Tasks
####################################
-keep class com.google.android.gms.tasks.** { *; }
-dontwarn com.google.android.gms.tasks.**

####################################
# Kotlin (ktx / reflection)
####################################
-keep class kotlin.Metadata { *; }
-keep class kotlin.** { *; }
-dontwarn kotlin.**

####################################
# Godot Firebase Plugin
####################################
-keep class com.godotx.firebase.** { *; }
-dontwarn com.godotx.firebase.**

-keepclassmembers class com.godotx.firebase.** {
    public <init>(org.godotengine.godot.Godot);
}
