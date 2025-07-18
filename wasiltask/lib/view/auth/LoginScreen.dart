import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/constants/route_names.dart';
import '../../core/constants/strings.dart';
import '../../core/utils/validators/validators.dart';
import '../../viewmodel/authCubit/auth_cubit.dart';
import '../../viewmodel/authCubit/auth_state.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool isLogin = true;
  String? emailError;
  String? passwordError;

  void handleSubmit() {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    setState(() {
      emailError = null;
      passwordError = null;
    });

    if (email.isEmpty) {
      setState(() => emailError = Strings.emailIsRequired);
      return;
    } else if (!isValidEmail(email)) {
      setState(() => emailError = Strings.invalidEmail);
      return;
    }

    if (password.isEmpty) {
      setState(() => passwordError = Strings.passwordIsRequired);
      return;
    }

    if (isLogin) {
      context.read<AuthCubit>().login(email, password);
    } else {
      context.read<AuthCubit>().register(email, password);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is Authenticated) {
            Navigator.pushReplacementNamed(context, RouteNames.products);
          } else if (state is AuthError) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        builder: (context, state) {
          final isLoading = state is AuthLoading;

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 24),
                Text(
                  Strings.appName,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: Colors.purple.shade900,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),

                InkWell(
                  onTap: () {
                    Navigator.pushNamed(context, RouteNames.products);
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.purple.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.person_outline,
                          color: Colors.purple.shade700,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          Strings.continueAsGuest,
                          style: TextStyle(color: Colors.purple.shade700),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                TextField(
                  controller: emailController,
                  decoration: InputDecoration(
                    labelText: Strings.emailLabel,
                    labelStyle: TextStyle(color: Colors.purple.shade700),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.purple.shade700),
                    ),
                    border: const OutlineInputBorder(),
                    errorText: emailError,
                    suffixIcon: emailController.text.isNotEmpty
                        ? IconButton(
                            icon: Icon(
                              Icons.clear,
                              color: Colors.purple.shade400,
                            ),
                            onPressed: () => setState(() {
                              emailController.clear();
                              emailError = null;
                            }),
                          )
                        : null,
                  ),
                  onChanged: (value) {
                    setState(() {
                      if (isValidEmail(value.trim())) {
                        emailError = null;
                      }
                    });
                  },
                ),

                const SizedBox(height: 16),

                TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: Strings.passwordLabel,
                    labelStyle: TextStyle(color: Colors.purple.shade700),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.purple.shade700),
                    ),
                    border: const OutlineInputBorder(),
                    errorText: passwordError,
                    suffixIcon: passwordController.text.isNotEmpty
                        ? IconButton(
                            icon: Icon(
                              Icons.clear,
                              color: Colors.purple.shade400,
                            ),
                            onPressed: () => setState(() {
                              passwordController.clear();
                              passwordError = null;
                            }),
                          )
                        : null,
                  ),
                  onChanged: (value) {
                    setState(() {
                      if (value.trim().isNotEmpty) {
                        passwordError = null;
                      }
                    });
                  },
                ),

                const SizedBox(height: 24),

                isLoading
                    ? const CircularProgressIndicator()
                    : Center(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.purple.shade900,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                          ),
                          onPressed: handleSubmit,
                          child: Text(
                            isLogin
                                ? Strings.loginButton
                                : Strings.registerButton,
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      ),

                const SizedBox(height: 12),

                TextButton(
                  onPressed: () => setState(() => isLogin = !isLogin),
                  child: Text(
                    isLogin ? Strings.registerLabel : Strings.loginLabel,
                    style: TextStyle(color: Colors.purple.shade700),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
