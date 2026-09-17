import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class DeleteTodolist extends StatefulWidget {
  const DeleteTodolist({
    super.key,
    required this.seq,
    required this.title,
    required this.addedDate,
    required this.imageKey,
  });

  final int seq;
  final String title;
  final String addedDate;
  final int? imageKey;

  @override
  State<DeleteTodolist> createState() => _DeleteTodolistState();
}

class _DeleteTodolistState extends State<DeleteTodolist> {
  static const String _baseUrl = 'http://192.168.10.46:8000/todo';

  bool _isDeleting = false;

  Future<void> _deleteTodo() async {
    if (_isDeleting) return;
    setState(() => _isDeleting = true);

    try {
      final response = await http.delete(
        Uri.parse('$_baseUrl/delete/${widget.seq}'),
      );
      final body = jsonDecode(utf8.decode(response.bodyBytes));

      if (response.statusCode == 200 && body['result'] == 'OK') {
        _showSuccessDialog();
        return;
      }
      throw Exception('삭제 실패');
    } catch (_) {
      if (mounted) {
        _showError();
      }
    } finally {
      if (mounted) {
        setState(() => _isDeleting = false);
      }
    }
  }

  void _showSuccessDialog() {
    Get.defaultDialog(
      title: '삭제 결과',
      middleText: '삭제가 완료되었습니다.',
      barrierDismissible: false,
      textConfirm: '확인',
      onConfirm: () {
        Get.back();
        Get.back(result: true);
      },
    );
  }

  void _showError() {
    Get.snackbar(
      '문제 발생',
      '삭제 중 문제가 발생했습니다.',
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 2),
      colorText: Colors.white,
      backgroundColor: Colors.red,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Todo list 삭제'), centerTitle: true),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox.square(
                  dimension: Get.width * 0.6,
                  child: _buildImage(),
                ),
                const SizedBox(height: 20),
                Text(
                  widget.title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                Text(widget.addedDate),
                const SizedBox(height: 72),
                ElevatedButton(
                  onPressed: _isDeleting ? null : _deleteTodo,
                  child: _isDeleting
                      ? const SizedBox.square(
                          dimension: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('삭제하기'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImage() {
    if (widget.imageKey == null) {
      return const Icon(Icons.image_not_supported_outlined, size: 96);
    }

    return Image.network(
      '$_baseUrl/select_image/${widget.imageKey}',
      fit: BoxFit.contain,
      errorBuilder: (_, _, _) =>
          const Icon(Icons.broken_image_outlined, size: 96),
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return const Center(child: CircularProgressIndicator());
      },
    );
  }
}
