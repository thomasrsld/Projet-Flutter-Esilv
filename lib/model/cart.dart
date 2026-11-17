import 'package:esilv_shop/model/product.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'cart.g.dart';

@riverpod
class Cart extends _$Cart {
  @override
  List<Product> build() {
    return [];
  }

  String get priceInEuros =>
      "${state.fold<num>(0, (prv, actual) => prv + actual.price).toStringAsFixed(2)}€";

  void add(Product product) {
    state = [...state, product];
  }

  void remove(Product product) {
    state = state.where((element) => element.id != product.id).toList();
  }
}
