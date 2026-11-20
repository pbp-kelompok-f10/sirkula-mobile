import 'package:flutter/material.dart';
import 'package:sirkula_mobile/core/api_client.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key, required this.api});

  final ApiClient api;

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  Map<String, dynamic>? _profile;
  String? _error;
  bool _loading = false;
  bool _submitting = false;
  bool _obscurePassword = true;
  int _request = 0;
  late bool _authenticated;

  @override
  void initState() {
    super.initState();
    _authenticated = widget.api.isAuthenticated;
    widget.api.addListener(_onApiChanged);
    if (_authenticated) _loadProfile();
  }

  @override
  void didUpdateWidget(covariant ProfilePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.api != widget.api) {
      oldWidget.api.removeListener(_onApiChanged);
      _request++;
      _authenticated = widget.api.isAuthenticated;
      _profile = null;
      _error = null;
      _loading = false;
      widget.api.addListener(_onApiChanged);
      if (_authenticated) _loadProfile();
    }
  }

  void _onApiChanged() {
    final authenticated = widget.api.isAuthenticated;
    if (authenticated == _authenticated) return;
    _authenticated = authenticated;
    _request++;
    if (!mounted) return;
    setState(() {
      _profile = null;
      _error = null;
      _loading = false;
    });
    if (authenticated) _loadProfile();
  }

  Future<void> _loadProfile() async {
    final request = ++_request;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final data = await widget.api.get('accounts/profile/');
      if (data is! Map) {
        throw const FormatException('Format profil tidak dikenali.');
      }
      if (!mounted || request != _request) return;
      setState(() => _profile = Map<String, dynamic>.from(data));
    } catch (error) {
      if (!mounted || request != _request) return;
      setState(() => _error = 'Gagal memuat profil: $error');
    } finally {
      if (mounted && request == _request) setState(() => _loading = false);
    }
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      await widget.api.login(_email.text.trim(), _password.text);
      _password.clear();
      if (mounted && widget.api.isAuthenticated && !_authenticated) {
        _onApiChanged();
      }
    } catch (error) {
      if (mounted) setState(() => _error = 'Gagal masuk: $error');
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  Future<void> _logout() async {
    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      await widget.api.logout();
      if (mounted && widget.api.isAuthenticated != _authenticated) {
        _onApiChanged();
      }
    } catch (error) {
      if (mounted) setState(() => _error = 'Gagal keluar: $error');
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  void dispose() {
    _request++;
    widget.api.removeListener(_onApiChanged);
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  String _value(String key) => _profile?[key]?.toString().trim() ?? '';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: _authenticated ? _buildProfile(theme) : _buildLogin(theme),
          ),
        ),
      ),
    );
  }

  Widget _buildLogin(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Icon(
              Icons.account_circle_outlined,
              size: 56,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(height: 20),
            Text(
              'Masuk ke Sirkula',
              style: theme.textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Masuk untuk melihat profil dan menggunakan akunmu.',
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 28),
            TextFormField(
              controller: _email,
              enabled: !_submitting,
              keyboardType: TextInputType.emailAddress,
              autofillHints: const [AutofillHints.email],
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
              validator: (value) => (value == null || value.trim().isEmpty)
                  ? 'Masukkan email.'
                  : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _password,
              enabled: !_submitting,
              obscureText: _obscurePassword,
              autofillHints: const [AutofillHints.password],
              onFieldSubmitted: (_) {
                if (!_submitting) _login();
              },
              decoration: InputDecoration(
                labelText: 'Kata sandi',
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  tooltip: _obscurePassword
                      ? 'Tampilkan kata sandi'
                      : 'Sembunyikan kata sandi',
                  onPressed: () =>
                      setState(() => _obscurePassword = !_obscurePassword),
                  icon: Icon(
                    _obscurePassword
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                  ),
                ),
              ),
              validator: (value) => (value == null || value.isEmpty)
                  ? 'Masukkan kata sandi.'
                  : null,
            ),
            if (_error != null) ...[
              const SizedBox(height: 16),
              Text(_error!, style: TextStyle(color: theme.colorScheme.error)),
            ],
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _submitting ? null : _login,
              child: Text(_submitting ? 'Sedang masuk…' : 'Masuk'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfile(ThemeData theme) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_profile == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _error ?? 'Profil belum tersedia.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              FilledButton.tonal(
                onPressed: _loadProfile,
                child: const Text('Coba lagi'),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: _submitting ? null : _logout,
                child: const Text('Keluar'),
              ),
            ],
          ),
        ),
      );
    }
    final displayName = _value('display_name');
    final fullName = _value('full_name');
    final username = _value('username');
    final name = displayName.isNotEmpty
        ? displayName
        : (fullName.isNotEmpty ? fullName : username);
    final avatar = _value('avatar');
    final avatarUrl = avatar.isEmpty
        ? null
        : Uri.tryParse(widget.api.baseUrl)?.resolve(avatar).toString();
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        CircleAvatar(
          radius: 40,
          backgroundColor: theme.colorScheme.primaryContainer,
          foregroundColor: theme.colorScheme.onPrimaryContainer,
          foregroundImage: avatarUrl == null ? null : NetworkImage(avatarUrl),
          child: const Icon(Icons.person_outline, size: 40),
        ),
        const SizedBox(height: 16),
        Text(
          name.isEmpty ? 'Profil' : name,
          textAlign: TextAlign.center,
          style: theme.textTheme.headlineSmall,
        ),
        if (_value('email').isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(
            _value('email'),
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium,
          ),
        ],
        const SizedBox(height: 28),
        Text('Informasi profil', style: theme.textTheme.titleMedium),
        const SizedBox(height: 8),
        _profileField('Nama lengkap', fullName),
        _profileField('Nama pengguna', username),
        _profileField('Lokasi', _value('location')),
        _profileField('Bio', _value('bio')),
        _profileField('Skor reputasi', _value('reputation_score')),
        _profileField('Skor kualitas barang', _value('item_quality_score')),
        _profileField('Transaksi berhasil', _value('successful_transactions')),
        if (_error != null) ...[
          const SizedBox(height: 16),
          Text(_error!, style: TextStyle(color: theme.colorScheme.error)),
        ],
        const SizedBox(height: 24),
        OutlinedButton.icon(
          onPressed: _submitting ? null : _logout,
          icon: const Icon(Icons.logout),
          label: Text(_submitting ? 'Sedang keluar…' : 'Keluar'),
        ),
      ],
    );
  }

  Widget _profileField(String label, String value) {
    if (value.isEmpty) return const SizedBox.shrink();
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(label),
      subtitle: Text(value),
    );
  }
}
