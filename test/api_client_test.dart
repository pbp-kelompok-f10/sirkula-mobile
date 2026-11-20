import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:sirkula_mobile/core/api_client.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'login sends credentials and uses the token for profile requests',
    () async {
      FlutterSecureStorage.setMockInitialValues({});
      final paths = <String>[];
      final client = ApiClient(
        client: MockClient((request) async {
          paths.add(request.url.path);
          if (request.url.path.endsWith('/accounts/login/')) {
            expect(jsonDecode(request.body), {
              'email': 'user@example.com',
              'password': 'secret',
            });
            return http.Response('{"token":"example-token"}', 200);
          }
          expect(request.headers['Authorization'], 'Token example-token');
          return http.Response('{"display_name":"Pengguna"}', 200);
        }),
      );
      addTearDown(client.dispose);

      await client.login('user@example.com', 'secret');
      expect(client.isAuthenticated, isTrue);
      final profile = await client.get('accounts/profile/') as Map;
      expect(profile['display_name'], 'Pengguna');
      expect(paths, ['/api/v1/accounts/login/', '/api/v1/accounts/profile/']);
    },
  );
}
