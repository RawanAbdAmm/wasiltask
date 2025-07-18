import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wasiltask/view/auth/LoginScreen.dart';
import 'package:wasiltask/viewmodel/ProductCubit/product_cubit.dart';
import 'package:wasiltask/viewmodel/authCubit/auth_cubit.dart';
import 'package:wasiltask/viewmodel/cartCubit/cart_cubit.dart';
import 'Navigate/navigator.dart';
import 'core/constants/strings.dart';
import 'data/services/ProductService.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => AuthCubit()),
        BlocProvider(create: (_) => ProductCubit(ProductService())..fetchProducts()),
        BlocProvider(create: (_) => CartCubit()),

      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: Strings.appTitle,
        theme: ThemeData(primarySwatch: Colors.deepPurple),
        home: const LoginScreen(),
        initialRoute: '/',
        onGenerateRoute: NavigatorRoute.generateRoute,
      ),
    );
  }
}
