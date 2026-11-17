import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'model/cart.dart';

void main() {
  runApp(
    ProviderScope(
      child: EsilvShop(),
    ),
  );
}
