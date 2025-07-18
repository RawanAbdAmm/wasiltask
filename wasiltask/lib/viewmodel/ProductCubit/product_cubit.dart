// cubit/product/product_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/category_enum.dart';
import '../../data/models/product_data_class.dart';
import '../../data/services/ProductService.dart';
import 'product_state.dart';

class ProductCubit extends Cubit<ProductState> {
  final ProductService _service;

  List<Product> _allProducts = [];
  bool _isAscending = true;

  ProductCubit(this._service) : super(ProductInitial());

  void fetchProducts() async {
    emit(ProductLoading());
    try {
      _allProducts = await _service.fetchProducts();
      emit(ProductLoaded(_allProducts));
    } catch (e) {
      emit(ProductError("Failed to fetch products"));
    }
  }

  void toggleSortByPrice() {
    _isAscending = !_isAscending;

    final sorted = List<Product>.from(_allProducts)
      ..sort((a, b) => _isAscending
          ? a.price.compareTo(b.price)
          : b.price.compareTo(a.price));

    emit(ProductLoaded(sorted));
  }

  bool get isAscending => _isAscending;

  void filterByCategory(ProductCategory category) {
    final filtered = _allProducts.where((product) => product.category == category).toList();
    emit(ProductLoaded(filtered));
  }

  void resetFilters() {
    emit(ProductLoaded(_allProducts));
  }
}
