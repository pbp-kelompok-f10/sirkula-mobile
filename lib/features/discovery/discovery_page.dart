import 'package:flutter/material.dart';
import 'package:sirkula_mobile/core/api_client.dart';

class DiscoveryPage extends StatefulWidget {
  const DiscoveryPage({super.key, required this.api});
  final ApiClient api;

  @override
  State<DiscoveryPage> createState() => _DiscoveryPageState();
}

class _DiscoveryPageState extends State<DiscoveryPage> {
  final _search = TextEditingController();
  List<dynamic> _locations = [];
  Map<String, dynamic>? _nearby;
  String? _location;
  String _query = '';
  double _radius = 3;
  bool _loading = true;
  Object? _error;
  int _request = 0;

  @override
  void initState() { super.initState(); _loadLocations(); }

  @override
  void dispose() { _search.dispose(); super.dispose(); }

  Future<void> _loadLocations() async {
    setState(() { _loading = true; _error = null; });
    try {
      final data = await widget.api.get('marketplace/map/locations/');
      final locations = data is List ? data : (data as Map)['results'] as List;
      if (!mounted) return;
      setState(() {
        _locations = locations;
        if (_location == null && locations.isNotEmpty) _location = locations.first['slug'].toString();
      });
      await _loadNearby();
    } catch (error) {
      if (!mounted) return;
      setState(() { _error = error; _loading = false; });
    }
  }

  Future<void> _loadNearby() async {
    final request = ++_request;
    setState(() { _loading = true; _error = null; });
    try {
      final params = <String, String>{'radius': _radius.toString(), if (_location != null) 'location': _location!, if (_query.isNotEmpty) 'q': _query};
      final data = await widget.api.get('marketplace/map/nearby/?${Uri(queryParameters: params).query}');
      if (!mounted || request != _request) return;
      setState(() { _nearby = Map<String, dynamic>.from(data as Map); _loading = false; });
    } catch (error) {
      if (!mounted || request != _request) return;
      setState(() { _error = error; _loading = false; });
    }
  }

