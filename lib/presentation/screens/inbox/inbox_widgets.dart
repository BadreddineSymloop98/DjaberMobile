import 'package:flutter/material.dart';
import 'package:intl/intl.dart' show DateFormat;

import '../../../core/extensions/responsive_extension.dart';
import '../../../data/models/connected_page.dart';
import '../../../data/models/conversation.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';

/// "Messenger" or "DM Instagram" — the web's `inbox.platform.*`.
String inboxPlatformLabel(PagePlatform platform, L10n l10n) =>
    platform == PagePlatform.instagram ? l10n.inboxPlatformInstagram : l10n.inboxPlatformMessenger;

/// The list's time — the web's `formatTime`: now, minutes, hours, the
/// weekday within a week, then the date.
String inboxTime(DateTime? at, L10n l10n, String localeTag) {
  if (at == null) return '';
  final local = at.toLocal();
  final elapsed = DateTime.now().difference(local);
  if (elapsed.inMinutes < 1) return l10n.inboxTimeNow;
  if (elapsed.inHours < 1) return l10n.inboxTimeMinutes(elapsed.inMinutes);
  if (elapsed.inDays < 1) return l10n.inboxTimeHours(elapsed.inHours);
  if (elapsed.inDays < 7) return DateFormat('EEE', localeTag).format(local);
  return DateFormat('d MMM', localeTag).format(local);
}

/// "à l'instant", "il y a 2 min" — for the switcher's "synchronisé …".
String inboxAgo(DateTime at, L10n l10n) {
  final elapsed = DateTime.now().difference(at);
  if (elapsed.inMinutes < 1) return l10n.pageCardNow;
  if (elapsed.inHours < 1) return l10n.pageCardMinutesAgo(elapsed.inMinutes);
  return l10n.pageCardHoursAgo(elapsed.inHours);
}

/// A conversation status in words. The web prints the raw English value.
String conversationStatusLabel(String status, L10n l10n) => switch (status) {
      'resolved' => l10n.inboxStatusResolved,
      'archived' => l10n.inboxStatusArchived,
      _ => l10n.inboxStatusActive,
    };

/// The customer's initial in a 40 square — radius 8, the file's frozen
/// style, where the web draws a circle.
class InboxAvatar extends StatelessWidget {
  const InboxAvatar({super.key, required this.name, this.bright = true});

  final String name;

  /// Unread rows and the thread header use `text/primary`; read rows dim it.
  final bool bright;

  @override
  Widget build(BuildContext context) {
    final trimmed = name.trim();
    final initial = trimmed.isEmpty ? '?' : String.fromCharCode(trimmed.runes.first).toUpperCase();
    return Container(
      width: 10.26.w, // 40
      height: 10.26.w,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.ink,
        border: Border.all(color: AppColors.rule, width: AppStroke.hairline),
        borderRadius: BorderRadius.circular(AppRadius.card),
      ),
      child: Text(
        initial,
        style: AppText.title.copyWith(color: bright ? AppColors.textPrimary : AppColors.textSecondary),
      ),
    );
  }
}

/// `Conversation Row` (node `541:5504`) — one line of the inbox.
///
/// Unread (the web's rule) brightens the name and the message and puts the
/// dot on the avatar. The status line is **`IA EN PAUSE`** when the AI handed
/// the conversation over — a mobile addition, the web inbox never shows it —
/// otherwise the status for a conversation that is not active, as the web
/// prints it.
class ConversationRow extends StatelessWidget {
  const ConversationRow({super.key, required this.conversation, required this.time, required this.onTap});

  final Conversation conversation;
  final String time;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);
    final unread = conversation.isUnread;
    final paused = conversation.aiPaused;
    final message = conversation.lastMessage?.trim();
    final text = (message == null || message.isEmpty)
        ? (conversation.hasLastMessage ? l10n.inboxAttachment : '')
        : message;
    final status = paused
        ? l10n.inboxAiPaused
        : conversation.isActive
            ? null
            : conversationStatusLabel(conversation.status, l10n);

    return Semantics(
      button: true,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.md), // 12
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  InboxAvatar(name: conversation.displayName, bright: unread),
                  if (unread)
                    PositionedDirectional(
                      top: -0.77.w, // -3
                      end: -0.77.w,
                      child: Container(
                        width: 2.56.w, // 10
                        height: 2.56.w,
                        decoration: BoxDecoration(
                          color: AppColors.textPrimary,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.surface, width: 2),
                        ),
                      ),
                    ),
                ],
              ),
              SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            conversation.displayName,
                            style: AppText.title.copyWith(
                              color: unread ? AppColors.textPrimary : AppColors.textSecondary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        SizedBox(width: AppSpacing.sm),
                        Text(time.toUpperCase(), style: AppText.labelMeta),
                      ],
                    ),
                    SizedBox(height: AppSpacing.xxs),
                    Text.rich(
                      TextSpan(
                        children: [
                          // The web's ↗: the page wrote last.
                          if (conversation.lastMessageFromPage == true)
                            const TextSpan(text: '↗ ', style: TextStyle(color: AppColors.textMuted)),
                          TextSpan(text: text),
                        ],
                      ),
                      style: AppText.bodyS.copyWith(
                        height: 1.32,
                        color: unread ? AppColors.textSecondary : AppColors.textMuted,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (status != null) ...[
                      SizedBox(height: AppSpacing.xxs),
                      Text(
                        status.toUpperCase(),
                        style: AppText.labelMicro.copyWith(
                          color: paused ? AppColors.textPrimary : AppColors.textMuted,
                        ),
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
