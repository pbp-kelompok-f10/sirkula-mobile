import 'package:flutter/material.dart';
import 'package:sirkula_mobile/core/api_client.dart';

class MarketplacePage extends StatefulWidget {
  const MarketplacePage({super.key, required this.api});
  final ApiClient api;

  @override
  State<MarketplacePage> createState() => _MarketplacePageState();
}

class _MarketplacePageState extends State<MarketplacePage> {
  final _search = TextEditingController();
  List<dynamic> _products = [];
  bool _loading = true;
  Object? _error;
  String _query = '';
  int _request = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final request = ++_request;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final params = _query.isEmpty
          ? ''
          : '?${Uri(queryParameters: {'q': _query}).query}';
      final data = await widget.api.get('marketplace/products/$params');
      final items = data is List ? data : (data as Map)['results'] as List;
      if (!mounted || request != _request) return;
      setState(() {
        _products = items;
        _loading = false;
      });
    } catch (error) {
      if (!mounted || request != _request) return;
      setState(() {
        _error = error;
        _loading = false;
      });
    }
  }

  void _submit() {
    _query = _search.text.trim();
    FocusScope.of(context).unfocus();
    _load();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              controller: _search,
              textInputAction: TextInputAction.search,
              onSubmitted: (_) => _submit(),
              decoration: InputDecoration(
                labelText: 'Cari nama produk',
                hintText: 'Misalnya jaket',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  onPressed: _submit,
                  icon: const Icon(Icons.arrow_forward),
                  tooltip: 'Cari produk',
                ),
                border: const OutlineInputBorder(),
              ),
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Produk tidak dapat dimuat: $_error',
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 12),
                          FilledButton.tonal(
                            onPressed: _load,
                            child: const Text('Coba lagi'),
                          ),
                        ],
                      ),
                    ),
                  )
                : _products.isEmpty
                ? const Center(child: Text('Tidak ada produk yang ditemukan.'))
                : RefreshIndicator(
                    onRefresh: _load,
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final columns = constraints.maxWidth >= 900
                            ? 4
                            : constraints.maxWidth >= 600
                            ? 3
                            : 2;
                        return GridView.builder(
                          padding: const EdgeInsets.all(16),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: columns,
                                crossAxisSpacing: 12,
                                mainAxisSpacing: 12,
                                childAspectRatio: .68,
                              ),
                          itemCount: _products.length,
                          itemBuilder: (context, index) {
                            final product = Map<String, dynamic>.from(
                              _products[index] as Map,
                            );
                            return Card(
                              clipBehavior: Clip.antiAlias,
                              child: InkWell(
                                onTap: () => Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => _ProductDetailPage(
                                      api: widget.api,
                                      id: product['id'],
                                    ),
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: SizedBox(
                                        width: double.infinity,
                                        child: _ProductImage(
                                          api: widget.api,
                                          image: product['image'],
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(12),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            '${product['name'] ?? ''}',
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: theme.textTheme.titleSmall,
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            _price(product['price']),
                                            style: TextStyle(
                                              color: theme.colorScheme.primary,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          if ((product['location'] ?? '')
                                              .toString()
                                              .isNotEmpty)
                                            Text(
                                              '${product['location']}',
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: theme.textTheme.bodySmall,
                                            ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

String _price(dynamic value) {
  if (value == null || value.toString().isEmpty) {
    return 'Harga tidak dicantumkan';
  }
  final number = double.tryParse(value.toString());
  if (number == null) return 'Rp $value';
  final parts = number
      .toStringAsFixed(number.truncateToDouble() == number ? 0 : 2)
      .split('.');
  final digits = parts[0].replaceAllMapped(
    RegExp(r'\B(?=(\d{3})+(?!\d))'),
    (_) => '.',
  );
  return 'Rp $digits${parts.length > 1 ? ',${parts[1]}' : ''}';
}

class _ProductImage extends StatelessWidget {
  const _ProductImage({required this.api, required this.image});
  final ApiClient api;
  final dynamic image;

  @override
  Widget build(BuildContext context) {
    final value = image?.toString() ?? '';
    final placeholder = ColoredBox(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: const Center(child: Icon(Icons.checkroom_outlined, size: 40)),
    );
    if (value.isEmpty) return placeholder;
    final url = Uri.parse(api.baseUrl).resolve(value).toString();
    return Image.network(
      url,
      fit: BoxFit.cover,
      errorBuilder: (_, _, _) => placeholder,
    );
  }
}

class _ProductDetailPage extends StatefulWidget {
  const _ProductDetailPage({required this.api, required this.id});
  final ApiClient api;
  final dynamic id;
  @override
  State<_ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<_ProductDetailPage> {
  Map<String, dynamic>? _product;
  Object? _error;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final data = await widget.api.get('marketplace/products/${widget.id}/');
      if (!mounted) return;
      setState(() {
        _product = Map<String, dynamic>.from(data as Map);
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final product = _product;
    return Scaffold(
      appBar: AppBar(title: const Text('Detail produk')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Detail produk tidak dapat dimuat: $_error',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    FilledButton.tonal(
                      onPressed: _load,
                      child: const Text('Coba lagi'),
                    ),
                  ],
                ),
              ),
            )
          : product == null
          ? const Center(child: Text('Produk tidak ditemukan.'))
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                SizedBox(
                  height: 280,
                  child: _ProductImage(
                    api: widget.api,
                    image: product['image'],
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  '${product['name'] ?? ''}',
                  style: theme.textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(
                  _price(product['price']),
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 16),
                for (final entry in <String, dynamic>{
                  'Jenis': product['listing_type'],
                  'Merek': product['brand'],
                  'Ukuran': product['size'],
                  'Lokasi': product['location'],
                  'Lama pemakaian': product['usage_duration'],
                  'Alasan barter': product['barter_reason'],
                  'Barang yang diinginkan': product['barter_wanted'],
                  'Deskripsi': product['description'],
                }.entries)
                  if (entry.value != null &&
                      entry.value.toString().trim().isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(entry.key, style: theme.textTheme.labelLarge),
                          const SizedBox(height: 4),
                          Text('${entry.value}'),
                        ],
                      ),
                    ),
                if (product['gallery'] is List &&
                    (product['gallery'] as List).isNotEmpty) ...[
                  Text('Galeri', style: theme.textTheme.titleMedium),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 140,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: (product['gallery'] as List).length,
                      separatorBuilder: (_, _) => const SizedBox(width: 8),
                      itemBuilder: (_, index) => SizedBox(
                        width: 140,
                        child: _ProductImage(
                          api: widget.api,
                          image: (product['gallery'] as List)[index]['image'],
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
    );
  }
}
