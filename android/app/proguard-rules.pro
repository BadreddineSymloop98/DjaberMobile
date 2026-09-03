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
