import 'package:flutter/widgets.dart';

import '../../core/error/app_exception.dart';
import '../../data/models/agent_insight.dart';
import '../../data/repositories/agent_repository.dart';
import 'base_view_model.dart';

/// A sandbox conversation with the agent.
///
/// A dry run on the backend — no credits, no real orders, nothing stored — so
/// the conversation lives only here, and the whole of it is sent with every
/// message.
class AgentTestChatViewModel extends BaseViewModel {
  AgentTestChatViewModel({
    required AgentRepository agents,
    required this.agentId,
  }) : _agents = agents;

  final AgentRepository _agents;
  final String agentId;

  final List<ChatTurn> _turns = [];
  List<ChatTurn> get turns => List.unmodifiable(_turns);

  bool _sending = false;
  bool get isSending => _sending;

  AppException? _lastError;

  /// Why the last message got no reply. Cleared by the next send.
  AppException? get lastError => _lastError;

  final input = TextEditingController();

  Future<void> send() async {
    final text = input.text.trim();
    if (text.isEmpty || _sending) return;

    // The history is what came before this message, not including it.
    final history = List<ChatTurn>.of(_turns);
    _turns.add(ChatTurn.user(text));
    input.clear();
    _sending = true;
    _lastError = null;
    safeNotify();

    final result = await _agents.test(
      agentId: agentId,
      message: text,
      history: history,
    );
    if (isDisposed) return;

    _sending = false;
    final reply = result.valueOrNull;
    if (reply != null) {
      _turns.add(ChatTurn.agent(reply));
    } else {
      _lastError = result.errorOrNull;
    }
    safeNotify();
  }

  @override
  void dispose() {
    input.dispose();
    super.dispose();
  }
}
