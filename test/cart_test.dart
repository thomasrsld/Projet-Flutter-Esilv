import 'package:esilv_shop/model/cart.dart';
import 'package:esilv_shop/model/product.dart';
import 'package:esilv_shop/page/cart_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

Product product(int id, num price) => Product(
  id: id,
  title: 'Produit $id avec un titre long à afficher dans le panier',
  description: 'Description',
  category: 'Test',
  image: 'https://example.com/produit.png',
  price: price,
  rate: 3.9,
);

void main() {
  test('Total exact et suppression de toutes les occurrences du même id', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    container.listen(cartProvider, (_, _) {});
    final cart = container.read(cartProvider.notifier);
    expect(cart.priceInEuros, '0.00€');
    cart.add(product(1, 109.95));
    expect(cart.priceInEuros, '109.95€');
    cart.add(product(2, 22.30));
    cart.add(product(8, 10.99));
    cart.add(product(1, 109.95));
    expect(cart.priceInEuros, '253.19€');
    cart.remove(product(1, 109.95));
    expect(container.read(cartProvider).map((p) => p.id), [2, 8]);
    expect(cart.priceInEuros, '33.29€');
    cart.remove(product(2, 22.30));
    cart.remove(product(8, 10.99));
    expect(cart.priceInEuros, '0.00€');
  });

  testWidgets(
    'Panier dynamique, images, liste longue et commandes sur petit écran',
    (tester) async {
      tester.view.physicalSize = const Size(320, 640);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final image = await tester.runAsync(() => createTestImage());
      PaintingBinding.instance.imageCache.putIfAbsent(
        const NetworkImage('https://example.com/produit.png'),
        () => OneFrameImageStreamCompleter(
          Future.value(ImageInfo(image: image!)),
        ),
      );
      await tester.pumpWidget(
        const ProviderScope(child: MaterialApp(home: CartPage())),
      );
      await tester.pumpAndSettle();
      expect(find.text('0.00€'), findsOneWidget);
      expect(find.text('Votre panier est vide'), findsOneWidget);
      final container = ProviderScope.containerOf(
        tester.element(find.byType(CartPage)),
      );
      final cart = container.read(cartProvider.notifier);
      cart.add(product(1, 109.95));
      await tester.pumpAndSettle();
      expect(find.text('Votre panier est vide'), findsNothing);
      expect(find.text('109.95€'), findsNWidgets(2));
      expect(find.text(product(1, 109.95).title), findsOneWidget);
      expect(
        tester.widget<Image>(find.byType(Image)).image,
        const NetworkImage('https://example.com/produit.png'),
      );
      await tester.tap(find.text('RETIRER'));
      await tester.pumpAndSettle();
      expect(find.text('Votre panier est vide'), findsOneWidget);
      expect(find.text('0.00€'), findsOneWidget);

      for (var id = 1; id <= 40; id++) {
        cart.add(product(id, 1.01));
      }
      await tester.pumpAndSettle();
      expect(find.text('40.40€'), findsOneWidget);
      final totalPosition = tester.getTopLeft(find.text('40.40€'));
      await tester.scrollUntilVisible(find.text(product(40, 1.01).title), 300);
      expect(find.text(product(40, 1.01).title).hitTestable(), findsOneWidget);
      expect(tester.getTopLeft(find.text('40.40€')), totalPosition);
      expect(find.text('Commander').hitTestable(), findsOneWidget);
      await tester.tap(find.text('Commander'));
      await tester.pumpAndSettle();
      expect(find.byType(CartPage), findsOneWidget);
      expect(container.read(cartProvider).length, 40);
      expect(tester.takeException(), isNull);
    },
  );
}
