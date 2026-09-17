import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'insert_todolist.dart';

class Todolist extends StatefulWidget {
  const Todolist({super.key});

  @override
  State<Todolist> createState() => _TodolistState();
}

class _TodolistState extends State<Todolist> {
  // Property
  List data = [];

  @override
  void initState() {
    super.initState();
    getTodoList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Todo List 검색'),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () async {
              var result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) {
                    return const InsertTodolist();
                  },
                ),
              );

              if (result == true) {
                getTodoList();
              }
            },
            icon: const Icon(
              Icons.add,
            ),
          ),
        ],
      ),

      body: ListView.builder(
        itemCount: data.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(10, 5, 10, 5,),
            child: Container(
              height: 70,
              decoration: BoxDecoration(
                color: index % 2 == 0
                    ? Colors.amber[100]
                    : Colors.pink[100],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  SizedBox(width: 10,),
                  // Todo 이미지
                  ClipOval(
                    child: Image.network(
                      getImageUrl(data[index]['seq']),
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                      errorBuilder: (
                        context,
                        error,
                        stackTrace,
                      ) {
                        return Icon(
                          Icons.image,
                          size: 50,
                        );
                      },
                    ),
                  ),
                  SizedBox(width: 15,),
                  Expanded(
                    child: Text(
                      '${data[index]['title']} / '
                      '${data[index]['added_date']}',
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  } // build

  Future<void> getTodoList() async {
    var url = Uri.parse('http://192.168.10.46:8000/todo/select_todo',);
    var response = await http.get(url);
    var result = jsonDecode(utf8.decode(response.bodyBytes),);
    data = result['results'];
    setState(() {});
  }

  String getImageUrl(int seq) {
    return 'http://192.168.10.46:8000/todo/select_image$seq';
  }


} // class