  void _showListing(Map<String, dynamic> listing) {
    final store = listing['store'];
    showModalBottomSheet<void>(context: context, isScrollControlled: true, showDragHandle: true, builder: (context) => SafeArea(child: SingleChildScrollView(padding: EdgeInsets.fromLTRB(24, 0, 24, 24 + MediaQuery.viewInsetsOf(context).bottom), child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
      Text('${listing['title'] ?? ''}', style: Theme.of(context).textTheme.headlineSmall),
      const SizedBox(height: 12),
      if ((listing['image_url'] ?? '').toString().isNotEmpty) Padding(padding: const EdgeInsets.only(bottom: 16), child: SizedBox(height: 200, width: double.infinity, child: Image.network(Uri.parse(widget.api.baseUrl).resolve(listing['image_url'].toString()).toString(), fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.image_not_supported_outlined)))),
      for (final entry in <String, dynamic>{'Harga': listing['price'] == null ? null : 'Rp ${listing['price']}', 'Jenis': listing['listing_type_label'], 'Toko': store is Map ? store['name'] : null, 'Jarak': listing['distance_km'] == null ? null : '${listing['distance_km']} km', 'Deskripsi': listing['description']}.entries)
        if (entry.value != null && entry.value.toString().trim().isNotEmpty) Padding(padding: const EdgeInsets.only(bottom: 12), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(entry.key, style: Theme.of(context).textTheme.labelLarge), const SizedBox(height: 4), Text('${entry.value}')])),
    ]))));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final stores = _nearby?['stores'] is List ? _nearby!['stores'] as List : [];
    final listings = _nearby?['listings'] is List ? _nearby!['listings'] as List : [];
    final center = _nearby?['center'];
    return Scaffold(appBar: AppBar(title: const Text('Temukan di sekitar')), body: ListView(padding: const EdgeInsets.all(16), children: [
      Text('Jelajahi lokasi', style: theme.textTheme.headlineSmall),
      const SizedBox(height: 6),
      Text('Temukan toko dan produk berdasarkan lokasi dan radius.', style: theme.textTheme.bodyMedium),
      const SizedBox(height: 20),
      if (_locations.isNotEmpty) DropdownButtonFormField<String>(
        initialValue: _location,
        decoration: const InputDecoration(labelText: 'Lokasi', border: OutlineInputBorder(), prefixIcon: Icon(Icons.location_on_outlined)),
        isExpanded: true,
        items: _locations.map((location) => DropdownMenuItem<String>(value: location['slug'].toString(), child: Text('${location['name']}', overflow: TextOverflow.ellipsis))).toList(),
        onChanged: (value) { if (value != null) { setState(() => _location = value); _loadNearby(); } },
      ),
      const SizedBox(height: 12),
      TextField(controller: _search, textInputAction: TextInputAction.search, onSubmitted: (_) { _query = _search.text.trim(); _loadNearby(); }, decoration: InputDecoration(labelText: 'Cari produk atau toko', prefixIcon: const Icon(Icons.search), border: const OutlineInputBorder(), suffixIcon: IconButton(icon: const Icon(Icons.arrow_forward), tooltip: 'Cari', onPressed: () { _query = _search.text.trim(); FocusScope.of(context).unfocus(); _loadNearby(); }))),
      const SizedBox(height: 16),
      Row(children: [Text('Radius', style: theme.textTheme.titleSmall), const Spacer(), Text('${_radius.toStringAsFixed(0)} km')]),
      Slider(value: _radius, min: 1, max: 100, divisions: 99, label: '${_radius.toStringAsFixed(0)} km', onChanged: (value) => setState(() => _radius = value), onChangeEnd: (_) => _loadNearby()),
      if (_loading) const Padding(padding: EdgeInsets.all(32), child: Center(child: CircularProgressIndicator()))
      else if (_error != null) Padding(padding: const EdgeInsets.all(24), child: Column(children: [Text('Lokasi dan hasil tidak dapat dimuat: $_error', textAlign: TextAlign.center), const SizedBox(height: 12), FilledButton.tonal(onPressed: _locations.isEmpty ? _loadLocations : _loadNearby, child: const Text('Coba lagi'))]))
      else ...[
        if (center is Map && center['label'] != null) Padding(padding: const EdgeInsets.only(bottom: 16), child: Text('Di sekitar ${center['label']}', style: theme.textTheme.bodyMedium)),
        Row(children: [Expanded(child: Text('Toko terdekat', style: theme.textTheme.titleLarge)), Text('${stores.length} hasil')]),
        const SizedBox(height: 8),
        if (stores.isEmpty) const Padding(padding: EdgeInsets.symmetric(vertical: 16), child: Text('Tidak ada toko dalam radius ini.')),
        for (final item in stores) Card(child: ListTile(leading: const Icon(Icons.storefront_outlined), title: Text('${item['name'] ?? ''}'), subtitle: Text('${item['address'] ?? ''}'), trailing: Text('${item['distance_km']} km'), onTap: () => showDialog<void>(context: context, builder: (context) => AlertDialog(title: Text('${item['name'] ?? ''}'), content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [Text('${item['address'] ?? ''}'), if ((item['description'] ?? '').toString().isNotEmpty) ...[const SizedBox(height: 12), Text('${item['description']}')], const SizedBox(height: 12), Text('${item['distance_km']} km')])), actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Tutup'))])))),
        const SizedBox(height: 24),
        Row(children: [Expanded(child: Text('Produk terdekat', style: theme.textTheme.titleLarge)), Text('${listings.length} hasil')]),
        const SizedBox(height: 8),
        if (listings.isEmpty) const Padding(padding: EdgeInsets.symmetric(vertical: 16), child: Text('Tidak ada produk dalam radius ini.')),
        for (final item in listings) Card(child: ListTile(leading: const Icon(Icons.checkroom_outlined), title: Text('${item['title'] ?? ''}'), subtitle: Text('${item['store'] is Map ? item['store']['name'] : ''} · ${item['distance_km']} km'), trailing: const Icon(Icons.chevron_right), onTap: () => _showListing(Map<String, dynamic>.from(item as Map)))),
      ],
    ]));
  }
}
