# Flutter and its plugins ship their own consumer rules; this file only holds
# what is specific to this app.

# Keep model classes' generic signatures. Nothing here uses reflection today,
# but stripping signatures is what silently breaks JSON handling the moment
# something does.
-keepattributes Signature
-keepattributes *Annotation*

# Readable stack traces from a release build. Without this an obfuscated crash
# report from a merchant's phone is unusable.
-keepattributes SourceFile,LineNumberTable
-renamesourcefileattribute SourceFile

# ---- flutter_secure_storage ----
#
# This is where the JWT lives, so a failure here is a release-only "cannot log
# in" with no visible cause.
#
# The plugin writes the name of its cipher algorithm into SharedPreferences and
# resolves it back by name on the next launch. R8 does not see that as a use of
# the enum's constants, and with minification on it removed the class outright:
#
#   com.it_nomads.fluttersecurestorage.ciphers.StorageCipherAlgorithm
#       -> R8$$REMOVED$$CLASS$$82
#
# Verify after any dependency bump by grepping mapping.txt for REMOVED against
# this package; the rules below should keep it out of that list.
-keep class com.it_nomads.fluttersecurestorage.** { *; }
-keepclassmembers enum com.it_nomads.fluttersecurestorage.** { *; }

# Any enum resolved from a stored or serialised name. `proguard-android-
# optimize.txt` keeps `values()` and `valueOf()`, but not the constants those
# operate on, and R8's enum unboxing is happy to rewrite what is left.
-keepclassmembers enum * {
    public static **[] values();
    public static ** valueOf(java.lang.String);
}

# ---- webview_flutter ----
#
# The OAuth step runs entirely inside this plugin, so if it fails in release
# the merchant cannot connect a Page at all.
#
# Its Android side is a Pigeon-generated bridge whose objects are created on
# demand from Dart. R8 removed the registrar that owns that bridge:
#
#   io.flutter.plugins.webviewflutter.AndroidWebkitLibraryPigeonProxyApiRegistrar
#
# along with 54 other classes in the package. Some of that is genuinely unused
# API surface, but the registrar is not optional, and this is not a path that
# can be checked by reading — it either works on a handset or it does not.
# Kept whole until the flow has actually been run from a release build.
-keep class io.flutter.plugins.webviewflutter.** { *; }

# ---- Note on scope ----
#
# Only the Java/Kotlin layer is at risk here. The Dart code is compiled ahead
# of time into libapp.so and R8 never sees it, so the app's own models, enums
# and JSON parsing cannot be broken this way — the exposure is limited to the
# plugins.
