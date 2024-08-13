import 'package:flutter/material.dart';

class AdminPage extends StatefulWidget {
  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  @override
  Widget build(BuildContext context) {
    String? role = ModalRoute.of(context)?.settings.arguments.toString();
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Dashboard '),
      ),
      body: Center(
        child: Text('Admin Page $role'),
      ),
    );
  }
}
