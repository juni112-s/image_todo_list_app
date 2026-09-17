import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:http/http.dart' as http;
import 'dart:convert';

class DeleteTodolist extends StatefulWidget {
  const DeleteTodolist({super.key});

  @override
  State<DeleteTodolist> createState() => _DeleteTodolistState();
}

class _DeleteTodolistState extends State<DeleteTodolist> {
  List data = [];

  late int seq;
  bool isPending = true;
  late ImageProvider cachedImage;
  late String title = '';
  late String addedDate;

  @override
  void initState() {
    super.initState();
    readDataFromDB();
  }

  void readDataFromDB() async {
    isPending = true;
    setState(() {});
    var request = await http.get(
      Uri.parse('http://192.168.10.46:8000/todo/select_todo'),
    );
    var decoded = json.decode(utf8.decode(request.bodyBytes));
    print(decoded);
    data = [for (var row in decoded['results']) row];
    print(data);
    title = data[0]['title'];
    seq = data[0]['seq'];
    addedDate = data[0]['added_date'].toString();
    cachedImage = NetworkImage('http://192.168.10.46:8000/todo/select_image/${data[0]['seq']}');
    isPending = false;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Todo list 삭제')),
      body: Center(
        child: isPending
            ? CircularProgressIndicator()
            : Column(
                children: [
                  Image(
                    image: cachedImage,
                    width: Get.width * 0.6,
                    height: Get.width * 0.6,
                    fit: .cover,
                  ),
                  Text(
                    title,
                    style: const TextStyle(fontSize: 20, fontWeight: .w900),
                  ),
                  Text(addedDate),
                  SizedBox(height: 100),
                  ElevatedButton(onPressed: () => deleteDataFromDB(seq), child: Text('삭제하기')),
                ],
              ),
      ),
    );
  }

  void deleteDataFromDB(int seq) async {
    var request = http.MultipartRequest(
      'DELETE',
      Uri.parse('http://192.168.10.46:8000/todo/delete/$seq'),
    );

    var res = await request.send();

    if (res.statusCode == 200) {
      showSucceedDialog();
      readDataFromDB();
    } else {
      errorSnackBar();
    }
  }

  void showSucceedDialog() {
    Get.defaultDialog(
      title: '삭제 결과',
      middleText: '삭제가 완료되었습니다.',
      barrierDismissible: false,
      textConfirm: '확인',
      onConfirm: () {
        Get.back();
        Get.back();
        readDataFromDB();
      },
    );
  }

  void errorSnackBar() {
    Get.snackbar(
      '문제 발생',
      '삭제 중 문제가 발생 했습니다.',
      snackPosition: .TOP,
      duration: const Duration(seconds: 2),
      colorText: Colors.white,
      backgroundColor: Colors.red,
    );
  }
}
