import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../generated/Strings_s.dart';
import '../active_users_bloc.dart';
import '../active_users_event.dart';
import '../active_users_state.dart';

class ActiveUserPage extends StatelessWidget {
  const ActiveUserPage({super.key});

  void _showCreateUserDialog(BuildContext context) {
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    String selectedRole = Com_string.Role_viewer.toString();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          elevation: 10,
          backgroundColor: Colors.blue.shade50,
          title: const Center(
              child: Text(
            'Create User',
            style: TextStyle(
                fontWeight: FontWeight.w500, fontSize: 20, color: Colors.black),
          )),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: emailController,
                decoration: const InputDecoration(labelText: 'Email'),
              ),
              TextField(
                controller: passwordController,
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
              ),
              DropdownButtonFormField<String>(
                value: selectedRole,
                decoration: const InputDecoration(labelText: 'Role'),
                items: [
                  'admin',
                  'manager',
                  Com_string.Role_developer,
                  Com_string.Role_viewer
                ]
                    .map((role) => DropdownMenuItem<String>(
                          value: role,
                          child: Text(role),
                        ))
                    .toList(),
                onChanged: (newValue) {
                  selectedRole = newValue!;
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                Com_string.Cancel,
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: Colors.black),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
              onPressed: () {
                final email = emailController.text;
                final password = passwordController.text;

                if (email.isNotEmpty && password.isNotEmpty) {
                  BlocProvider.of<ActiveUsersBloc>(context).add(
                    CreateUser(email, password, selectedRole),
                  );
                  Navigator.of(context).pop();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text(Com_string.Please_fill_all_field)),
                  );
                }
              },
              child: const Text(
                'Create User',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.black),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ActiveUsersBloc()..add(LoadActiveUsers()),
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Active Users',
            style: TextStyle(
                fontSize: 20, fontWeight: FontWeight.w700, color: Colors.black),
          ),
        ),
        body: BlocBuilder<ActiveUsersBloc, ActiveUsersState>(
          builder: (context, state) {
            if (state is ActiveUsersLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is ActiveUsersError) {
              return Center(child: Text('Error: ${state.message}'));
            } else if (state is ActiveUsersLoaded) {
              final users = state.users;

              if (users.isEmpty) {
                return const Center(child: Text('No active users found.'));
              }

              return ListView.builder(
                itemCount: users.length,
                itemBuilder: (context, index) {
                  final user = users[index];
                  final uid = user.id;
                  final email = user[Com_string.email] ?? 'No Email';
                  final role = user[Com_string.role];

                  return Card(
                    margin:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 5,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.blue.withOpacity(0.1), Colors.white],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.blue,
                          child: Text("${index + 1}"),
                        ),
                        title: Text(
                          email,
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 16,
                            color: Colors.black,
                          ),
                        ),
                        subtitle: Text('Role: $role'),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () {
                            BlocProvider.of<ActiveUsersBloc>(context)
                                .add(DeleteUser(uid));
                          },
                        ),
                        onTap: () {
                          // Implement the role update dialog here
                        },
                      ),
                    ),
                  );
                },
              );
            } else {
              return const Center(child: Text('Unexpected state'));
            }
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _showCreateUserDialog(context),
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}
