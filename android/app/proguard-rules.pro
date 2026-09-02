# ---------------------------------------------------------------------------
# F2.1b — regras necessárias para o build de RELEASE (R8) dos dois flavors.
#
# O tflite_flutter referencia o delegate de GPU por reflexão; sem estas regras
# o R8 aborta com "Missing class org.tensorflow.lite.gpu.GpuDelegateFactory".
# O delegate é opcional em runtime (Plano B da F1.4, hoje desligado), mas o
# bytecode que o menciona entra no APK de qualquer forma.
# ---------------------------------------------------------------------------
-dontwarn org.tensorflow.lite.gpu.**
-keep class org.tensorflow.lite.gpu.** { *; }
-keep class org.tensorflow.lite.** { *; }
