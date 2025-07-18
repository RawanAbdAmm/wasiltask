import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/models/product_data_class.dart';
import 'cart_state.dart';

class CartCubit extends Cubit<CartState> {
  CartCubit() : super(const CartState());

  Future<void> loadCartFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString('cart');
    if (jsonString != null) {
      final List decoded = json.decode(jsonString);
      final items = decoded.map((item) {
        return CartItem(
          product: Product(
            id: item['id'],
            title: item['title'],
            description: item['description'],
            price: item['price'],
            thumbnail: item['thumbnail'],
            category: item['category'],
          ),
          quantity: item['quantity'],
        );
      }).toList();
      emit(CartState(items: items));
    }
  }

  void _saveCartToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final cartData = state.items.map((item) {
      return {
        'id': item.product.id,
        'title': item.product.title,
        'description': item.product.description,
        'price': item.product.price,
        'thumbnail': item.product.thumbnail,
        'category': item.product.category,
        'quantity': item.quantity,
      };
    }).toList();
    await prefs.setString('cart', json.encode(cartData));
  }

  void addToCart(Product product) {
    final existing = state.items
        .where((item) => item.product.id == product.id)
        .toList();

    List<CartItem> updated;
    if (existing.isNotEmpty) {
      updated = state.items.map((item) {
        if (item.product.id == product.id) {
          return item.copyWith(quantity: item.quantity + 1);
        }
        return item;
      }).toList();
    } else {
      updated = List<CartItem>.from(state.items)
        ..add(CartItem(product: product, quantity: 1));
    }

    emit(CartState(items: updated));
    _saveCartToPrefs();
  }

  void removeFromCart(Product product) {
    final updated = List<CartItem>.from(state.items)
      ..removeWhere((item) => item.product.id == product.id);
    emit(CartState(items: updated));
    _saveCartToPrefs();
  }

  void increaseQuantity(Product product) {
    final updated = state.items.map<CartItem>((item) {
      if (item.product.id == product.id) {
        return item.copyWith(quantity: item.quantity + 1);
      }
      return item;
    }).toList();
    emit(CartState(items: updated));
    _saveCartToPrefs();
  }

  void decreaseQuantity(Product product) {
    final updated = state.items
        .map<CartItem>((item) {
          if (item.product.id == product.id && item.quantity > 1) {
            return item.copyWith(quantity: item.quantity - 1);
          }
          return item;
        })
        .where((item) => item.quantity > 0)
        .toList();

    emit(CartState(items: updated));
    _saveCartToPrefs();
  }
}
