enum ProductCategory {
  beauty,
  fragrances,
  furniture,
  groceries,
  unknown;

  static ProductCategory fromString(String value) {
    switch (value.toLowerCase()) {
      case 'beauty':
        return ProductCategory.beauty;
      case 'fragrances':
        return ProductCategory.fragrances;
      case 'furniture':
        return ProductCategory.furniture;
      case 'groceries':
        return ProductCategory.groceries;
      default:
        return ProductCategory.unknown;
    }
  }

  String get label {
    switch (this) {
      case ProductCategory.beauty:
        return 'Beauty';
      case ProductCategory.fragrances:
        return 'Fragrances';
      case ProductCategory.furniture:
        return 'Furniture';
      case ProductCategory.groceries:
        return 'Groceries';
      case ProductCategory.unknown:
        return 'Unknown';
    }
  }
}
