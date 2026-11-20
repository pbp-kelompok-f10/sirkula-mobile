import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sirkula_mobile/core/api_client.dart';
import 'package:sirkula_mobile/main.dart';

class FakeApiClient extends ApiClient {
  final requestedPaths = <String>[];

  @override
  Future<dynamic> get(String path) async {
    requestedPaths.add(path);
    if (path.startsWith('marketplace/map/nearby/')) {
      return <String, dynamic>{'listings': [], 'stores': []};
    }
    return <dynamic>[];
  }
}

void main() {
  testWidgets('drawer navigates between every module', (tester) async {
    final api = FakeApiClient();
    addTearDown(api.dispose);
    await tester.pumpWidget(MaterialApp(home: AppShell(api: api)));
    await tester.pumpAndSettle();

    expect(api.requestedPaths, contains('marketplace/products/'));
    for (final label in [
      'Discovery Map',
      'Wardrobe',
      'AI Stylist',
      'Transaksi',
      'Barter',
      'Profil',
      'Marketplace',
    ]) {
      await tester.tap(find.byTooltip('Open navigation menu'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text(label).last);
      await tester.tap(find.text(label).last);
      await tester.pumpAndSettle();
      expect(find.text(label), findsWidgets);
    }
    expect(api.requestedPaths, contains('marketplace/map/locations/'));
  });
}
