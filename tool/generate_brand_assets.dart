// Gera ícone e splash PROVISÓRIOS nas cores do Design System v2.0
// (jabuticaba, massa, manga), inspirados na "Mordidinha": um biscoito
// mordido com farelos e o ponto em manga.
//
// Substitua os PNGs de assets/branding/ pelo logo oficial exportado do
// Design System e rode de novo:
//   dart run flutter_launcher_icons
//   dart run flutter_native_splash:create
//
// Uso: dart run tool/generate_brand_assets.dart
import 'dart:io';

import 'package:image/image.dart' as img;

final jabuticaba = img.ColorRgba8(0x5B, 0x2A, 0x7A, 0xFF);
final massa = img.ColorRgba8(0xFF, 0xF8, 0xF0, 0xFF);
final manga = img.ColorRgba8(0xFF, 0x8F, 0x5E, 0xFF);
final transparent = img.ColorRgba8(0, 0, 0, 0);

/// Desenha a marca centrada em (cx, cy) com escala [s] (1 = 1024 px).
/// [bite] é a cor da "mordida" (a cor do fundo).
void drawMark(img.Image image, int cx, int cy, double s, img.Color bite) {
  int v(num n) => (n * s).round();
  // Biscoito.
  img.fillCircle(image, x: cx, y: cy - v(40), radius: v(300), color: massa, antialias: true);
  // Mordida: três círculos da cor do fundo no canto superior direito.
  for (final (dx, dy, r) in [(250, -270, 110), (320, -150, 95), (150, -350, 90)]) {
    img.fillCircle(image, x: cx + v(dx), y: cy + v(dy), radius: v(r), color: bite, antialias: true);
  }
  // Farelos.
  for (final (dx, dy, r) in [(420, -330, 22), (390, -60, 16), (470, -200, 12)]) {
    img.fillCircle(image, x: cx + v(dx), y: cy + v(dy), radius: v(r), color: massa, antialias: true);
  }
  // O ponto (manga).
  img.fillCircle(image, x: cx, y: cy + v(370), radius: v(70), color: manga, antialias: true);
}

img.Image canvas(int size, img.Color background) =>
    img.Image(width: size, height: size, numChannels: 4)..clear(background);

void save(String path, img.Image image) {
  File(path)
    ..createSync(recursive: true)
    ..writeAsBytesSync(img.encodePng(image));
  stdout.writeln('gerado $path');
}

void main() {
  const dir = 'assets/branding';

  // Ícone completo (iOS e Android legado): fundo jabuticaba.
  final icon = canvas(1024, jabuticaba);
  drawMark(icon, 512, 512, 1, jabuticaba);
  save('$dir/icon.png', icon);

  // Android adaptativo: só a marca, dentro da zona segura (66%).
  final foreground = canvas(1024, transparent);
  drawMark(foreground, 512, 512, 0.62, transparent);
  save('$dir/icon_foreground.png', foreground);

  // Splash: marca sobre jabuticaba em círculo, para fundo claro ou escuro.
  final splash = canvas(768, transparent);
  img.fillCircle(splash, x: 384, y: 384, radius: 384, color: jabuticaba, antialias: true);
  drawMark(splash, 384, 384, 0.6, jabuticaba);
  save('$dir/splash_logo.png', splash);

  // Android 12+: ícone central de 960 px com a marca dentro de 640 px.
  final android12 = canvas(960, transparent);
  img.fillCircle(android12, x: 480, y: 480, radius: 320, color: jabuticaba, antialias: true);
  drawMark(android12, 480, 480, 0.5, jabuticaba);
  save('$dir/splash_android12.png', android12);
}
