import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/product_data_class.dart';


class ProductService {
  Future<List<Product>> fetchProducts() async {
    final response = await http.get(Uri.parse('https://dummyjson.com/products'));
    final jsonData = json.decode(response.body);
    final List products = jsonData['products'];
    return products.map((e) => Product.fromJson(e)).toList();
  }
}
