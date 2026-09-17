import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';

class Todolist extends StatefulWidget {
  const Todolist({super.key});

  @override
  State<Todolist> createState() => _TodolistState();
}

class _TodolistState extends State<Todolist> {
  List todoList = [];

  @override
  void initState() {
    super.initState();
    //
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Todo List'),
        actions: [
          IconButton(
            onPressed: () {
              //Get
            }, 
            icon: Icon(Icons.delete_outline)),
          IconButton(
            onPressed: () {
              //showAddDialog();
            }, 
            icon: Icon(Icons.add_outlined)),
        ],
      ),
      body:Center(
        child: todoList.isEmpty
        ? Text('등록된 정보가 없습니다.')
        : ListView.builder(
          itemCount: todoList.length,
          itemBuilder: (context, index) {
            return Slidable(
              key: ValueKey(todoList[index]['seq']),
              startActionPane:  ActionPane(
                motion: DrawerMotion(),
                extentRatio: 0.25,
                children: [
                  SlidableAction(
                    onPressed: (context) {
                      //
                    },
                  ),
                ]
              ),
              child: Card()
            );
          },
        ),
      )
    );
  }
}