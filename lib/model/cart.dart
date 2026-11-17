import 'package:esilv_shop/model/product.dart';
import 'package:flutter/foundation.dart';

class Cart extends ChangeNotifier {
  final List<Product> _products = [];
  List<Product> get products => _products;

  void add(Product product) {
    _products.add(product);
    notifyListeners();
  }

  void remove(Product product) {
    _products.remove(product);
    notifyListeners();
  }
}
