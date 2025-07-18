import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/constants/route_names.dart';
import '../../core/constants/strings.dart';
import '../../core/utils/common/custom_alert.dart';
import '../../core/utils/common/custom_snackbar.dart';
import '../../data/models/category_enum.dart';
import '../../viewmodel/ProductCubit/product_cubit.dart';
import '../../viewmodel/ProductCubit/product_state.dart';
import '../../viewmodel/cartCubit/cart_cubit.dart';
import '../../viewmodel/cartCubit/cart_state.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  ProductCategory? selectedCategory;

  @override
  Widget build(BuildContext context) {
    final productCubit = context.read<ProductCubit>();
    final isGuest = FirebaseAuth.instance.currentUser?.isAnonymous ?? true;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (isGuest) {
          Navigator.pushReplacementNamed(context, RouteNames.login);
        } else {
          await SystemNavigator.pop();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            Strings.productsTitle,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.deepPurple,
            ),
          ),
          actions: [
            if (!isGuest)
              IconButton(
                icon: const Icon(Icons.logout),
                color: Colors.deepPurple,
                onPressed: () async {
                  await showConfirmDialog(
                    context,
                    title: Strings.confirmLogout,
                    message: Strings.areYouSure,
                    confirmText: Strings.logout,
                    onConfirm: () async {
                      await FirebaseAuth.instance.signOut();
                      if (!context.mounted) return;
                      Navigator.pushReplacementNamed(context, RouteNames.login);
                    },
                  );
                },
              ),
            BlocBuilder<CartCubit, CartState>(
              builder: (context, state) {
                final itemCount = state.items.fold<int>(
                  0,
                  (sum, item) => sum + item.quantity,
                );

                return Stack(
                  alignment: Alignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.shopping_cart),
                      color: Colors.deepPurple,
                      onPressed: () {
                        Navigator.pushNamed(context, RouteNames.cart);
                      },
                    ),
                    if (itemCount > 0)
                      Positioned(
                        top: 8,
                        right: 6,
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 16,
                            minHeight: 16,
                          ),
                          child: Text(
                            itemCount > 99 ? '99+' : '$itemCount',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          ],
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        productCubit.toggleSortByPrice();
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple.shade900,
                    ),
                    child: Text(
                      productCubit.isAscending
                          ? Strings.sortAscending
                          : Strings.sortDescending,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 12),
                  DropdownButton<ProductCategory>(
                    value: selectedCategory,
                    hint: Text(
                      Strings.filterCategory,
                      style: TextStyle(color: Colors.purple.shade700),
                    ),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => selectedCategory = value);
                        productCubit.filterByCategory(value);
                      }
                    },
                    items: ProductCategory.values
                        .where((cat) => cat != ProductCategory.unknown)
                        .map((category) {
                          return DropdownMenuItem<ProductCategory>(
                            value: category,
                            child: Text(category.label),
                          );
                        })
                        .toList(),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: () {
                      setState(() => selectedCategory = null);
                      productCubit.resetFilters();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple.shade900,
                    ),
                    child: const Text(
                      Strings.resetFilters,
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
            if (isGuest)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade100,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.amber.shade700),
                  ),
                  child: Row(
                    children: const [
                      Icon(Icons.info_outline, color: Colors.amber),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          Strings.browseGuest,
                          style: TextStyle(fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            Expanded(
              child: BlocBuilder<ProductCubit, ProductState>(
                builder: (context, state) {
                  if (state is ProductLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is ProductError) {
                    return Center(child: Text(state.message));
                  } else if (state is ProductLoaded) {
                    if (state.products.isEmpty) {
                      return const Center(child: Text(Strings.noProductsFound));
                    }
                    return GridView.builder(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 8,
                      ),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 8,
                            mainAxisSpacing: 8,
                            childAspectRatio: 0.6,
                          ),
                      itemCount: state.products.length,
                      itemBuilder: (context, index) {
                        final product = state.products[index];
                        return Card(
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ClipRRect(
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(12),
                                ),
                                child: Image.network(
                                  product.thumbnail,
                                  height: 140,
                                  width: double.infinity,
                                  fit: BoxFit.contain,
                                  errorBuilder: (context, error, stackTrace) =>
                                      const Icon(Icons.broken_image),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                ),
                                child: Text(
                                  product.title,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "${product.price} JOD",
                                      style: TextStyle(
                                        color: Colors.purple.shade900,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    IconButton(
                                      icon: Icon(
                                        Icons.shopping_cart_outlined,
                                        size: 20,
                                        color: Colors.purple.shade900,
                                      ),
                                      onPressed: () {
                                        context.read<CartCubit>().addToCart(
                                          product,
                                        );
                                        SnackBarHelper.showPurpleSnackBar(
                                          context,
                                          '${product.title} ${Strings.addToCart.toLowerCase()}',
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                ),
                                child: SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.deepPurple,
                                    ),
                                    onPressed: () {
                                      Navigator.pushNamed(
                                        context,
                                        RouteNames.productDetails,
                                        arguments: product,
                                      );
                                    },
                                    child: const Text(
                                      Strings.details,
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 6),
                            ],
                          ),
                        );
                      },
                    );
                  } else {
                    return const SizedBox.shrink();
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
