import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:provider/provider.dart';

import '../../../core/extensions/responsive_extension.dart';
import '../../../core/utils/money.dart';
import '../../../data/models/client.dart';
import '../../../data/repositories/client_repository.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../../viewmodels/client_detail_view_model.dart';
import '../../widgets/api_error_message.dart';
import '../../widgets/app_icon.dart';
import '../../widgets/app_toast.dart';
import '../../widgets/back_scope.dart';
import '../../widgets/home_widgets.dart';
import '../../widgets/icon_square_button.dart';
import 'client_form_sheet.dart';

/// `Client details` (Figma `639:9393`) — the web's *Client Details* modal as a
/// screen.
///
/// Name and source; phone, e-mail and address; total orders, total spent and
/// last order; the AI conversation metrics and history when the client has
/// conversations (the web hides both otherwise); notes; then *Voir les
/// commandes* and *Modifier le client*.
///
/// Returns `true` to the list when the client was edited, so its row reloads.
class ClientDetailScreen extends StatefulWidget {
  const ClientDetailScreen({super.key, required this.clientId});

  final String clientId;

  @override
  State<ClientDetailScreen> createState() => _ClientDetailScreenState();
}

class _ClientDetailScreenState extends State<ClientDetailScreen> {
  late final ClientDetailViewModel _model = ClientDetailViewModel(
    clients: context.read<ClientRepository>(),
    clientId: widget.clientId,
  );

  bool _edited = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _model.load());
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  Future<void> _edit(Client client) async {
    final l10n = L10n.of(context);
    final saved = await showClientFormSheet(
      context,
      clients: context.read<ClientRepository>(),
      // The details screen has no list to check against; a duplicate phone is
      // still caught by the server's 400.
      knownPhones: const {},
      editing: client,
    );
    if (saved == null || !mounted) return;
    setState(() => _edited = true);
    AppToast.success(context, l10n.clientUpdated);
    await _model.load();
  }

  /// The web opens the orders page filtered on this client. The orders screen
  /// is not built on mobile yet, so this says so rather than opening an
  /// unfiltered placeholder.
  void _viewOrders() => AppToast.info(context, L10n.of(context).clientOrdersSoon);

  Future<bool> _onBack() async {
    final router = GoRouter.of(context);
    if (router.canPop()) {
      router.pop(true);
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);

    return ListenableBuilder(
      listenable: _model,
      builder: (context, _) => BackIntercept(
        active: _edited,
        onBack: _onBack,
        child: Scaffold(
          backgroundColor: AppColors.ink,
          body: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(AppSpacing.gutterTight, 0.47.h, AppSpacing.gutter, AppSpacing.lg),
                  child: Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: AppBackButton(semanticLabel: l10n.commonBack),
                  ),
                ),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: _model.load,
                    color: AppColors.textPrimary,
                    backgroundColor: AppColors.surface,
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: EdgeInsets.fromLTRB(AppSpacing.gutterTight, 0, AppSpacing.gutterTight, AppSpacing.xxl),
                      children: _content(l10n),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _content(L10n l10n) {
    if (_model.isFirstLoad) {
      return [
        Padding(
          padding: EdgeInsets.symmetric(vertical: AppSpacing.huge),
          child: const Center(
            child: SizedBox.square(
              dimension: 20,
              child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.textMuted),
            ),
          ),
        ),
      ];
    }
    final client = _model.client;
    if (client == null) {
      return [
        ApiErrorLine(error: _model.error),
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: OutlinedButton(onPressed: _model.load, child: Text(l10n.commonRetry)),
        ),
      ];
    }

    final tag = Localizations.localeOf(context).toLanguageTag();
    final date = DateFormat.yMd(tag);
    final metrics = _model.metrics;
    final hasConversations =
        metrics != null && (metrics.conversationCount > 0 || metrics.conversations.isNotEmpty);
    final notes = client.notes?.trim();

    Widget section(String label) => Padding(
          padding: EdgeInsets.fromLTRB(AppSpacing.xs, AppSpacing.xxl, AppSpacing.xs, AppSpacing.md),
          child: Text(label.toUpperCase(), style: AppText.labelSection),
        );

    return [
      if (_model.error != null) ApiErrorLine(error: _model.error),
      Padding(
        padding: EdgeInsets.symmetric(horizontal: AppSpacing.xs),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.clientDetailEyebrow, style: AppText.labelMeta),
            SizedBox(height: AppSpacing.md),
            Text(client.name, style: AppText.displayM),
            SizedBox(height: AppSpacing.xs),
            Text(
              (client.source == ClientSource.ai ? l10n.clientsSourceAi : l10n.clientsSourceManual).toUpperCase(),
              style: AppText.labelMeta,
            ),
          ],
        ),
      ),
      SizedBox(height: AppSpacing.xl),

      // ---- Contact ----
      ListBox(
        children: [
          _Fact(label: l10n.clientPhone, value: client.phone ?? '—'),
          _Fact(label: l10n.authEmail, value: client.email ?? '—'),
          _Fact(label: l10n.clientAddress, value: client.address ?? '—'),
        ],
      ),
      SizedBox(height: AppSpacing.xl),

      // ---- Orders ----
      IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: KpiTile(
                label: l10n.clientDetailTotalOrders,
                value: Money.grouped(client.totalOrders, tag),
                icon: AppIcons.clipboard,
                iconColor: AppColors.accentMoney,
              ),
            ),
            SizedBox(width: AppSpacing.sm),
            Expanded(
              child: KpiTile(
                label: l10n.clientsStatTotalSpent,
                value: Money.grouped(client.totalSpent.round(), tag),
                unit: 'DA',
                icon: AppIcons.dollar,
                iconColor: AppColors.accentMoney,
              ),
            ),
          ],
        ),
      ),
      SizedBox(height: AppSpacing.sm),
      KpiTile(
        label: l10n.clientDetailLastOrder,
        value: client.lastOrderDate == null ? '—' : date.format(client.lastOrderDate!.toLocal()),
        icon: AppIcons.clock,
        iconColor: AppColors.accentMoney,
      ),

      // ---- AI metrics, only when there are conversations (as the web) ----
      if (hasConversations) ...[
        section(l10n.clientDetailMetrics),
        ListBox(
          children: [
            _Fact(label: l10n.clientDetailConversations, value: '${metrics.conversationCount}'),
            _Fact(label: l10n.clientDetailMessages, value: '${metrics.totalMessages}'),
            _Fact(label: l10n.clientDetailAiResponses, value: '${metrics.aiResponseCount}'),
            _Fact(label: l10n.clientDetailClientMessages, value: '${metrics.messagesReceived}'),
            _Fact(
              label: l10n.clientDetailLastMessage,
              value: metrics.lastMessageDate == null ? '—' : date.format(metrics.lastMessageDate!.toLocal()),
            ),
          ],
        ),
        if (metrics.conversations.isNotEmpty) ...[
          section(l10n.clientDetailHistory),
          ListBox(
            children: [
              for (final conversation in metrics.conversations) _ConversationLine(conversation: conversation),
            ],
          ),
        ],
      ],

      // ---- Notes ----
      if (notes != null && notes.isNotEmpty) ...[
        section(l10n.clientNotes),
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.surface,
            border: Border.all(color: AppColors.rule, width: AppStroke.hairline),
            borderRadius: BorderRadius.circular(AppRadius.card),
          ),
          child: Text(notes, style: AppText.bodyS.copyWith(color: AppColors.textSecondary, height: 1.4)),
        ),
      ],

      SizedBox(height: AppSpacing.xxl),
      FilledButton(onPressed: _viewOrders, child: Text(l10n.clientViewOrders)),
      SizedBox(height: AppSpacing.sm),
      OutlinedButton(onPressed: () => _edit(client), child: Text(l10n.clientEditTitle)),
    ];
  }
}

