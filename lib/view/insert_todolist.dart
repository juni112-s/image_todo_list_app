import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class InsertTodolist extends StatefulWidget {
  const InsertTodolist({super.key});

  @override
  State<InsertTodolist> createState() => _InsertTodolistState();
}

class _InsertTodolistState extends State<InsertTodolist> {
  static const String _baseUrl = 'http://192.168.10.46:8000/todo';

  final TextEditingController _titleController = TextEditingController();
  final FixedExtentScrollController _pickerController =
      FixedExtentScrollController();

  List<_TodoImage> _images = const [];
  int _selectedIndex = 0;
  bool _isLoadingImages = true;
  bool _isSaving = false;
  String? _loadError;

  @override
  void initState() {
    super.initState();
    _loadImages();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _pickerController.dispose();
    super.dispose();
  }

  Future<void> _loadImages() async {
    setState(() {
      _isLoadingImages = true;
      _loadError = null;
    });

    try {
      final keyResponse = await http.get(
        Uri.parse('$_baseUrl/read_all_image_keys'),
      );
      if (keyResponse.statusCode != 200) {
        throw Exception('이미지 목록을 불러오지 못했습니다.');
      }

      final decoded = jsonDecode(utf8.decode(keyResponse.bodyBytes));
      final rows = decoded['results'] as List<dynamic>? ?? const [];
      final keys = rows
          .map((row) => (row as Map<String, dynamic>)['seq'])
          .whereType<int>()
          .toList();

      final images = await Future.wait(keys.map(_loadImage));
      if (!mounted) return;

      setState(() {
        _images = images;
        _selectedIndex = 0;
        _isLoadingImages = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loadError = '이미지를 불러오는 중 문제가 발생했습니다.';
        _isLoadingImages = false;
      });
    }
  }

  Future<_TodoImage> _loadImage(int seq) async {
    final response = await http.get(Uri.parse('$_baseUrl/select_image/$seq'));
    if (response.statusCode != 200 ||
        response.headers['content-type']?.startsWith('image/') != true) {
      throw Exception('이미지 $seq번을 불러오지 못했습니다.');
    }
    return _TodoImage(seq: seq, bytes: response.bodyBytes);
  }

  Future<void> _insertTodo() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      _showError('목록을 입력해 주세요.');
      return;
    }
    if (_images.isEmpty) {
      _showError('선택할 수 있는 이미지가 없습니다.');
      return;
    }

    FocusScope.of(context).unfocus();
    setState(() => _isSaving = true);

    final now = DateTime.now();
    final addedDate =
        '${now.year.toString().padLeft(4, '0')}-'
        '${now.month.toString().padLeft(2, '0')}-'
        '${now.day.toString().padLeft(2, '0')}';

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/insert').replace(
          queryParameters: {
            'title': title,
            'added_date': addedDate,
            'image': _images[_selectedIndex].seq.toString(),
          },
        ),
      );
      final body = jsonDecode(utf8.decode(response.bodyBytes));

      if (response.statusCode == 200 && body['result'] == 'OK') {
        Get.back(result: true);
        return;
      }
      throw Exception('등록에 실패했습니다.');
    } catch (_) {
      if (mounted) {
        _showError('목록을 등록하는 중 문제가 발생했습니다.');
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  void _showError(String message) {
    Get.snackbar(
      '알림',
      message,
      snackPosition: SnackPosition.TOP,
      colorText: Colors.white,
      backgroundColor: Colors.redAccent,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add View'), centerTitle: true),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Column(
            children: [
              SizedBox(height: 190, child: Center(child: _buildImagePicker())),
              const SizedBox(height: 28),
              TextField(
                controller: _titleController,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _insertTodo(),
                decoration: const InputDecoration(hintText: '목록을 입력하세요'),
              ),
              const SizedBox(height: 44),
              ElevatedButton(
                onPressed: _isSaving || _isLoadingImages ? null : _insertTodo,
                child: _isSaving
                    ? const SizedBox.square(
                        dimension: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('OK'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImagePicker() {
    if (_isLoadingImages) {
      return const CircularProgressIndicator();
    }
    if (_loadError != null) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(_loadError!, textAlign: TextAlign.center),
          TextButton(onPressed: _loadImages, child: const Text('다시 시도')),
        ],
      );
    }
    if (_images.isEmpty) {
      return const Text('등록된 이미지가 없습니다.');
    }

    return Container(
      width: 170,
      color: Colors.lightBlue.shade50,
      child: CupertinoPicker(
        scrollController: _pickerController,
        itemExtent: 62,
        useMagnifier: true,
        magnification: 1.12,
        selectionOverlay: CupertinoPickerDefaultSelectionOverlay(
          background: Colors.lightBlue.withValues(alpha: 0.16),
        ),
        onSelectedItemChanged: (index) {
          setState(() => _selectedIndex = index);
        },
        children: [
          for (final image in _images)
            Padding(
              padding: const EdgeInsets.all(6),
              child: Image.memory(
                image.bytes,
                width: 52,
                height: 52,
                fit: BoxFit.contain,
                gaplessPlayback: true,
              ),
            ),
        ],
      ),
    );
  }
}

class _TodoImage {
  const _TodoImage({required this.seq, required this.bytes});

  final int seq;
  final Uint8List bytes;
}
