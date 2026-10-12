import 'package:url_launcher/url_launcher.dart';

/// Páginas legais. Precisam estar publicadas antes do envio às lojas
/// (a Apple exige Termos e Privacidade no paywall).
abstract final class LegalLinks {
  static final privacy = Uri.parse('https://podecomerapp.com.br/privacidade');
  static final terms = Uri.parse('https://podecomerapp.com.br/termos');
}

Future<bool> openLink(Uri uri) =>
    launchUrl(uri, mode: LaunchMode.externalApplication);
