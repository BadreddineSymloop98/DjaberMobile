import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:provider/provider.dart';

import '../../../app/routes.dart';
import '../../../core/extensions/responsive_extension.dart';
import '../../../data/models/conversation.dart';
import '../../../data/models/conversation_thread.dart';
import '../../../data/repositories/inbox_repository.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../../viewmodels/conversation_view_model.dart';
import '../../widgets/api_error_message.dart';
import '../../widgets/app_icon.dart';
import '../../widgets/app_toast.dart';
import '../../widgets/back_scope.dart';
import '../../widgets/icon_square_button.dart';
import '../../widgets/leave_sheet.dart';
import '../agents/agent_widgets.dart' show compactButton;
import 'inbox_widgets.dart';

/// `10b — Conversation` (and `10b · terminée`) — the web inbox's thread pane.
///
/// Pushed from the inbox, home's queue and a live notification, so back pops
/// to where it was opened. Reached alone (a cold deep link, a splash replay),
/// back goes to the inbox, the parent `router.dart` declares. A typed reply
/// asks before it is dropped.
///
/// **Actions follow the backend's handoff semantics** (live docs): a handed
/// over conversation is `resolved` *and* `aiPaused`, and setting it `active`
/// resumes the AI. So:
///
/// | State | Header | Composer |
/// |---|---|---|
/// | active | *Marquer terminé* (white) · archive | open, quick replies |
/// | paused | archive; the notice offers *Réactiver l'IA* | open, quick replies |
/// | resolved / archived, not paused | *Rouvrir* · archive | closed + the web's hint |
///
/// The web closes the composer for anything not `active`; a paused
/// conversation is the one the merchant must be able to answer, so it stays
/// open there. The notice is a mobile addition.
class ConversationScreen extends StatefulWidget {
  const ConversationScreen({super.key, required this.conversationId});

  final String conversationId;

  @override
  State<ConversationScreen> createState() => _ConversationScreenState();
}

class _ConversationScreenState extends State<ConversationScreen> {
  late final ConversationViewModel _model = ConversationViewModel(
    inbox: context.read<InboxRepository>(),
    conversationId: widget.conversationId,
  );

  final _scroll = ScrollController();
  Timer? _poll;
  int _shownCount = 0;

  /// The web's fixed quick replies, verbatim — French in every language, as
  /// there.
  static const _quickReplies = ['Bonjour 👋', 'Merci pour votre message', 'Disponible, oui', 'Je vous envoie le détail'];

  /// A customer's next message only reaches the phone by asking: push is not
  /// wired (brief §7). A cheap GET while the thread is open.
  static const _pollEvery = Duration(seconds: 15);

  late final AppLifecycleListener _lifecycle = AppLifecycleListener(
    onResume: () {
      if (!_model.isFirstLoad) _model.load();
    },
  );

  @override
  void initState() {
    super.initState();
    _lifecycle;
    _model.addListener(_followNewMessages);
    WidgetsBinding.instance.addPostFrameCallback((_) => _model.load());
    _poll = Timer.periodic(_pollEvery, (_) {
      if (!_model.isFirstLoad && !_model.isSending) _model.load();
    });
  }

  @override
  void dispose() {
    _poll?.cancel();
    _lifecycle.dispose();
    _model.removeListener(_followNewMessages);
    _model.dispose();
    _scroll.dispose();
    super.dispose();
  }

