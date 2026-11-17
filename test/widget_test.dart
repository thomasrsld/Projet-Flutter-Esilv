import 'dart:convert';

import 'package:esilv_shop/app.dart';
import 'package:esilv_shop/model/cart.dart';
import 'package:esilv_shop/model/product.dart';
import 'package:esilv_shop/page/cart_page.dart';
import 'package:esilv_shop/page/detail_product_page.dart';
import 'package:esilv_shop/page/list_product_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  testWidgets('Navigation panier, retour, ajout et détail produit', (
    tester,
  ) async {
    const imageUrl = 'https://example.com/produit.png';
    final product = {
      'id': 42,
      'title': 'Produit de test',
      'description': 'Description courte',
      'category': 'Test',
      'image': imageUrl,
      'price': 22.30,
      'rating': {'rate': 3.9, 'count': 120},
    };
    final requests = <String>[];
    final secondProduct = {
      ...product,
      'id': 7,
      'title': 'Autre produit',
      'price': 10.99,
    };

    // Réponses API simulées : le test ne dépend pas d'Internet.
    final client = MockClient((request) async {
      requests.add(request.url.path);
      return http.Response(
        jsonEncode(
          request.url.path == '/products' ? [product, secondProduct] : product,
        ),
        200,
        headers: {'content-type': 'application/json; charset=utf-8'},
      );
    });
    // Image locale en mémoire pour éviter une requête réseau d'image.
    final image = await tester.runAsync(() => createTestImage());
    PaintingBinding.instance.imageCache.putIfAbsent(
      const NetworkImage(imageUrl),
      () =>
          OneFrameImageStreamCompleter(Future.value(ImageInfo(image: image!))),
    );

    await http.runWithClient(() async {
      await tester.pumpWidget(const ProviderScope(child: EsilvShop()));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.shopping_cart_outlined), findsOneWidget);
      expect(find.text('Produit de test'), findsOneWidget);

      await tester.tap(find.text('AJOUTER').first);
      await tester.pumpAndSettle();
      final container = ProviderScope.containerOf(
        tester.element(find.byType(ListProductPage)),
      );
      expect(container.read(cartProvider).single.id, 42);
      expect(find.text('1'), findsOneWidget);
      await tester.tap(find.text('AJOUTER').last);
      await tester.pumpAndSettle();
      expect(find.text('2'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.shopping_cart_outlined));
      await tester.pumpAndSettle();
      expect(find.byType(CartPage), findsOneWidget);
      expect(find.text('Votre panier est vide'), findsNothing);
      expect(find.text('33.29€'), findsOneWidget);
      expect(find.text('Produit de test'), findsOneWidget);
      expect(find.text('Autre produit'), findsOneWidget);

      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(find.byType(CartPage), findsNothing);
      expect(find.text('Produit de test'), findsOneWidget);
      expect(container.read(cartProvider).map((product) => product.id), [
        42,
        7,
      ]);

      await tester.tap(find.byIcon(Icons.shopping_cart_outlined));
      await tester.pumpAndSettle();
      expect(find.text('33.29€'), findsOneWidget);
      await tester.pageBack();
      await tester.pumpAndSettle();

      await tester.tap(find.text('Produit de test'));
      await tester.pumpAndSettle();
      expect(find.byType(DetailProductPage), findsOneWidget);
      expect(requests, contains('/products/42'));
      expect(find.text('Description courte'), findsOneWidget);
      expect(find.text('3.9/5'), findsOneWidget);
      expect(find.byIcon(Icons.star), findsNWidgets(4));
      expect(find.byIcon(Icons.star_border), findsOneWidget);
      await tester.tap(find.text('Ajouter au panier'));
      await tester.pumpAndSettle();
      expect(container.read(cartProvider).length, 3);
      expect(find.text('Déjà présent dans le panier'), findsOneWidget);
      expect(tester.takeException(), isNull);

      await tester.pageBack();
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.shopping_cart_outlined));
      await tester.pumpAndSettle();
      expect(find.text('55.59€'), findsOneWidget);
      await tester.tap(find.text('RETIRER').first);
      await tester.pumpAndSettle();
      expect(find.text('Produit de test'), findsNothing);
      expect(find.text('10.99€'), findsNWidgets(2));
      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(find.text('1'), findsOneWidget);
      await tester.tap(find.byIcon(Icons.shopping_cart_outlined));
      await tester.pumpAndSettle();
      await tester.tap(find.text('RETIRER'));
      await tester.pumpAndSettle();
      expect(find.text('0.00€'), findsOneWidget);
      expect(find.text('Votre panier est vide'), findsOneWidget);
      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(find.text('0'), findsOneWidget);
      await tester.pumpWidget(const SizedBox.shrink());
    }, () => client);
    client.close();
  });

  for (final rate in [0, 1.9, 3.9, 5]) {
    testWidgets('Note $rate : étoiles et fiche longue sur petit écran', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(320, 640);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      const imageUrl = 'https://example.com/produit.png';
      final image = await tester.runAsync(() => createTestImage());
      PaintingBinding.instance.imageCache.putIfAbsent(
        const NetworkImage(imageUrl),
        () => OneFrameImageStreamCompleter(
          Future.value(ImageInfo(image: image!)),
        ),
      );
      final product = Product.fromMap({
        'id': 15,
        'title': 'Un produit avec une longue description',
        'description': List.filled(
          15,
          'Une description longue pour tester la hauteur de la fiche.',
        ).join(' '),
        'category': 'Test',
        'image': imageUrl,
        'price': 109.95,
        'rating': {'rate': rate},
      });
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(home: DetailProductPage(product: product)),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('$rate/5'), findsOneWidget);
      expect(find.byIcon(Icons.star), findsNWidgets(rate.round()));
      expect(find.byIcon(Icons.star_border), findsNWidgets(5 - rate.round()));
      for (final icon in tester.widgetList<Icon>(find.byIcon(Icons.star))) {
        expect(icon.color, Colors.amber);
      }
      for (final icon in tester.widgetList<Icon>(
        find.byIcon(Icons.star_border),
      )) {
        expect(icon.color, Colors.grey);
      }
      expect(tester.takeException(), isNull);
      await tester.tap(find.text('Ajouter au panier'));
      await tester.pumpAndSettle();
      final container = ProviderScope.containerOf(
        tester.element(find.byType(DetailProductPage)),
      );
      expect(container.read(cartProvider).single.rate, rate);
      expect(tester.takeException(), isNull);
      await tester.drag(find.byType(ListView), const Offset(0, -1500));
      await tester.pumpAndSettle();
      expect(find.text('Test').hitTestable(), findsOneWidget);
      expect(find.text('Ajouter au panier').hitTestable(), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
}
