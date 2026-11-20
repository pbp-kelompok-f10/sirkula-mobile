import 'package:flutter/material.dart';
import 'package:sirkula_mobile/core/api_client.dart';

class TransactionsPage extends StatefulWidget {
  const TransactionsPage({super.key, required this.api});

  final ApiClient api;

  @override
  State<TransactionsPage> createState() => _TransactionsPageState();
}

class _TransactionsPageState extends State<TransactionsPage> {
  List<dynamic>? _orders;
  Object? _error;
  bool _loading = false;
  late bool _authenticated;
  int _request = 0;

  @override
  void initState() {
    super.initState();
    _authenticated = widget.api.isAuthenticated;
    widget.api.addListener(_onApiChanged);
    if (_authenticated) _load();
  }

  @override
  void didUpdateWidget(covariant TransactionsPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.api != widget.api) {
      oldWidget.api.removeListener(_onApiChanged);
      _request++;
      _authenticated = widget.api.isAuthenticated;
      widget.api.addListener(_onApiChanged);
      _orders = null;
      _error = null;
      _loading = false;
      if (_authenticated) _load();
    }
  }

  void _onApiChanged() {
    final authenticated = widget.api.isAuthenticated;
    if (authenticated == _authenticated) return;
    setState(() {
      _request++;
      _authenticated = authenticated;
      _orders = null;
      _error = null;
      _loading = false;
    });
    if (authenticated) _load();
  }

  Future<void> _load() async {
    final request = ++_request;
    final api = widget.api;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final response = await api.get('transactions/orders/');
      final data = response is List ? response : (response as Map)['results'];
      if (data is! List) throw const FormatException('Respons pesanan tidak valid');
      if (!mounted || api != widget.api || request != _request) return;
      setState(() => _orders = data);
    } catch (error) {
      if (!mounted || api != widget.api || request != _request) return;
      setState(() => _error = error);
    } finally {
      if (mounted && api == widget.api && request == _request) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  void dispose() {
    widget.api.removeListener(_onApiChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget content;
    if (!_authenticated) {
      content = const _Message(icon: Icons.lock_outline, title: 'Masuk untuk melihat pesanan', description: 'Silakan masuk melalui halaman akun terlebih dahulu.');
    } else if (_loading) {
      content = const Center(child: CircularProgressIndicator());
    } else if (_error != null) {
      content = _Message(icon: Icons.error_outline, title: 'Pesanan tidak dapat dimuat', description: '$_error', onRetry: _load);
    } else if (_orders == null || _orders!.isEmpty) {
      content = const _Message(icon: Icons.receipt_long_outlined, title: 'Belum ada pesanan', description: 'Pesanan pembelian dan penjualan Anda akan muncul di sini.');
    } else {
      content = RefreshIndicator(
        onRefresh: _load,
        child: ListView.builder(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          itemCount: _orders!.length,
          itemBuilder: (context, index) {
            final order = Map<String, dynamic>.from(_orders![index] as Map);
            final items = order['items'] as List? ?? [];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    Expanded(child: Text('${order['order_number']}', style: Theme.of(context).textTheme.titleMedium)),
                    Chip(label: Text(_status('${order['status']}'))),
                  ]),
                  const SizedBox(height: 8),
                  Text('${items.length} barang · Total Rp ${order['total']}'),
                  const SizedBox(height: 4),
                  Text('Pengiriman: ${order['shipping_method']} · Pembayaran: ${order['payment_status']}'),
                  if (order['created_at'] != null) ...[
                    const SizedBox(height: 4),
                    Text('Dibuat: ${_date(order['created_at'])}', style: Theme.of(context).textTheme.bodySmall),
                  ],
                  if (items.isNotEmpty) ...[
                    const Divider(height: 24),
                    for (final item in items)
                      Padding(padding: const EdgeInsets.only(bottom: 4), child: Text('Produk #${item['product']} · Rp ${item['price']}')),
                  ],
                ]),
              ),
            );
          },
        ),
      );
    }
    return Scaffold(appBar: AppBar(title: const Text('Pesanan')), body: content);
  }
}

String _status(String value) => switch (value) {
  'PENDING' => 'Menunggu konfirmasi',
  'CONFIRMED' => 'Dikonfirmasi',
  'SHIPPED' => 'Dikirim',
  'COMPLETED' => 'Selesai',
  'CANCELLED' => 'Dibatalkan',
  _ => value,
};

String _date(dynamic value) {
  final date = DateTime.tryParse(value.toString())?.toLocal();
  if (date == null) return value.toString();
  return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
}

class _Message extends StatelessWidget {
  const _Message({required this.icon, required this.title, required this.description, this.onRetry});
  final IconData icon;
  final String title;
  final String description;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 48, color: Theme.of(context).colorScheme.primary),
        const SizedBox(height: 16),
        Text(title, textAlign: TextAlign.center, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        Text(description, textAlign: TextAlign.center),
        if (onRetry != null) ...[
          const SizedBox(height: 16),
          FilledButton.tonal(onPressed: onRetry, child: const Text('Coba lagi')),
        ],
      ]),
    ),
  );
}
