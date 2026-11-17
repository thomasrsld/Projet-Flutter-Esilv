import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../model/cart.dart';

class CartPage extends ConsumerWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final products = ref.watch(cartProvider);
    final cart = ref.read(cartProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text('Panier Esilv Shop'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(child: Text("Votre panier total est de")),
                Text(
                  cart.priceInEuros,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          Expanded(
            child: products.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text("Votre panier est vide"),
                        Icon(Icons.image),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: products.length,
                    itemBuilder: (context, index) => ListTile(
                      leading: Image.network(
                        products[index].image,
                        width: 60,
                        height: 80,
                        fit: BoxFit.contain,
                      ),
                      title: Text(
                        products[index].title,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Text(
                        products[index].getPrice(),
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      trailing: TextButton(
                        onPressed: () => ref
                            .read(cartProvider.notifier)
                            .remove(products[index]),
                        child: Text('RETIRER'),
                      ),
                    ),
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SizedBox(
              width: double.infinity,
              child: FilledButton(onPressed: () {}, child: Text('Commander')),
            ),
          ),
        ],
      ),
    );
  }
}
