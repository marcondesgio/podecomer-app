import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/app_localizations.dart';
import 'routes.dart';

/// Barra inferior: Início · [Escanear] · Meu Grupo · Meu Perfil.
/// O botão central (68 px) abre o scanner em tela cheia.
class HomeShell extends StatelessWidget {
  const HomeShell({super.key, required this.shell});

  final StatefulNavigationShell shell;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    void go(int branch) =>
        shell.goBranch(branch, initialLocation: branch == shell.currentIndex);

    Widget item(int branch, IconData icon, String label) {
      final selected = shell.currentIndex == branch;
      return Expanded(
        child: InkWell(
          onTap: () => go(branch),
          child: Semantics(
            selected: selected,
            button: true,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    icon,
                    color: selected ? scheme.primary : scheme.onSurfaceVariant,
                  ),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                      color: selected
                          ? scheme.primary
                          : scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      body: shell,
      bottomNavigationBar: Material(
        color: scheme.surfaceContainer,
        child: SafeArea(
          // Sem altura fixa: cresce com a fonte dinâmica do sistema.
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                item(0, Icons.home_outlined, l10n.navHome),
                Expanded(
                  child: Center(
                    heightFactor: 1,
                    child: SizedBox.square(
                      dimension: 68,
                      child: FloatingActionButton(
                        heroTag: null,
                        tooltip: l10n.navScan,
                        shape: const CircleBorder(),
                        onPressed: () => context.push(AppRoutes.scanner),
                        child: const Icon(Icons.qr_code_scanner, size: 32),
                      ),
                    ),
                  ),
                ),
                item(1, Icons.group_outlined, l10n.groupTitle),
                item(2, Icons.person_outline, l10n.profileTitle),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
