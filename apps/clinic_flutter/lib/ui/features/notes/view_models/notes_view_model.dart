import 'package:flutter/material.dart';

class NoteDraft {
  const NoteDraft({required this.id, required this.body, required this.createdAt});
  final String id;
  final String body;
  final DateTime createdAt;
}

class NotesViewModel extends ChangeNotifier {
  final _controller = TextEditingController();
  final List<NoteDraft> _notes = [];

  TextEditingController get controller => _controller;
  List<NoteDraft> get notes => List.unmodifiable(_notes);

  void addNote() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    _notes.insert(
      0,
      NoteDraft(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        body: text,
        createdAt: DateTime.now(),
      ),
    );
    _controller.clear();
    notifyListeners();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
