import 'package:flutter/foundation.dart';

import '../../../../data/repositories/copilot_repository.dart';

class CopilotViewModel extends ChangeNotifier {
  CopilotViewModel({required CopilotRepository repository})
      : _repository = repository;

  final CopilotRepository _repository;

  bool _loading = false;
  bool _sending = false;
  String? _conversationId;
  List<String> _messages = const [];

  bool get isLoading => _loading;
  bool get isSending => _sending;
  String? get conversationId => _conversationId;
  List<String> get messages => List.unmodifiable(_messages);

  Future<void> load() async {
    _loading = true;
    notifyListeners();
    final result = await _repository.pending();
    _messages = result.dataOrNull ?? const [];
    _loading = false;
    notifyListeners();
  }

  Future<void> send(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty || _sending) return;

    _messages = [..._messages, trimmed];
    _sending = true;
    notifyListeners();

    var sessionId = _conversationId;
    if (sessionId == null) {
      final session = await _repository.startSession();
      sessionId = session.dataOrNull;
      _conversationId = sessionId;
      if (sessionId == null) {
        _sending = false;
        notifyListeners();
        return;
      }
    }

    await _repository.sendMessage(sessionId, trimmed);
    _sending = false;
    notifyListeners();
  }
}
