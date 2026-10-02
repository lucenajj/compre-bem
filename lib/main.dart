import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'screens/cart_screen.dart';
import 'screens/compare_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/login_screen.dart';
import 'screens/scanner_screen.dart';
import 'store/app_store.dart';
import 'utils/format.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initFormatting();
  final store = AppStore();
  await store.init();
  runApp(ChangeNotifierProvider.value(value: store, child: const CompreBemApp()));
}

class CompreBemApp extends StatelessWidget {
  const CompreBemApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Compre Bem',
      debugShowCheckedModeBanner: false,
      locale: const Locale('pt', 'BR'),
      supportedLocales: const [Locale('pt', 'BR')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1E9E57)),
        useMaterial3: true,
      ),
      home: const AuthGate(),
    );
  }
}

/// Mostra o login ou o app, conforme a sessão salva no aparelho.
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final ready = context.select<AppStore, bool>((s) => s.ready);
    final loggedIn = context.select<AppStore, bool>((s) => s.isLoggedIn);
    if (!ready) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return loggedIn ? const HomeShell() : const LoginScreen();
  }
}

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  // No desktop (web) a aba Escanear não existe: o leitor de código
  // de barras só faz sentido no celular, no supermercado.
  static const _screens = [
    if (!kIsWeb) ScannerScreen(),
    CartScreen(),
    CompareScreen(),
    DashboardScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final cartCount = context.select<AppStore, int>((s) => s.cartCount);
    return Scaffold(
      appBar: AppBar(
        title: const Text('🛒 Compre Bem'),
        actions: [
          IconButton(
            tooltip: 'Sair',
            icon: const Icon(Icons.logout),
            onPressed: () => context.read<AppStore>().logout(),
          ),
        ],
      ),
      body: IndexedStack(index: _index, children: _screens),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: [
          if (!kIsWeb)
            const NavigationDestination(
                icon: Icon(Icons.qr_code_scanner), label: 'Escanear'),
          NavigationDestination(
            icon: Badge(
              label: Text('$cartCount'),
              isLabelVisible: cartCount > 0,
              child: const Icon(Icons.shopping_basket),
            ),
            label: 'Compra',
          ),
          const NavigationDestination(
              icon: Icon(Icons.compare_arrows), label: 'Comparar'),
          const NavigationDestination(
              icon: Icon(Icons.dashboard), label: 'Dashboard'),
        ],
      ),
    );
  }
}
