import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../Blocs/AUTHentication/authentication_bloc.dart';
import '../Blocs/AUTHentication/authentication_event.dart';
import '../Blocs/AUTHentication/authentication_state.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<AuthenticationBloc, AuthenticationState>(
        listener: (context, state) {
          if (state is AuthenticationAuthenticated) {
            if (state.userId == 'admin') {
              Navigator.pushReplacementNamed(
                context,
                '/admin',
                arguments: state.userId.toString(),
              );
            } else if (state.userId == 'manager') {
              Navigator.pushReplacementNamed(
                context,
                '/manager',
                arguments: state.userId.toString(),
              );
            } else if (state.userId == 'developer') {
              Navigator.pushReplacementNamed(
                context,
                '/developer',
                arguments: state.userId.toString(),
              );
            } else if (state.userId == 'viewer') {
              Navigator.pushReplacementNamed(
                context,
                '/viewer',
                arguments: state.userId.toString(),
              );
            }
          } else if (state is AuthenticationError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          bool isPasswordVisible = false;
          if (state is PasswordVisibilityState) {
            isPasswordVisible = state.isPasswordVisible;
          }

          return SafeArea(
            child: SingleChildScrollView(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Image.asset("assets/images/logoin.png"),
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: _emailController,
                          decoration: const InputDecoration(
                            labelText: 'Email',
                            labelStyle: TextStyle(color: Colors.black),
                            border: OutlineInputBorder(),
                            focusedBorder: OutlineInputBorder(
                              borderSide:
                                  BorderSide(color: Colors.blue, width: 2.0),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide:
                                  BorderSide(color: Colors.grey, width: 1.0),
                            ),
                            contentPadding:
                                EdgeInsets.symmetric(horizontal: 16.0),
                          ),
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your email';
                            } else if (!RegExp(r'\S+@\S+\.\S+')
                                .hasMatch(value)) {
                              return 'Please enter a valid email address';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16.0),
                        TextFormField(
                          controller: _passwordController,
                          decoration: InputDecoration(
                            suffixIcon: IconButton(
                              onPressed: () {
                                context
                                    .read<AuthenticationBloc>()
                                    .add(TogglePasswordVisibilityEvent());
                              },
                              icon: Icon(isPasswordVisible
                                  ? Icons.visibility
                                  : Icons.visibility_off),
                            ),
                            labelText: 'Password',
                            labelStyle: TextStyle(color: Colors.black),
                            border: const OutlineInputBorder(),
                            focusedBorder: const OutlineInputBorder(
                              borderSide:
                                  BorderSide(color: Colors.blue, width: 2.0),
                            ),
                            enabledBorder: const OutlineInputBorder(
                              borderSide:
                                  BorderSide(color: Colors.grey, width: 1.0),
                            ),
                            contentPadding:
                                EdgeInsets.symmetric(horizontal: 16.0),
                          ),
                          obscureText: !isPasswordVisible,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your password';
                            } else if (value.length < 6) {
                              return 'Password must be at least 6 characters long';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        Align(
                          alignment: Alignment.centerRight,
                          child: RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: 'Forgot Password?',
                                  style: const TextStyle(
                                    color: Colors.red,
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.w700,
                                  ),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () {
                                      Navigator.pushNamed(
                                          context, '/forgot_password');
                                    },
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          height: 50,
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              if (_formKey.currentState?.validate() ?? false) {
                                final email = _emailController.text;
                                final password = _passwordController.text;
                                context.read<AuthenticationBloc>().add(
                                      LoginEvent(
                                          email: email, password: password),
                                    );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor:
                                  Colors.blue, // Button background color
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 32.0, vertical: 16.0),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              elevation: 5,
                            ),
                            child: state is AuthenticationLoading
                                ? const CircularProgressIndicator()
                                : Text('Login'),
                          ),
                        ),
                        const SizedBox(height: 16.0),
                        RichText(
                          text: TextSpan(
                            children: [
                              const TextSpan(
                                text: 'Don\'t have an account? ',
                                style: TextStyle(
                                    color: Colors.black, fontSize: 16.0),
                              ),
                              TextSpan(
                                text: 'Register here',
                                style: const TextStyle(
                                  color: Colors.blue,
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.w700,
                                ),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    Navigator.pushReplacementNamed(
                                        context, '/register');
                                  },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        if (state is AuthenticationUnauthenticated) ...[
                          const SizedBox(height: 16.0),
                          Container()
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
