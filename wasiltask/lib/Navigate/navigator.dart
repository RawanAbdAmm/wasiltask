import 'package:flutter/material.dart';
import 'package:wasiltask/view/auth/LoginScreen.dart';
import 'package:wasiltask/view/cart/CartScreen.dart';
import 'package:wasiltask/view/product/ProductScreen.dart';
import 'package:wasiltask/view/product/ProductDetailsScreen.dart';
import 'package:wasiltask/data/models/product_data_class.dart';
import '../core/constants/route_names.dart';

class NavigatorRoute {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case RouteNames.login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());

      case RouteNames.products:
        return MaterialPageRoute(builder: (_) => const ProductListScreen());

      case RouteNames.cart:
        return MaterialPageRoute(builder: (_) => const CartScreen());

      case RouteNames.productDetails:
        final product = settings.arguments as Product;
        return MaterialPageRoute(
            builder: (_) => ProductDetailsScreen(product: product));

      default:
        return MaterialPageRoute(
            builder: (_) => Scaffold(
              body: Center(child: Text('No route defined for ${settings.name}')),
            ));
    }
  }
}
