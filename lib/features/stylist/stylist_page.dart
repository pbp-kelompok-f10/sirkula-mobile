import 'dart:math';

import 'package:flutter/material.dart';
import 'package:sirkula_mobile/core/api_client.dart';

class StylistPage extends StatefulWidget {
  const StylistPage({super.key, required this.api});

  final ApiClient api;

  @override
  State<StylistPage> createState() => _StylistPageState();
}

class _StylistPageState extends State<StylistPage> {
  final _prompt = TextEditingController();
  bool _authenticated = false;
  bool _loading = false;
  bool _sending = false;
  Object? _error;
  Object? _sendError;
  List<dynamic> _conversations = [];
  Map<String, dynamic>? _selected;
  String? _requestKey;
  String? _requestText;
  String? _requestConversation;
  int? _requestVersion;

  @override
  void initState() {
    super.initState();
    _authenticated = widget.api.isAuthenticated;
    widget.api.addListener(_authChanged);
    if (_authenticated) _load();
  }

  @override
  void didUpdateWidget(covariant StylistPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.api != widget.api) {
      oldWidget.api.removeListener(_authChanged);
      widget.api.addListener(_authChanged);
      _authenticated = widget.api.isAuthenticated;
      _conversations = [];
      _selected = null;
      if (_authenticated) _load();
    }
  }

  void _authChanged() {
    if (_authenticated == widget.api.isAuthenticated) return;
    setState(() {
      _authenticated = widget.api.isAuthenticated;
      _conversations = [];
      _selected = null;
      _error = null;
      _sendError = null;
      _prompt.clear();
      _sending = false;
      _requestKey = null;
    });
    if (_authenticated) _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final result = await widget.api.get('outfits/conversations/') as List;
      if (!mounted || !_authenticated) return;
      setState(() {
        _conversations = result;
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

  String _uuid() {
    final random = Random.secure();
    final bytes = List<int>.generate(16, (_) => random.nextInt(256));
    bytes[6] = (bytes[6] & 0x0f) | 0x40;
    bytes[8] = (bytes[8] & 0x3f) | 0x80;
    final hex = bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
    return '${hex.substring(0, 8)}-${hex.substring(8, 12)}-${hex.substring(12, 16)}-${hex.substring(16, 20)}-${hex.substring(20)}';
  }

  Future<void> _send() async {
    final text = _prompt.text.trim();
    if (text.isEmpty || _sending) return;
    final selected = _selected;
    final id = selected?['id']?.toString();
    final version = selected?['version'] as int?;
    if (_requestKey == null ||
        _requestText != text ||
        _requestConversation != id ||
        _requestVersion != version) {
      _requestKey = _uuid();
      _requestText = text;
      _requestConversation = id;
      _requestVersion = version;
    }
    setState(() {
      _sending = true;
      _sendError = null;
    });
    try {
      final response = await widget.api.post(
        id == null
            ? 'outfits/conversations/'
            : 'outfits/conversations/$id/messages/',
        {
          'prompt': text,
          'request_key': _requestKey,
          if (id != null) 'version': version,
        },
      );
      if (!mounted || !_authenticated) return;
      final conversation = Map<String, dynamic>.from(response as Map);
      setState(() {
        _selected = conversation;
        _conversations = [
          conversation,
          ..._conversations.where((c) => c['id'] != conversation['id']),
        ];
        _prompt.clear();
        _requestKey = null;
        _sending = false;
      });
    } catch (error) {
      if (!mounted || !_authenticated) return;
      setState(() {
        _sendError = error;
        _sending = false;
      });
    }
  }

  @override
  void dispose() {
    widget.api.removeListener(_authChanged);
    _prompt.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final selected = _selected;
    return Scaffold(
      appBar: selected == null
          ? null
          : AppBar(
              leading: BackButton(
                onPressed: () => setState(() {
                  _selected = null;
                  _sendError = null;
                  _prompt.clear();
                  _requestKey = null;
                }),
              ),
              title: Text(
                (selected['title']?.toString().isNotEmpty == true
                    ? selected['title'].toString()
                    : 'Percakapan'),
              ),
            ),
      body: !_authenticated
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'Masuk ke akun untuk menggunakan stylist.',
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
                      'Percakapan tidak dapat dimuat: $_error',
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
          : Column(
              children: [
                Expanded(
                  child: selected == null
                      ? RefreshIndicator(
                          onRefresh: _load,
                          child: ListView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: const EdgeInsets.all(20),
                            children: [
                              Text(
                                'Percakapan Anda',
                                style: theme.textTheme.headlineSmall,
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Mulai percakapan untuk mendapatkan rekomendasi dari lemari Anda.',
                              ),
                              const SizedBox(height: 20),
                              if (_conversations.isEmpty)
                                const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 32),
                                  child: Text(
                                    'Belum ada percakapan.',
                                    textAlign: TextAlign.center,
                                  ),
                                )
                              else
                                ..._conversations.map((entry) {
                                  final conversation =
                                      Map<String, dynamic>.from(entry as Map);
                                  final title =
                                      conversation['title']?.toString() ?? '';
                                  final messages =
                                      conversation['messages'] as List? ?? [];
                                  return Card(
                                    child: ListTile(
                                      leading: CircleAvatar(
                                        child: Icon(
                                          Icons.chat_bubble_outline,
                                          color: theme.colorScheme.primary,
                                        ),
                                      ),
                                      title: Text(
                                        title.isEmpty ? 'Percakapan' : title,
                                      ),
                                      subtitle: Text(
                                        '${messages.length} pesan',
                                      ),
                                      trailing: const Icon(Icons.chevron_right),
                                      onTap: () => setState(() {
                                        _selected = conversation;
                                        _sendError = null;
                                        _prompt.clear();
                                        _requestKey = null;
                                      }),
                                    ),
                                  );
                                }),
                            ],
                          ),
                        )
                      : ListView(
                          padding: const EdgeInsets.all(20),
                          children: [
                            ...((selected['messages'] as List?) ?? []).map((
                              entry,
                            ) {
                              final message = Map<String, dynamic>.from(
                                entry as Map,
                              );
                              final mine = message['role'] == 'user';
                              return Align(
                                alignment: mine
                                    ? Alignment.centerRight
                                    : Alignment.centerLeft,
                                child: Container(
                                  constraints: const BoxConstraints(
                                    maxWidth: 600,
                                  ),
                                  margin: const EdgeInsets.only(bottom: 12),
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    color: mine
                                        ? theme.colorScheme.primaryContainer
                                        : theme
                                              .colorScheme
                                              .surfaceContainerHighest,
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Text(
                                    message['content']?.toString() ?? '',
                                  ),
                                ),
                              );
                            }),
                            if (selected['result'] is Map &&
                                (selected['result']['pieces'] as List?)
                                        ?.isNotEmpty ==
                                    true) ...[
                              const SizedBox(height: 12),
                              Text(
                                'Rekomendasi pakaian',
                                style: theme.textTheme.titleMedium,
                              ),
                              const SizedBox(height: 8),
                              ...((selected['result']['pieces'] as List).map(
                                (piece) => ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  leading: const Icon(Icons.checkroom),
                                  title: Text(
                                    piece['name']?.toString() ?? 'Pakaian',
                                  ),
                                ),
                              )),
                            ],
                          ],
                        ),
                ),
                if (_sendError != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Pesan tidak terkirim: $_sendError',
                            style: TextStyle(color: theme.colorScheme.error),
                          ),
                        ),
                        TextButton(
                          onPressed: _sending ? null : _send,
                          child: const Text('Coba lagi'),
                        ),
                      ],
                    ),
                  ),
                SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _prompt,
                            enabled: !_sending,
                            minLines: 1,
                            maxLines: 4,
                            maxLength: 500,
                            decoration: InputDecoration(
                              labelText: selected == null
                                  ? 'Mulai percakapan'
                                  : 'Tulis pesan',
                              border: const OutlineInputBorder(),
                              counterText: '',
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton.filled(
                          onPressed: _sending ? null : _send,
                          tooltip: 'Kirim pesan',
                          icon: _sending
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.send),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
