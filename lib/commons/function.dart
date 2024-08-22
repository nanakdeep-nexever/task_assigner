import 'package:flutter/cupertino.dart';

Future<T?> pushNamed<T>(BuildContext context, String route,
    [dynamic args]) async {
  return await Navigator.pushNamed(context, route, arguments: args);
}
