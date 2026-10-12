# Regras do R8 para o build de release.
# Os plugins (RevenueCat, ML Kit, câmera) já trazem as próprias regras de keep;
# aqui só silenciamos referências opcionais que não existem no app.

# ML Kit: só usamos o reconhecedor latino; os outros scripts não são incluídos.
-dontwarn com.google.mlkit.vision.text.chinese.**
-dontwarn com.google.mlkit.vision.text.devanagari.**
-dontwarn com.google.mlkit.vision.text.japanese.**
-dontwarn com.google.mlkit.vision.text.korean.**

# Flutter: componentes adiados (Play Core) não são usados.
-dontwarn com.google.android.play.core.**
