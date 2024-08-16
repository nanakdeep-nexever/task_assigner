import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../Blocs/Project_Management_BLoC/project_manage_bloc.dart';
import '../Blocs/Project_Management_BLoC/project_manage_state.dart';

class ProjectManagementPage extends StatefulWidget {
  @override
  State<ProjectManagementPage> createState() => _ProjectManagementPageState();
}

class _ProjectManagementPageState extends State<ProjectManagementPage> {
  @override
  Widget build(BuildContext context) {
    String? role = ModalRoute.of(context)?.settings.arguments.toString();

    return Scaffold(
      appBar: AppBar(
        title: Text("Project"),
        actions: [
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.logout),
          ),
        ],
      ),
      body: BlocConsumer<ProjectBloc, ProjectState>(
        listener: (context, state) {},
        builder: (context, state) {
          print("Project $role");
          if (role == 'admin') {
            if (state is ProjectLoading) {
              return Center(
                child: CircularProgressIndicator(),
              );
            } else if (state is ProjectLoaded) {
              return Text("data");
            }
          } else {
            return Text("null");
          }
          return Text("tst");
        },
      ),
    );
  }
}
