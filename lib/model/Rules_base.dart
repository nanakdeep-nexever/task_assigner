class Role {
  final String id;
  final String name;

  Role({required this.id, required this.name});
}

final roles = {
  'admin': Role(id: '1', name: 'Admin'),
  'manager': Role(id: '2', name: 'Manager'),
  'developer': Role(id: '3', name: 'Developer'),
  'viewer': Role(id: '4', name: 'Viewer'),
};

final rolePermissions = {
  'admin': [
    'create_user',
    'delete_user',
    'create_project',
    'assign_task',
    'view_tasks'
  ],
  'manager': ['create_project', 'assign_task', 'view_tasks'],
  'developer': ['update_task', 'view_tasks'],
  'viewer': ['view_tasks'],
};
