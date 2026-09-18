import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:imagetodolist_app/view/delete_todolist.dart';
import 'package:imagetodolist_app/view/insert_todolist.dart';

class Todolist extends StatefulWidget {
  const Todolist({super.key});

  @override
  State<Todolist> createState() => _TodolistState();
}

class _TodolistState extends State<Todolist> {
  static const String _baseUrl = 'http://192.168.10.46:8000/todo';
  static const List<Color> _cardColors = [Color(0xFFFFF1AD), Color(0xFFF5B6CB)];

  List<_TodoItem> _todoList = const [];
  bool _isLoading = true;
  String? _loadError;

  @override
  void initState() {
    super.initState();
    _readTodoList();
  }

  Future<void> _readTodoList() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
        _loadError = null;
      });
    }

    try {
      final response = await http.get(Uri.parse('$_baseUrl/select_todo'));
      if (response.statusCode != 200) {
        throw Exception('목록 조회 실패');
      }

      final decoded = jsonDecode(utf8.decode(response.bodyBytes));
      final rows = decoded['results'] as List<dynamic>? ?? const [];
      final todoList = rows.map((row) {
        final item = row as Map<String, dynamic>;
        return _TodoItem(
          seq: item['seq'] as int,
          title: item['title']?.toString() ?? '',
          addedDate: item['added_date']?.toString() ?? '',
          imageKey: item['image_key'] as int?,
        );
      }).toList();

      if (!mounted) return;
      setState(() {
        _todoList = todoList;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loadError = '목록을 불러오는 중 문제가 발생했습니다.';
        _isLoading = false;
      });
    }
  }

  Future<void> _openInsertPage() async {
    final result = await Get.to<bool>(() => const InsertTodolist());
    if (result == true) {
      await _readTodoList();
    }
  }

  Future<void> _openDeletePage(_TodoItem item) async {
    final result = await Get.to<bool>(
      () => DeleteTodolist(
        seq: item.seq,
        title: item.title,
        addedDate: item.addedDate,
        imageKey: item.imageKey,
      ),
    );
    if (result == true) {
      await _readTodoList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Todo List 검색'),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: _openInsertPage,
            tooltip: '할 일 추가',
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_loadError != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_loadError!),
            const SizedBox(height: 8),
            TextButton(onPressed: _readTodoList, child: const Text('다시 시도')),
          ],
        ),
      );
    }

    if (_todoList.isEmpty) {
      return RefreshIndicator(
        onRefresh: _readTodoList,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: const [
            SizedBox(height: 240),
            Center(child: Text('등록된 정보가 없습니다.')),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _readTodoList,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        itemCount: _todoList.length,
        itemBuilder: (context, index) {
          final item = _todoList[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Slidable(
                key: ValueKey(item.seq),
                endActionPane: ActionPane(
                  motion: const DrawerMotion(),
                  extentRatio: 0.25,
                  children: [
                    SlidableAction(
                      onPressed: (_) => _openDeletePage(item),
                      backgroundColor: Colors.redAccent,
                      foregroundColor: Colors.white,
                      icon: Icons.delete_outline,
                      label: '삭제',
                    ),
                  ],
                ),
                child: _TodoCard(
                  item: item,
                  color: _cardColors[index % _cardColors.length],
                  imageUrl: item.imageKey == null
                      ? null
                      : '$_baseUrl/select_image/${item.imageKey}',
                  onTap: () => _openDeletePage(item),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _TodoCard extends StatelessWidget {
  const _TodoCard({
    required this.item,
    required this.color,
    required this.imageUrl,
    required this.onTap,
  });

  final _TodoItem item;
  final Color color;
  final String? imageUrl;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          height: 66,
          child: Row(
            children: [
              const SizedBox(width: 8),
              SizedBox.square(dimension: 54, child: _buildImage()),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${item.title} / ${item.addedDate}',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 13),
                ),
              ),
              const SizedBox(width: 12),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImage() {
    if (imageUrl == null) {
      return const Icon(Icons.image_not_supported_outlined, size: 38);
    }

    return Image.network(
      imageUrl!,
      fit: BoxFit.contain,
      errorBuilder: (_, _, _) =>
          const Icon(Icons.broken_image_outlined, size: 38),
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return const Padding(
          padding: EdgeInsets.all(16),
          child: CircularProgressIndicator(strokeWidth: 2),
        );
      },
    );
  }
}

class _TodoItem {
  const _TodoItem({
    required this.seq,
    required this.title,
    required this.addedDate,
    required this.imageKey,
  });

  final int seq;
  final String title;
  final String addedDate;
  final int? imageKey;
}
