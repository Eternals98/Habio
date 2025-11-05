import 'package:flutter_test/flutter_test.dart';
import 'package:per_habit/features/store/data/models/shop_item_model.dart';

void main() {
  group('ShopItemModel.fromMap', () {
    test('uses Firestore document id when payload id is missing', () {
      final model = ShopItemModel.fromMap({
        'name': 'Test Item',
        'description': 'Description',
        'icono': 'icon.png',
        'price': 100,
        'content': <Map<String, dynamic>>[],
      }, id: 'doc-123');

      expect(model.id, 'doc-123');
    });

    test('keeps payload id when provided', () {
      final model = ShopItemModel.fromMap({
        'id': 'payload-id',
        'name': 'Another Item',
        'description': 'Description',
        'icono': 'icon.png',
        'price': 200,
        'content': <Map<String, dynamic>>[],
      }, id: 'doc-456');

      expect(model.id, 'payload-id');
    });
  });
}
