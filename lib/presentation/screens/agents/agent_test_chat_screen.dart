import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../app/routes.dart';
import '../../../core/extensions/responsive_extension.dart';
import '../../../data/models/agent.dart';
import '../../../data/repositories/agent_repository.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../../viewmodels/agent_test_chat_view_model.dart';
import '../../widgets/api_error_message.dart';
import '../../widgets/app_icon.dart';
import '../../widgets/icon_square_button.dart';
import 'agent_widgets.dart';

/// Test the agent in a sandbox chat — the web's Test Chat modal as a screen.
///
/// A dry run: no credits, no real orders, nothing stored. Leaving the screen
/// ends the conversation, as closing the web's modal does. Bubbles follow the
/// modal: the merchant's white on the end edge, the agent's dark on the start
/// edge, and `[PRODUCT_CARD:id]` tags in a reply drawn as product cards.
class AgentTestChatScreen extends StatefulWidget {
  const AgentTestChatScreen({super.key, required this.agentId, this.agent});

  final String agentId;

  /// Handed over by the agents screen for the title and the empty state.
  /// Absent when the route is rebuilt without it, which leaves plain copy.
  final Agent? agent;

  @override
  State<AgentTestChatScreen> createState() => _AgentTestChatScreenState();
}

class _AgentTestChatScreenState extends State<AgentTestChatScreen> {
  late final AgentTestChatViewModel _model = AgentTestChatViewModel(
    agents: context.read<AgentRepository>(),
    agentId: widget.agentId,
  );
  final _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    _model.addListener(_toBottom);
  }

  @override
  void dispose() {
    _model.removeListener(_toBottom);
    _model.dispose();
    _scroll.dispose();
    super.dispose();
  }

  /// Keeps the newest message in view.
  void _toBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scroll.hasClients) return;
      _scroll.animateTo(
        _scroll.position.maxScrollExtent,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );
    });
  }

  void _back() {
    final router = GoRouter.of(context);
    if (router.canPop()) {
      router.pop();
    } else {
      router.go(Routes.agents);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);
    final agent = widget.agent;

    return ListenableBuilder(
      listenable: _model,
      builder: (context, _) {
        final turns = _model.turns;
        return Scaffold(
          backgroundColor: AppColors.ink,
          resizeToAvoidBottomInset: true,
          body: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    AppSpacing.gutter,
                    0.47.h,
                    AppSpacing.gutter,
                    AppSpacing.md,
                  ),
                  child: Row(
                    children: [
                      AppBackButton(onBack: _back, semanticLabel: l10n.commonBack),
                      SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Text(
                          agent == null ? l10n.agentsActionTest : l10n.agentsTestTitle(agent.name),
                          style: AppText.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: AppSpacing.gutter),
                  child: Text(
                    l10n.agentsTestNote,
                    style: AppText.bodyS.copyWith(color: AppColors.textMuted),
                  ),
                ),
                SizedBox(height: AppSpacing.md),
                Expanded(
                  child: turns.isEmpty && !_model.isSending
                      ? _EmptyChat(agent: agent)
                      : ListView(
                          controller: _scroll,
                          padding: EdgeInsets.symmetric(
                            horizontal: AppSpacing.gutter,
                            vertical: AppSpacing.sm,
                          ),
                          children: [
                            for (final turn in turns)
                              turn.fromAgent
                                  ? _AgentReply(content: turn.content)
                                  : _UserBubble(content: turn.content),
                            if (_model.isSending) const _Typing(),
                          ],
                        ),
                ),
                if (_model.lastError != null)
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: AppSpacing.gutter),
                    child: Text(
                      '${l10n.agentsTestFailed} ${apiErrorMessage(_model.lastError!, l10n)}',
                      style: AppText.actionS.copyWith(color: AppColors.accentAlert),
                      textAlign: TextAlign.center,
                    ),
                  ),
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    AppSpacing.gutter,
                    AppSpacing.sm,
                    AppSpacing.gutter,
                    AppSpacing.md,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _model.input,
                          enabled: !_model.isSending,
                          textInputAction: TextInputAction.send,
                          onSubmitted: (_) => _model.send(),
                          style: AppText.bodyS.copyWith(color: AppColors.textPrimary),
                          decoration: InputDecoration(hintText: l10n.agentsTestPlaceholder),
                        ),
                      ),
                      SizedBox(width: AppSpacing.sm),
                      ValueListenableBuilder<TextEditingValue>(
                        valueListenable: _model.input,
                        builder: (context, value, _) => FilledButton(
                          style: compactButton,
                          onPressed: _model.isSending || value.text.trim().isEmpty
                              ? null
                              : _model.send,
                          child: Text(l10n.agentsTestSend),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Bubble corners: round, except the one pointing at its speaker.
BorderRadiusDirectional _corners({required bool fromAgent}) {
  const big = Radius.circular(12);
  const small = Radius.circular(2);
  return BorderRadiusDirectional.only(
    topStart: big,
    topEnd: big,
    bottomStart: fromAgent ? small : big,
    bottomEnd: fromAgent ? big : small,
  );
}

/// The web's empty chat: the bot mark, who is being tested, and how.
class _EmptyChat extends StatelessWidget {
  const _EmptyChat({required this.agent});

  final Agent? agent;

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);
    final agent = this.agent;
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: AppSpacing.gutter),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12.3.w, // 48
              height: 12.3.w,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.surfaceHigh,
                borderRadius: BorderRadius.circular(AppRadius.card),
              ),
              child: AppIcon(AppIcons.bot, size: 6.15.w, color: AppColors.textSecondary),
            ),
            SizedBox(height: AppSpacing.md),
            Text(
              agent == null ? l10n.agentsTestEmpty : l10n.agentsTestEmptyFor(agent.name),
              style: AppText.bodyS.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            if (agent != null) ...[
              SizedBox(height: AppSpacing.xs),
              Text(
                [
                  agentPersonalityLabel(agent.personality, l10n),
                  if (agent.aiModel != null) agent.aiModel!,
                ].join(' · '),
                style: AppText.labelMicro,
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// The merchant's message: white, on the end edge.
class _UserBubble extends StatelessWidget {
  const _UserBubble({required this.content});

  final String content;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: AlignmentDirectional.centerEnd,
      child: Container(
        margin: EdgeInsets.only(bottom: AppSpacing.md),
        constraints: BoxConstraints(maxWidth: 80.w),
        padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: 2.56.w),
        decoration: BoxDecoration(
          color: AppColors.textPrimary,
          borderRadius: _corners(fromAgent: false),
        ),
        child: Text(content, style: AppText.bodyS.copyWith(color: AppColors.ink, height: 1.32)),
      ),
    );
  }
}

