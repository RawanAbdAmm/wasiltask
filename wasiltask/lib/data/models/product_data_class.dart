import 'category_enum.dart';

class Product {
  final int id;
  final String title;
  final String description;
  final double price;
  final ProductCategory category;
  final String thumbnail;

  Product({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.category,
    required this.thumbnail,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      price: (json['price'] as num).toDouble(),
      category: ProductCategory.fromString(json['category']),
      thumbnail: json['thumbnail'],
    );
  }
}
