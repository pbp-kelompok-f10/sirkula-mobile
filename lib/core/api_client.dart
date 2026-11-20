import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class ApiException implements Exception {
  const ApiException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => message;
}

class ApiClient extends ChangeNotifier {
  ApiClient({http.Client? client, FlutterSecureStorage? storage})
    : _client = client ?? http.Client(),
      _storage = storage ?? const FlutterSecureStorage();

  final http.Client _client;
  final FlutterSecureStorage _storage;
  String? _token;

  static const _configuredBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://zayyan-ramadzaki-sirkula.pws.cs.ui.ac.id',
  );

  String get baseUrl => _configuredBaseUrl.replaceFirst(RegExp(r'/+$'), '');

  bool get isAuthenticated => _token != null;

  Future<void> restoreSession() async {
    _token = await _storage.read(key: 'auth_token');
    notifyListeners();
  }

  Future<dynamic> get(String path) => _request('GET', path);

  Future<dynamic> post(String path, Map<String, dynamic> data) =>
      _request('POST', path, data);

  Future<dynamic> _request(
    String method,
    String path, [
    Map<String, dynamic>? data,
  ]) async {
    final uri = Uri.parse('$baseUrl/api/v1/$path');
    final headers = <String, String>{
      'Accept': 'application/json',
      if (data != null) 'Content-Type': 'application/json',
      if (_token != null) 'Authorization': 'Token $_token',
    };
    late final http.Response response;
    try {
      response =
          await (method == 'GET'
                  ? _client.get(uri, headers: headers)
                  : _client.post(uri, headers: headers, body: jsonEncode(data)))
              .timeout(const Duration(seconds: 20));
    } catch (_) {
      throw const ApiException(
        'Tidak dapat terhubung ke server. Periksa koneksi dan alamat API.',
      );
    }
    dynamic body;
    if (response.body.isNotEmpty) {
      try {
        body = jsonDecode(utf8.decode(response.bodyBytes));
      } on FormatException {
        throw ApiException(
          'Respons server tidak valid.',
          statusCode: response.statusCode,
        );
      }
    }
    if (response.statusCode < 200 || response.statusCode >= 300) {
      final message = body is Map && body['detail'] != null
          ? body['detail'].toString()
          : 'Permintaan gagal (${response.statusCode}).';
      throw ApiException(message, statusCode: response.statusCode);
    }
    return body;
  }

  Future<void> login(String email, String password) async {
    final result = await post('accounts/login/', {
      'email': email,
      'password': password,
    });
    final token = result is Map ? result['token'] : null;
    if (token is! String || token.isEmpty) {
      throw const ApiException('Respons login tidak memiliki token.');
    }
    await _storage.write(key: 'auth_token', value: token);
    _token = token;
    notifyListeners();
  }

  Future<void> logout() async {
    await post('accounts/logout/', {});
    await _storage.delete(key: 'auth_token');
    _token = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _client.close();
    super.dispose();
  }
}