/// The agent's reply: dark bubbles on the start edge, with each
/// `[PRODUCT_CARD:id]` tag drawn as a product card in its place.
class _AgentReply extends StatelessWidget {
  const _AgentReply({required this.content});

  final String content;

  static final _card = RegExp(r'\[PRODUCT_CARD:([^\]]+)\]');

  @override
  Widget build(BuildContext context) {
    final parts = <Widget>[];
    var last = 0;
    for (final match in _card.allMatches(content)) {
      _addText(parts, content.substring(last, match.start));
      parts.add(_ProductCard(productId: match.group(1)!));
      last = match.end;
    }
    _addText(parts, content.substring(last));

    return Padding(
      padding: EdgeInsets.only(bottom: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var i = 0; i < parts.length; i++) ...[
            if (i > 0) SizedBox(height: AppSpacing.sm),
            parts[i],
          ],
        ],
      ),
    );
  }

  static void _addText(List<Widget> parts, String text) {
    final trimmed = text.trim();
    if (trimmed.isNotEmpty) parts.add(_AgentBubble(text: trimmed));
  }
}

class _AgentBubble extends StatelessWidget {
  const _AgentBubble({required this.text, this.muted = false});

  final String text;
  final bool muted;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(maxWidth: 80.w),
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: 2.56.w),
      decoration: BoxDecoration(
        color: AppColors.surfaceRaised,
        border: Border.all(color: AppColors.rule, width: AppStroke.hairline),
        borderRadius: _corners(fromAgent: true),
      ),
      child: Text(
        text,
        style: AppText.bodyS.copyWith(
          color: muted ? AppColors.textMuted : AppColors.textPrimary,
          height: 1.32,
        ),
      ),
    );
  }
}

class _Typing extends StatelessWidget {
  const _Typing();

  @override
  Widget build(BuildContext context) => Align(
        alignment: AlignmentDirectional.centerStart,
        child: Padding(
          padding: EdgeInsets.only(bottom: AppSpacing.md),
          child: const _AgentBubble(text: '• • •', muted: true),
        ),
      );
}

/// A product the agent put in its reply — the web shows the same placeholder
/// card with the short id.
class _ProductCard extends StatelessWidget {
  const _ProductCard({required this.productId});

  final String productId;

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);
    final shortId = productId.substring(0, math.min(8, productId.length));
    return Container(
      width: 53.33.w, // 208
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.surfaceRaised,
        border: Border.all(color: AppColors.rule, width: AppStroke.hairline),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            height: 24.62.w, // 96
            color: AppColors.surfaceHigh,
            alignment: Alignment.center,
            child: AppIcon(AppIcons.box, size: 6.15.w, color: AppColors.textMuted),
          ),
          Padding(
            padding: EdgeInsets.all(2.56.w), // 10
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.agentsTestProduct,
                  style: AppText.bodyS.copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.w500),
                ),
                Text(
                  l10n.agentsTestProductId(shortId),
                  style: AppText.labelMicro,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
