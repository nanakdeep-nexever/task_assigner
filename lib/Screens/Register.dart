import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../Blocs/AUTHentication/authentication_bloc.dart';
import '../Blocs/AUTHentication/authentication_event.dart';
import '../Blocs/AUTHentication/authentication_state.dart';

class RegisterPage extends StatelessWidget {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Register'),
      ),
      body: BlocConsumer<AuthenticationBloc, AuthenticationState>(
        listener: (context, state) {
          if (state is AuthenticationAuthenticated) {
            if (state.userId == 'admin') {
              Navigator.pushReplacementNamed(context, '/admin',
                  arguments: state.userId.toString());
            } else if (state.userId == 'manager') {
              Navigator.pushReplacementNamed(context, '/manager',
                  arguments: state.userId.toString());
            } else if (state.userId == 'developer') {
              Navigator.pushReplacementNamed(context, '/developer',
                  arguments: state.userId.toString());
            } else {
              Navigator.pushReplacementNamed(context, '/viewer',
                  arguments: state.userId.toString());
            }
          } else if (state is AuthenticationError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          if (state is AuthenticationLoading) {
            return Center(child: CircularProgressIndicator());
          }

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextField(
                  controller: _emailController,
                  decoration: InputDecoration(labelText: 'Email'),
                ),
                TextField(
                  controller: _passwordController,
                  decoration: InputDecoration(labelText: 'Password'),
                  obscureText: true,
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    final email = _emailController.text;
                    final password = _passwordController.text;
                    context.read<AuthenticationBloc>().add(
                          RegisterEvent(email: email, password: password),
                        );
                  },
                  child: Text('Register'),
                ),
                if (state is AuthenticationUnauthenticated) ...[
                  Text('Please Register first',
                      style: TextStyle(color: Colors.red)),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}
