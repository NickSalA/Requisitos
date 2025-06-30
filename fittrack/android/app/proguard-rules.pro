# Evita que ProGuard elimine clases de TensorFlow Lite
-keep class org.tensorflow.** { *; }

# Mantiene las clases relacionadas con GPU Delegate
-keep class org.tensorflow.lite.gpu.** { *; }
-keep class org.tensorflow.lite.gpu.GpuDelegateFactory$Options { *; }

# Suprime advertencias relacionadas con clases faltantes (según `missing_rules.txt`)
-dontwarn org.tensorflow.lite.gpu.GpuDelegateFactory$Options
