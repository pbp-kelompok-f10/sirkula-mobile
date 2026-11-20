import 'package:flutter/material.dart';

import 'core/api_client.dart';
import 'features/bartering/bartering_page.dart';
import 'features/discovery/discovery_page.dart';
import 'features/marketplace/marketplace_page.dart';
import 'features/profile/profile_page.dart';
import 'features/stylist/stylist_page.dart';
import 'features/transactions/transactions_page.dart';
import 'features/wardrobe/wardrobe_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const SirkulaApp());
}

class SirkulaApp extends StatefulWidget {
  const SirkulaApp({super.key});

  @override
  State<SirkulaApp> createState() => _SirkulaAppState();
}

class _SirkulaAppState extends State<SirkulaApp> {
  late final ApiClient _api;

  @override
  void initState() {
    super.initState();
    _api = ApiClient();
    _api.restoreSession().catchError((Object _) {});
  }

  @override
  void dispose() {
    _api.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const green = Color(0xff1c472f);
    final scheme = ColorScheme.fromSeed(seedColor: green, primary: green);
    return MaterialApp(
      title: 'Sirkula',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: scheme,
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xfff8faf7),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xfff8faf7),
          foregroundColor: green,
          centerTitle: false,
        ),
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(),
        ),
      ),
      home: AppShell(api: _api),
    );
  }
}

class AppShell extends StatefulWidget {
  const AppShell({super.key, required this.api});

  final ApiClient api;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _selected = 0;

  static const _destinations = [
    (label: 'Marketplace', icon: Icons.storefront_outlined, selected: Icons.storefront),
    (label: 'Discovery Map', icon: Icons.explore_outlined, selected: Icons.explore),
    (label: 'Wardrobe', icon: Icons.checkroom_outlined, selected: Icons.checkroom),
    (label: 'AI Stylist', icon: Icons.auto_awesome_outlined, selected: Icons.auto_awesome),
    (label: 'Transaksi', icon: Icons.receipt_long_outlined, selected: Icons.receipt_long),
    (label: 'Barter', icon: Icons.swap_horiz_outlined, selected: Icons.swap_horiz),
    (label: 'Profil', icon: Icons.person_outline, selected: Icons.person),
  ];

  @override
  Widget build(BuildContext context) {
    final pages = [
      MarketplacePage(api: widget.api),
      DiscoveryPage(api: widget.api),
      WardrobePage(api: widget.api),
      StylistPage(api: widget.api),
      TransactionsPage(api: widget.api),
      BarteringPage(api: widget.api),
      ProfilePage(api: widget.api),
    ];
    return Scaffold(
      appBar: AppBar(
        title: Text(_destinations[_selected].label),
        actions: [
          IconButton(
            tooltip: 'Profil',
            onPressed: () => setState(() => _selected = 6),
            icon: const Icon(Icons.account_circle_outlined),
          ),
          const SizedBox(width: 8),
        ],
      ),
      drawer: NavigationDrawer(
        selectedIndex: _selected,
        onDestinationSelected: (index) {
          setState(() => _selected = index);
          Navigator.pop(context);
        },
        children: [
          Container(
            color: const Color(0xff1c472f),
            padding: const EdgeInsets.fromLTRB(24, 52, 24, 24),
            alignment: Alignment.centerLeft,
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Image(image: AssetImage('logo/sirkula.png'), width: 150, semanticLabel: 'Sirkula'),
                SizedBox(height: 12),
                Text('Berputar kembali, lebih berarti.', style: TextStyle(color: Colors.white)),
              ],
            ),
          ),
          const SizedBox(height: 12),
          for (final destination in _destinations)
            NavigationDrawerDestination(
              icon: Icon(destination.icon),
              selectedIcon: Icon(destination.selected),
              label: Text(destination.label),
            ),
        ],
      ),
      body: SafeArea(child: pages[_selected]),
    );
  }
}
