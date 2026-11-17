import 'package:esilv_shop/model/product.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final map = <String, dynamic>{
    'id': 1,
    'title': 'Produit de test',
    'description': 'Description',
    'category': 'Test',
    'image': 'https://example.com/produit.png',
    'price': 109.95,
    'rating': {'rate': 3.9, 'count': 120},
  };

  test('fromMap lit rating.rate entier ou décimal sans changer le prix', () {
    expect(Product.fromMap(map).rate, 3.9);
    expect(Product.fromMap(map).price, 109.95);
    expect(Product.fromMap(map).getPrice(), '109.95€');
    expect(
      Product.fromMap({
        ...map,
        'rating': {'rate': 3},
      }).rate,
      3,
    );
  });

  test('toMap conserve rating.rate et permet un aller-retour du modèle', () {
    final product = Product.fromMap(map);
    expect(product.toMap()['rating'], {'rate': 3.9});
    final restored = Product.fromMap(product.toMap());
    expect(restored, product);
    expect(restored.hashCode, product.hashCode);
  });

  test('Deux produits de notes différentes ne sont pas égaux', () {
    final product = Product.fromMap(map);
    final other = Product.fromMap({
      ...map,
      'rating': {'rate': 4.1},
    });
    expect(product == other, isFalse);
  });
}