  /// Scrolls to the newest message when one arrives — unless the merchant has
  /// scrolled up to read, which a poll must not yank them out of.
  void _followNewMessages() {
    final count = _model.messages.length;
    if (count == _shownCount) return;
    final first = _shownCount == 0;
    final atBottom = !_scroll.hasClients || _scroll.position.pixels >= _scroll.position.maxScrollExtent - 64;
    _shownCount = count;
    if (!first && !atBottom) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) _scroll.jumpTo(_scroll.position.maxScrollExtent);
    });
  }

  /// Closes the thread after an archive. An explicit pop, so the leave sheet
  /// is not asked; back itself goes through the route's [BackScope].
  void _close() {
    final router = GoRouter.of(context);
    if (router.canPop()) {
      router.pop(_model.changed);
    } else {
      router.go(Routes.inbox);
    }
  }

  /// A typed reply is work back would drop, so it asks. While a send is in
  /// flight the press is ignored: the reply is already on its way, and "your
  /// unsent reply will be lost" would be untrue.
  Future<bool> _onBack() async {
    if (_model.isSending) return false;
    return showLeaveSheet(context, body: L10n.of(context).conversationLeaveBody);
  }

  Future<void> _setStatus(ConversationStatus status) async {
    final l10n = L10n.of(context);
    final wasPaused = _model.conversation?.aiPaused ?? false;
    final error = await _model.setStatus(status);
    if (!mounted) return;
    if (error != null) {
      AppToast.info(context, apiErrorMessage(error, l10n));
      return;
    }
    AppToast.success(context, switch (status) {
      ConversationStatus.resolved => l10n.conversationResolvedToast,
      ConversationStatus.archived => l10n.conversationArchivedToast,
      ConversationStatus.active => wasPaused ? l10n.conversationAiResumedToast : l10n.conversationReopenedToast,
    });
    // The web closes the thread on archive.
    if (status == ConversationStatus.archived) _close();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);

    // Back pops to the inbox or home when one is below, or goes to the inbox
    // (the route's parent). The composer is listened to as well, so the
    // intercept turns on with the first typed character.
    return ListenableBuilder(
      listenable: Listenable.merge([_model, _model.input]),
      builder: (context, _) {
        final conversation = _model.conversation;
        return BackIntercept(
          active: _model.input.text.trim().isNotEmpty || _model.isSending,
          onBack: _onBack,
          child: Scaffold(
            backgroundColor: AppColors.ink,
            resizeToAvoidBottomInset: true,
            body: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _Header(
                    conversation: conversation,
                    busy: _model.isUpdatingStatus,
                    onBack: () => BackScope.back(context),
                    onStatus: _setStatus,
                  ),
                  if (conversation != null && conversation.aiPaused)
                    _PausedNotice(
                      busy: _model.isUpdatingStatus,
                      onResume: () => _setStatus(ConversationStatus.active),
                    ),
                  Expanded(child: _thread(l10n)),
                  if (conversation != null) _composer(l10n),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _thread(L10n l10n) {
    if (_model.isFirstLoad) {
      return const Center(
        child: SizedBox.square(
          dimension: 20,
          child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.textMuted),
        ),
      );
    }
    if (_model.conversation == null) {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: AppSpacing.gutter),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ApiErrorLine(error: _model.error),
            OutlinedButton(onPressed: _model.load, child: Text(l10n.commonRetry)),
          ],
        ),
      );
    }
    final messages = _model.messages;
    if (messages.isEmpty) {
      return Center(
        child: Text(l10n.conversationEmpty, style: AppText.bodyS.copyWith(color: AppColors.textMuted)),
      );
    }
    return ListView.builder(
      controller: _scroll,
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.gutterTight, vertical: AppSpacing.sm),
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final message = messages[index];
        final previous = index == 0 ? null : messages[index - 1];
        return _MessageLine(
          message: message,
          // The web's grouping: a new speaker opens a group, and only the
          // group's first message carries the time.
          startsGroup: previous == null || previous.isFromPage != message.isFromPage,
          sentHere: _model.isSentHere(message),
        );
      },
    );
  }

  Widget _composer(L10n l10n) {
    final canReply = _model.canReply;
    final sending = _model.isSending;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(height: AppStroke.hairline, color: AppColors.rule),
        if (canReply)
          Padding(
            padding: EdgeInsets.fromLTRB(AppSpacing.gutterTight, AppSpacing.md, AppSpacing.gutterTight, AppSpacing.xs),
            child: Wrap(
              spacing: 1.54.w, // 6
              runSpacing: 1.54.w,
              children: [
                for (final reply in _quickReplies)
                  Semantics(
                    button: true,
                    child: GestureDetector(
                      onTap: sending ? null : () => _model.send(reply),
                      behavior: HitTestBehavior.opaque,
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 2.56.w, vertical: 1.54.w), // 10 · 6
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.rule, width: AppStroke.hairline),
                          borderRadius: BorderRadius.circular(AppRadius.input),
                        ),
                        child: Text(
                          reply,
                          style: AppText.bodyS.copyWith(
                            color: sending ? AppColors.textMuted : AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        if (_model.sendError != null)
          Padding(
            padding: EdgeInsets.fromLTRB(AppSpacing.gutterTight, AppSpacing.sm, AppSpacing.gutterTight, 0),
            child: ApiErrorLine(error: _model.sendError),
          ),
        Padding(
          padding: EdgeInsets.fromLTRB(
            AppSpacing.gutterTight,
            AppSpacing.sm,
            AppSpacing.gutterTight,
            canReply ? AppSpacing.md : AppSpacing.sm,
          ),
          child: Opacity(
            opacity: canReply ? 1 : 0.35,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: TextField(
                    controller: _model.input,
                    enabled: canReply,
                    minLines: 1,
                    maxLines: 4,
                    keyboardType: TextInputType.multiline,
                    textCapitalization: TextCapitalization.sentences,
                    style: AppText.bodyS.copyWith(color: AppColors.textPrimary),
                    decoration: InputDecoration(hintText: l10n.conversationReplyHint),
                  ),
                ),
                SizedBox(width: AppSpacing.sm),
                ValueListenableBuilder<TextEditingValue>(
                  valueListenable: _model.input,
                  builder: (context, value, _) => FilledButton(
                    style: compactButton,
                    onPressed: canReply && !sending && value.text.trim().isNotEmpty ? _model.send : null,
                    child: Text(sending ? l10n.conversationSending : l10n.conversationSend),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (!canReply)
          Padding(
            padding: EdgeInsets.fromLTRB(AppSpacing.gutterTight, 0, AppSpacing.gutterTight, AppSpacing.lg),
            child: Text(
              l10n.conversationReopenHint,
              textAlign: TextAlign.center,
              style: AppText.bodyS.copyWith(color: AppColors.textMuted),
            ),
          ),
      ],
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.conversation, required this.busy, required this.onBack, required this.onStatus});

  final Conversation? conversation;
  final bool busy;
  final VoidCallback onBack;
  final ValueChanged<ConversationStatus> onStatus;

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);
    final current = conversation;
    final showResolve = current != null && current.isActive && !current.aiPaused;
    final showReopen = current != null && !current.isActive && !current.aiPaused;
    final showArchive = current != null && !current.isArchived;
    final meta = current == null
        ? ''
        : [
            conversationStatusLabel(current.status, l10n),
            // The platform gives way when *Rouvrir* needs the width.
            if (!showReopen) inboxPlatformLabel(current.platform, l10n),
          ].join(' · ');

    return Padding(
      padding: EdgeInsets.fromLTRB(AppSpacing.gutterTight, 0.47.h, AppSpacing.gutterTight, AppSpacing.lg),
      child: Row(
        children: [
          AppBackButton(onBack: onBack, semanticLabel: l10n.commonBack),
          SizedBox(width: 2.56.w), // 10
          if (current != null) ...[
            InboxAvatar(name: current.displayName),
            SizedBox(width: 2.56.w),
          ],
          Expanded(
            child: current == null
                ? const SizedBox.shrink()
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        current.displayName,
                        // Figma's `Display/S` is 16; the code token is 20 — the
                        // file wins (brief, style frozen).
                        style: AppText.displayS.copyWith(fontSize: 16.sp),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: AppSpacing.xxs),
                      Text(
                        meta.toUpperCase(),
                        style: AppText.labelMeta,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
          ),
          IgnorePointer(
            ignoring: busy,
            child: Opacity(
              opacity: busy ? 0.4 : 1,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (showResolve) ...[
                    SizedBox(width: 2.56.w),
                    _ResolveButton(label: l10n.conversationMarkResolved, onTap: () => onStatus(ConversationStatus.resolved)),
                  ],
                  if (showReopen) ...[
                    SizedBox(width: 2.56.w),
                    OutlinedButton(
                      style: compactButton,
                      onPressed: () => onStatus(ConversationStatus.active),
                      child: Text(l10n.conversationReopen),
                    ),
                  ],
                  if (showArchive) ...[
                    SizedBox(width: 2.56.w),
                    IconSquareButton(
                      icon: AppIcons.close,
                      onTap: () => onStatus(ConversationStatus.archived),
                      semanticLabel: l10n.conversationArchive,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// The web's white *Marquer terminé*, as a square.
class _ResolveButton extends StatelessWidget {
  const _ResolveButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(
            color: AppColors.textPrimary,
            borderRadius: BorderRadius.circular(AppRadius.card),
          ),
          child: AppIcon(AppIcons.checkCircle, size: 6.15.w, color: AppColors.ink),
        ),
      ),
    );
  }
}

/// `IA EN PAUSE` — mobile addition, shown while `aiPaused`.
class _PausedNotice extends StatelessWidget {
  const _PausedNotice({required this.busy, required this.onResume});

  final bool busy;
  final VoidCallback onResume;

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);
    return Padding(
      padding: EdgeInsets.fromLTRB(AppSpacing.gutterTight, 0, AppSpacing.gutterTight, AppSpacing.md),
      child: Container(
        padding: EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border.all(color: AppColors.ruleStrong, width: AppStroke.hairline),
          borderRadius: BorderRadius.circular(AppRadius.card),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.inboxAiPaused.toUpperCase(), style: AppText.labelMeta.copyWith(color: AppColors.textPrimary)),
            SizedBox(height: AppSpacing.xs),
            Text(
              l10n.conversationPausedNotice,
              style: AppText.bodyS.copyWith(height: 1.32, color: AppColors.textSecondary),
            ),
            SizedBox(height: AppSpacing.sm),
            OutlinedButton(
              style: compactButton,
              onPressed: busy ? null : onResume,
              child: Text(l10n.conversationResumeAi),
            ),
          ],
        ),
      ),
    );
  }
}

/// One message: the customer on the start edge in a quiet bubble, the page on
/// the end edge in white — the web's layout.
class _MessageLine extends StatelessWidget {
  const _MessageLine({required this.message, required this.startsGroup, required this.sentHere});

  final ConversationMessage message;
  final bool startsGroup;
  final bool sentHere;

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);
    final tag = Localizations.localeOf(context).toLanguageTag();
    final fromPage = message.isFromPage;
    final at = message.timestamp;

    final parts = <Widget>[
      if (message.hasImage) _Photo(url: message.attachmentUrl!),
      if (message.hasFile) _FileChip(type: message.attachmentType!),
      if (message.hasText) _Bubble(text: message.text!.trim(), fromPage: fromPage),
      if (!message.hasText && message.attachmentUrl == null)
        _Bubble(text: l10n.inboxEmptyMessage, fromPage: fromPage, muted: true),
    ];

    return Padding(
      padding: EdgeInsets.only(top: startsGroup ? AppSpacing.md : AppSpacing.xxs),
      child: Align(
        alignment: fromPage ? AlignmentDirectional.centerEnd : AlignmentDirectional.centerStart,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 72.w),
          child: Column(
            crossAxisAlignment: fromPage ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              for (var i = 0; i < parts.length; i++) ...[
                if (i > 0) SizedBox(height: AppSpacing.xs),
                parts[i],
              ],
              if (startsGroup && at != null)
                Padding(
                  padding: EdgeInsets.fromLTRB(AppSpacing.xxs, AppSpacing.xs, AppSpacing.xxs, 0),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(DateFormat.Hm(tag).format(at.toLocal()), style: AppText.labelMicro),
                      if (fromPage) ...[
                        SizedBox(width: AppSpacing.xs),
                        if (!sentHere) ...[
                          AppIcon(AppIcons.bot, size: 3.08.w, color: AppColors.textMuted),
                          SizedBox(width: AppSpacing.xxs),
                        ],
                        Text(
                          (sentHere ? l10n.conversationAuthorYou : l10n.conversationAuthorAi).toUpperCase(),
                          style: AppText.labelMicro,
                        ),
                      ],
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Bubble extends StatelessWidget {
  const _Bubble({required this.text, required this.fromPage, this.muted = false});

  final String text;
  final bool fromPage;
  final bool muted;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm), // 12 · 8
      decoration: BoxDecoration(
        color: fromPage ? AppColors.textPrimary : AppColors.surfaceHigh,
        border: fromPage ? null : Border.all(color: const Color(0x1FFFFFFF), width: AppStroke.hairline), // line/edge
        borderRadius: BorderRadius.circular(AppRadius.card),
      ),
      child: Text(
        text,
        style: AppText.bodyS.copyWith(
          height: 1.32,
          color: muted ? AppColors.textMuted : (fromPage ? AppColors.ink : AppColors.textPrimary),
          fontStyle: muted ? FontStyle.italic : null,
        ),
      ),
    );
  }
}

/// A photo the customer sent. Meta's links expire, so a failed load shows the
/// placeholder instead of an error.
class _Photo extends StatelessWidget {
  const _Photo({required this.url});

  final String url;

  @override
  Widget build(BuildContext context) {
    final placeholder = Container(
      color: AppColors.surfaceHigh,
      alignment: Alignment.center,
      child: AppIcon(AppIcons.box, size: 6.15.w, color: AppColors.textMuted),
    );
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.card),
      child: SizedBox(
        width: 46.15.w, // 180
        height: 33.85.w, // 132
        child: CachedNetworkImage(
          imageUrl: url,
          fit: BoxFit.cover,
          placeholder: (_, _) => placeholder,
          errorWidget: (_, _, _) => placeholder,
        ),
      ),
    );
  }
}

/// Any other attachment, by its type — the web's 📎 chip.
class _FileChip extends StatelessWidget {
  const _FileChip({required this.type});

  final String type;

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.surfaceHigh,
        border: Border.all(color: AppColors.rule, width: AppStroke.hairline),
        borderRadius: BorderRadius.circular(AppRadius.card),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppIcon(AppIcons.fileText, size: 3.59.w, color: AppColors.textSecondary),
          SizedBox(width: AppSpacing.xs),
          Text('${l10n.inboxAttachment} · $type', style: AppText.bodyS.copyWith(color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}
