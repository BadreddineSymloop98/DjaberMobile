import 'package:flutter/widgets.dart';

import '../../core/error/app_exception.dart';
import '../../core/error/result.dart';
import '../../data/models/conversation.dart';
import '../../data/models/conversation_thread.dart';
import '../../data/repositories/inbox_repository.dart';
import 'base_view_model.dart';

/// `10b — Conversation` — the web inbox's thread pane, as its own screen.
class ConversationViewModel extends BaseViewModel {
  ConversationViewModel({required InboxRepository inbox, required this.conversationId}) : _inbox = inbox;

  final InboxRepository _inbox;
  final String conversationId;

  final input = TextEditingController();

  Conversation? _conversation;
  Conversation? get conversation => _conversation;

  List<ConversationMessage> _messages = const [];
  List<ConversationMessage> get messages => _messages;

  /// Ids of the messages sent from this screen. The API does not say whether
  /// a page message came from the AI or the merchant, so only these can be
  /// labelled "Vous"; the rest take the web's "IA".
  final Set<String> _sentHere = {};
  bool isSentHere(ConversationMessage message) => _sentHere.contains(message.id);

  bool _loadedOnce = false;
  bool get isFirstLoad => !_loadedOnce;

  bool _sending = false;
  bool get isSending => _sending;

  AppException? _sendError;
  AppException? get sendError => _sendError;

  ConversationStatus? _updating;
  bool get isUpdatingStatus => _updating != null;

  /// Something was sent or the status changed — the inbox should re-read.
  bool _changed = false;
  bool get changed => _changed;

  static const _localPrefix = 'local_';

  /// The web lets the merchant reply to an `active` conversation only. A
  /// handed-over one is `resolved` *and* paused (live docs), and it is the one
  /// the merchant most needs to answer — so a paused conversation takes
  /// replies too. The reply endpoint does not check the status.
  bool get canReply {
    final current = _conversation;
    return current != null && (current.isActive || current.aiPaused);
  }

  Future<void> load() async {
    await run(_load, silent: _loadedOnce, tag: 'conversation');
    _loadedOnce = true;
    safeNotify();
  }

  Future<Result<void>> _load() async {
    final result = await _inbox.thread(conversationId);
    final thread = result.valueOrNull;
    if (thread == null) return Result<void>.failure(result.errorOrNull!);
    _conversation = thread.conversation;
    // A message still on its way is not in the answer yet — keep its bubble.
    final pending = _messages.where((m) => m.id.startsWith(_localPrefix));
    _messages = [...thread.messages, ...pending];
    return const Result<void>.success(null);
  }

  /// Sends [preset] (a quick reply) or what is typed. The bubble appears at
  /// once and is taken back, with the text restored, if the send fails.
  Future<bool> send([String? preset]) async {
    final text = (preset ?? input.text).trim();
    if (text.isEmpty || _sending || !canReply) return false;

    final local = ConversationMessage(
      id: '$_localPrefix${DateTime.now().microsecondsSinceEpoch}',
      text: text,
      timestamp: DateTime.now(),
      isFromPage: true,
    );
    _sending = true;
    _sendError = null;
    _messages = [..._messages, local];
    _sentHere.add(local.id);
    if (preset == null) input.clear();
    safeNotify();

    final result = await _inbox.reply(conversationId, text);
    if (isDisposed) return result.errorOrNull == null;
    _sending = false;

    final error = result.errorOrNull;
    if (error != null) {
      _messages = _messages.where((m) => m.id != local.id).toList(growable: false);
      _sentHere.remove(local.id);
      _sendError = error;
      if (preset == null && input.text.isEmpty) input.text = text;
      safeNotify();
      return false;
    }

    _changed = true;
    final storedId = result.valueOrNull;
    if (storedId != null) {
      _sentHere.add(storedId);
      _messages = [for (final m in _messages) m.id == local.id ? m.withId(storedId) : m];
    } else {
      // No id to match the stored copy against: drop the bubble, the reload
      // brings the real one.
      _messages = _messages.where((m) => m.id != local.id).toList(growable: false);
    }
    safeNotify();
    await load();
    return true;
  }

  /// Null on success, or when another change is already running.
  Future<AppException?> setStatus(ConversationStatus status) async {
    final current = _conversation;
    if (current == null || _updating != null) return null;
    _updating = status;
    safeNotify();

    final result = await _inbox.setStatus(conversationId, status);
    if (isDisposed) return result.errorOrNull;
    _updating = null;
    final updated = result.valueOrNull;
    if (updated != null) {
      _conversation = current.copyWith(status: updated.status, aiPaused: updated.aiPaused);
      _changed = true;
    }
    safeNotify();
    return result.errorOrNull;
  }

  @override
  void dispose() {
    input.dispose();
    super.dispose();
  }
}
