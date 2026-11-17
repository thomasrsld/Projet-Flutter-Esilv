import 'package:esilv_shop/model/cart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:provider/provider.dart';

import '../model/product.dart';

class DetailProductPage extends ConsumerWidget {
  final Product product;

  const DetailProductPage({required this.product, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(product.title),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 8,
        children: [
          Expanded(
            child: ListView(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 8,
                  children: [
                    Container(
                      color: Colors.black12,
                      child: Image.network(
                        product.image,
                        width: MediaQuery.of(context).size.width,
                        height: 200,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Row(
                        children: [
                          for (var i = 0; i < 5; i++)
                            Icon(
                              i < product.rate.round()
                                  ? Icons.star
                                  : Icons.star_border,
                              color: i < product.rate.round()
                                  ? Colors.amber
                                  : Colors.grey,
                            ),
                          SizedBox(width: 8),
                          Text('${product.rate}/5'),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              product.title,
                              style: Theme.of(context).textTheme.titleLarge,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(product.getPrice()),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text(product.description),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text(product.category),
                    ),
                    if (ref.watch(cartProvider).contains(product))
                      Chip(label: const Text('Déjà présent dans le panier')),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SizedBox(
              width: MediaQuery.of(context).size.width,
              child: FilledButton(
                onPressed: () {
                  ref.read(cartProvider.notifier).add(product);
                },
                child: Text("Ajouter au panier"),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
