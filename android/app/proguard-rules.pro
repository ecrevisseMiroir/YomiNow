# google_mlkit_text_recognition references the Chinese, Devanagari and Korean
# recognizer options, but the app only bundles the Japanese model. R8 would
# otherwise fail release builds on the missing classes.
-dontwarn com.google.mlkit.vision.text.chinese.**
-dontwarn com.google.mlkit.vision.text.devanagari.**
-dontwarn com.google.mlkit.vision.text.korean.**
