import 'package:flutter/widgets.dart';
import '../features/products/presentation/screens/product_details_screen.dart';
import '../features/products/presentation/screens/product_list_screen.dart';

class AppRoutes {
  static const String productList = '/';
  static const String productDetails = '/products/details';

  static Map<String, WidgetBuilder> get routes => {
    productList: (_) => const ProductListScreen(),
    productDetails: (_) => const ProductDetailsScreen(),
  };
}
