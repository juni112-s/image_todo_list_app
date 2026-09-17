import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:imagetodolist_app/view/todolist.dart';

import 'view/insert_todolist.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: .fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const InsertTodolist(),
    );
  }
}
