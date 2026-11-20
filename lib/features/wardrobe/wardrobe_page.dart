import 'package:flutter/material.dart';
import 'package:sirkula_mobile/core/api_client.dart';

class WardrobePage extends StatefulWidget {
  const WardrobePage({super.key, required this.api});

  final ApiClient api;

  @override
  State<WardrobePage> createState() => _WardrobePageState();
}

class _WardrobePageState extends State<WardrobePage> {
  bool _loading = false;
  bool _authenticated = false;
  Object? _error;
  List<dynamic> _items = [];
  Map<String, String> _categories = {};

  @override
  void initState() {
    super.initState();
    _authenticated = widget.api.isAuthenticated;
    widget.api.addListener(_authChanged);
    if (_authenticated) _load();
  }

  @override
  void didUpdateWidget(covariant WardrobePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.api != widget.api) {
      oldWidget.api.removeListener(_authChanged);
      widget.api.addListener(_authChanged);
      _authenticated = widget.api.isAuthenticated;
      _items = [];
      _categories = {};
      if (_authenticated) _load();
    }
  }

  void _authChanged() {
    if (_authenticated == widget.api.isAuthenticated) return;
    setState(() {
      _authenticated = widget.api.isAuthenticated;
      _items = [];
      _categories = {};
      _error = null;
    });
    if (_authenticated) _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final results = await Future.wait([
        widget.api.get('wardrobe/items/'),
        widget.api.get('wardrobe/categories/'),
      ]);
      if (!mounted || !_authenticated) return;
      final items = results[0] as List;
      final categories = results[1] as List;
      setState(() {
        _items = items;
        _categories = {
          for (final c in categories) '${c['id']}': '${c['name']}',
        };
        _loading = false;
      });
    } catch (error) {
      if (!mounted || !_authenticated) return;
      setState(() {
        _error = error;
        _loading = false;
      });
    }
  }

  @override
  void dispose() {
    widget.api.removeListener(_authChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: !_authenticated
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'Masuk ke akun untuk melihat lemari pakaian Anda.',
                  textAlign: TextAlign.center,
                ),
              ),
            )
          : _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Lemari tidak dapat dimuat: $_error',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    FilledButton.tonal(
                      onPressed: _load,
                      child: const Text('Coba lagi'),
                    ),
                  ],
                ),
              ),
            )
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(20),
                children: [
                  Text('Pakaian Anda', style: theme.textTheme.headlineSmall),
                  const SizedBox(height: 8),
                  Text(
                    '${_items.length} pakaian tersimpan',
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 20),
                  if (_items.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 48),
                      child: Text(
                        'Lemari Anda masih kosong.',
                        textAlign: TextAlign.center,
                      ),
                    )
                  else
                    ..._items.map((entry) {
                      final item = Map<String, dynamic>.from(entry as Map);
                      final name = (item['name'] as String?)?.trim();
                      final category = _categories['${item['category']}'];
                      final status = item['status'] == 'draft'
                          ? 'Draft'
                          : 'Aktif';
                      return Card(
                        child: ListTile(
                          leading: CircleAvatar(
                            child: Icon(
                              Icons.checkroom,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                          title: Text(
                            name == null || name.isEmpty
                                ? 'Pakaian tanpa nama'
                                : name,
                          ),
                          subtitle: Text([?category, status].join(' · ')),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () => showModalBottomSheet<void>(
                            context: context,
                            showDragHandle: true,
                            builder: (context) => SafeArea(
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(
                                  24,
                                  0,
                                  24,
                                  32,
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      name == null || name.isEmpty
                                          ? 'Pakaian tanpa nama'
                                          : name,
                                      style: theme.textTheme.headlineSmall,
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'Kategori: ${category ?? 'Belum dipilih'}',
                                    ),
                                    const SizedBox(height: 8),
                                    Text('Status: $status'),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Foto: ${(item['images'] as List?)?.length ?? 0}',
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                ],
              ),
            ),
    );
  }
}