class _Fact extends StatelessWidget {
  const _Fact({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppText.bodyS.copyWith(color: AppColors.textMuted)),
          SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(value, textAlign: TextAlign.end, style: AppText.title),
          ),
        ],
      ),
    );
  }
}

/// One conversation: page name and message count, `PLATFORM · STATUS`, then the
/// last message prefixed *IA :* or *Client :* — the web's history card.
class _ConversationLine extends StatelessWidget {
  const _ConversationLine({required this.conversation});

  final ClientConversation conversation;

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);
    final last = conversation.lastMessage?.trim();

    return Padding(
      padding: EdgeInsets.all(AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  conversation.pageName ?? conversation.platform,
                  style: AppText.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: AppSpacing.xxs),
                Text(
                  '${conversation.platform}  ·  ${conversation.status}'.toUpperCase(),
                  style: AppText.labelMeta,
                ),
                if (last != null && last.isNotEmpty) ...[
                  SizedBox(height: AppSpacing.xxs),
                  Text(
                    '${conversation.lastMessageIsFromPage ? l10n.clientDetailFromAi : l10n.clientDetailFromClient} $last',
                    style: AppText.bodyS.copyWith(color: AppColors.textSecondary),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          SizedBox(width: AppSpacing.sm),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('${conversation.messageCount}', style: AppText.numeralM),
              Text(l10n.clientDetailMsgs, style: AppText.labelMicro),
            ],
          ),
        ],
      ),
    );
  }
}
