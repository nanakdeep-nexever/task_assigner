import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_assign_app/Blocs/AUTHentication/authentication_event.dart';

import '../Blocs/AUTHentication/authentication_bloc.dart';
import '../Blocs/AUTHentication/authentication_state.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<AuthenticationBloc, AuthenticationState>(
        listener: (context, state) {
          if (state is AuthenticationAuthenticated) {
            Navigator.pushNamed(context, "/completeProfile");
            /*     if (state.userId == 'admin') {
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
            } else {
              Navigator.pushReplacementNamed(
                context,
                '/viewer',
                arguments: state.userId.toString(),
              );
            }*/
          } else if (state is AuthenticationError) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Already Registered")),
            );
            _emailController.clear();
            _passwordController.clear();
          }
        },
        builder: (context, state) {
          return SafeArea(
            child: SingleChildScrollView(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Image.asset("assets/images/newRegisLogo.png"),
                        const SizedBox(height: 16.0),
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
                            labelText: 'Password',
                            labelStyle: const TextStyle(color: Colors.black),
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
                                const EdgeInsets.symmetric(horizontal: 16.0),
                            suffixIcon: IconButton(
                              onPressed: () {
                                setState(() {
                                  _isPasswordVisible = !_isPasswordVisible;
                                });
                              },
                              icon: Icon(
                                _isPasswordVisible
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                              ),
                            ),
                          ),
                          obscureText: !_isPasswordVisible,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your password';
                            } else if (value.length < 6) {
                              return 'Password must be at least 6 characters long';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          height: 50,
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              if (_formKey.currentState?.validate() ?? false) {
                                final email = _emailController.text;
                                final password = _passwordController.text;
                                context.read<AuthenticationBloc>().add(
                                      RegisterEvent(
                                          email: email, password: password),
                                    );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor: Colors.blue,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 32.0, vertical: 16.0),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              elevation: 5,
                            ),
                            child: state is AuthenticationLoading
                                ? const Center(
                                    child: CircularProgressIndicator(),
                                  )
                                : const Text('Register'),
                          ),
                        ),
                        const SizedBox(height: 16.0),
                        RichText(
                          text: TextSpan(
                            children: [
                              const TextSpan(
                                text: 'Already have an account? ',
                                style: TextStyle(
                                    color: Colors.black, fontSize: 16.0),
                              ),
                              TextSpan(
                                text: 'Login',
                                style: const TextStyle(
                                  color: Colors.blue,
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.w700,
                                ),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    Navigator.pushReplacementNamed(
                                        context, '/');
                                  },
                              ),
                            ],
                          ),
                        ),
                        if (state is AuthenticationUnauthenticated) ...[
                          const SizedBox(height: 16.0),
                          const Text(
                            'Please register first',
                            style: TextStyle(color: Colors.red, fontSize: 16.0),
                          ),
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
