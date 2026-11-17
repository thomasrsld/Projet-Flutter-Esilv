import 'dart:convert';

import 'package:esilv_shop/page/cart_page.dart';
import 'package:esilv_shop/page/detail_product_page.dart';
import 'package:esilv_shop/page/list_product_page.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart';

import 'model/product.dart';

class EsilvShop extends StatelessWidget {
  const EsilvShop({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Esilv Shop',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      routerConfig: _router,
    );
  }
}

final _router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => ListProductPage(),
      routes: [
        GoRoute(
          path: 'product/:idProduct',
          builder: (context, state) {
            final idProductNullable = int.tryParse(
              state.pathParameters['idProduct'] ?? "",
            );
            if (idProductNullable == null) {
              return Scaffold(body: Center(child: Text("Produit introuvable")));
            }
            return FutureBuilder(
              future: getProductById(idProductNullable),
              builder: (context, asyncSnapshot) {
                if (asyncSnapshot.hasData && asyncSnapshot.data != null) {
                  return DetailProductPage(product: asyncSnapshot.data!);
                } else if (asyncSnapshot.connectionState ==
                    ConnectionState.waiting) {
                  return Scaffold(
                    body: Center(child: CircularProgressIndicator()),
                  );
                }
                return Scaffold(
                  body: Center(child: Text("Produit introuvable")),
                );
              },
            );
          },
        ),
        GoRoute(path: 'cart', builder: (context, state) => CartPage()),
      ],
    ),
  ],
);

Future<Product> getProductById(int? idProductNullable) async {
  final response = await get(
    Uri.parse('https://fakestoreapi.com/products/${idProductNullable!}'),
  );
  //Récupérer les produits en List<Map>
  if (response.statusCode == 200) {
    return Product.fromMap(json.decode(response.body));
  }
  return Future.error("Produit introuvable");
}
