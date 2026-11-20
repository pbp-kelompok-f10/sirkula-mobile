import 'package:flutter/material.dart';
import 'package:sirkula_mobile/core/api_client.dart';

class BarteringPage extends StatefulWidget {
  const BarteringPage({super.key, required this.api});

  final ApiClient api;

  @override
  State<BarteringPage> createState() => _BarteringPageState();
}

class _BarteringPageState extends State<BarteringPage> {
  List<dynamic>? _offers;
  List<dynamic>? _transactions;
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
  void didUpdateWidget(covariant BarteringPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.api != widget.api) {
      oldWidget.api.removeListener(_onApiChanged);
      _request++;
      _authenticated = widget.api.isAuthenticated;
      widget.api.addListener(_onApiChanged);
      _offers = null;
      _transactions = null;
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
      _offers = null;
      _transactions = null;
      _error = null;
      _loading = false;
    });
    if (authenticated) _load();
  }

  List<dynamic> _list(dynamic response) {
    final data = response is List ? response : (response as Map)['results'];
    if (data is! List) {
      throw const FormatException('Respons barter tidak valid');
    }
    return data;
  }

  Future<void> _load() async {
    final request = ++_request;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final responses = await Future.wait([
        widget.api.get('bartering/offers/'),
        widget.api.get('bartering/transactions/'),
      ]);
      final offers = _list(responses[0]);
      final transactions = _list(responses[1]);
      if (!mounted || request != _request) return;
      setState(() {
        _offers = offers;
        _transactions = transactions;
      });
    } catch (error) {
      if (!mounted || request != _request) return;
      setState(() => _error = error);
    } finally {
      if (mounted && request == _request) setState(() => _loading = false);
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
      content = const _Message(
        icon: Icons.lock_outline,
        title: 'Masuk untuk melihat barter',
        description: 'Silakan masuk melalui halaman akun terlebih dahulu.',
      );
    } else if (_loading) {
      content = const Center(child: CircularProgressIndicator());
    } else if (_error != null) {
      content = _Message(
        icon: Icons.error_outline,
        title: 'Barter tidak dapat dimuat',
        description: '$_error',
        onRetry: _load,
      );
    } else if ((_offers?.isEmpty ?? true) && (_transactions?.isEmpty ?? true)) {
      content = const _Message(
        icon: Icons.swap_horiz,
        title: 'Belum ada barter',
        description: 'Penawaran dan transaksi barter Anda akan muncul di sini.',
      );
    } else {
      content = RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              'Penawaran barter',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            if (_offers!.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Text('Belum ada penawaran barter.'),
              ),
            for (final offer in _offers!)
              _OfferCard(offer: Map<String, dynamic>.from(offer as Map)),
            const SizedBox(height: 16),
            Text(
              'Transaksi barter',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            if (_transactions!.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Text('Belum ada transaksi barter.'),
              ),
            for (final transaction in _transactions!)
              _TransactionCard(
                transaction: Map<String, dynamic>.from(transaction as Map),
              ),
          ],
        ),
      );
    }
    return Scaffold(body: content);
  }
}

class _OfferCard extends StatelessWidget {
  const _OfferCard({required this.offer});
  final Map<String, dynamic> offer;

  @override
  Widget build(BuildContext context) => Card(
    margin: const EdgeInsets.only(bottom: 12),
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Penawaran #${offer['id']}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              Chip(label: Text(_status('${offer['status']}'))),
            ],
          ),
          const SizedBox(height: 8),
          Text('Produk ditawarkan: #${offer['offered_product']}'),
          Text('Produk diminta: #${offer['requested_product']}'),
          if ((offer['message'] as String? ?? '').isNotEmpty) ...[
            const SizedBox(height: 8),
            Text('Pesan: ${offer['message']}'),
          ],
          if ((offer['proposer_tracking_number'] as String? ?? '').isNotEmpty)
            Text('Resi pengaju: ${offer['proposer_tracking_number']}'),
          if ((offer['recipient_tracking_number'] as String? ?? '').isNotEmpty)
            Text('Resi penerima: ${offer['recipient_tracking_number']}'),
          if (offer['created_at'] != null) ...[
            const SizedBox(height: 8),
            Text(
              'Dibuat: ${_date(offer['created_at'])}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ],
      ),
    ),
  );
}

class _TransactionCard extends StatelessWidget {
  const _TransactionCard({required this.transaction});
  final Map<String, dynamic> transaction;

  @override
  Widget build(BuildContext context) => Card(
    margin: const EdgeInsets.only(bottom: 12),
    child: ListTile(
      leading: const Icon(Icons.swap_horiz),
      title: Text('Transaksi #${transaction['id']}'),
      subtitle: Text(
        'Penawaran #${transaction['offer']}\nDibuat: ${_date(transaction['created_at'])}${transaction['completed_at'] == null ? '' : '\nSelesai: ${_date(transaction['completed_at'])}'}',
      ),
      isThreeLine: true,
    ),
  );
}

String _status(String value) => switch (value) {
  'PENDING' => 'Menunggu keputusan',
  'ACCEPTED' => 'Diterima',
  'SHIPPING' => 'Dalam pengiriman',
  'COMPLETED' => 'Selesai',
  'REJECTED' => 'Ditolak',
  'CANCELLED' => 'Dibatalkan',
  _ => value,
};

String _date(dynamic value) {
  final date = DateTime.tryParse(value.toString())?.toLocal();
  if (date == null) return value.toString();
  return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
}

class _Message extends StatelessWidget {
  const _Message({
    required this.icon,
    required this.title,
    required this.description,
    this.onRetry,
  });
  final IconData icon;
  final String title;
  final String description;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 48, color: Theme.of(context).colorScheme.primary),
          const SizedBox(height: 16),
          Text(
            title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(description, textAlign: TextAlign.center),
          if (onRetry != null) ...[
            const SizedBox(height: 16),
            FilledButton.tonal(
              onPressed: onRetry,
              child: const Text('Coba lagi'),
            ),
          ],
        ],
      ),
    ),
  );
}
