import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../core/extensions/responsive_extension.dart';
import '../../../data/repositories/delivery_repository.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../../viewmodels/delivery_fees_view_model.dart';
import '../../widgets/api_error_message.dart';
import '../../widgets/app_icon.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/app_toast.dart';
import '../../widgets/back_scope.dart';
import '../../widgets/home_widgets.dart';
import '../../widgets/icon_square_button.dart';
import '../../widgets/leave_sheet.dart';
import '../../widgets/list_widgets.dart';
import '../orders/order_status_pill.dart';

/// `Delivery fees per wilaya` (Figma `661:16208`) — the web's
/// `stock/delivery/fees`.
///
/// The 58 wilayas, each with its home / stop-desk / return price. A row's
/// *Enregistrer* appears once something in it changed, *Réinitialiser* once
/// it holds the merchant's own prices. *Compléter les manquants* writes the
/// defaults for wilayas without a rule; *Tout réinitialiser* replaces every
/// custom price, after asking.
class DeliveryFeesScreen extends StatefulWidget {
  const DeliveryFeesScreen({super.key});

  @override
  State<DeliveryFeesScreen> createState() => _DeliveryFeesScreenState();
}

class _DeliveryFeesScreenState extends State<DeliveryFeesScreen> {
  late final DeliveryFeesViewModel _model = DeliveryFeesViewModel(delivery: context.read<DeliveryRepository>());

  final _search = TextEditingController();
  final _searchFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    _search.addListener(() => _model.setSearch(_search.text));
    WidgetsBinding.instance.addPostFrameCallback((_) => _model.load());
  }

  @override
  void dispose() {
    _search.dispose();
    _searchFocus.dispose();
    _model.dispose();
    super.dispose();
  }

  Future<void> _fillMissing() async {
    final l10n = L10n.of(context);
    final result = await _model.seed(overwrite: false);
    if (!mounted) return;
    if (result.errorOrNull case final error?) {
      AppToast.info(context, apiErrorMessage(error, l10n));
    } else {
      AppToast.success(context, l10n.deliveryFeesFilled(result.valueOrNull ?? 0));
    }
  }

  Future<void> _resetAll() async {
    final l10n = L10n.of(context);
    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: AppColors.surface,
      barrierColor: AppColors.scrim,
      builder: (sheet) => SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(AppSpacing.gutter, AppSpacing.xl, AppSpacing.gutter, AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(l10n.deliveryFeesResetAllTitle, style: AppText.title),
              SizedBox(height: AppSpacing.xs),
              Text(
                l10n.deliveryFeesResetAllBody,
                style: AppText.bodyS.copyWith(color: AppColors.textMuted, height: 1.32),
              ),
              SizedBox(height: AppSpacing.xl),
              FilledButton(onPressed: () => Navigator.of(sheet).pop(true), child: Text(l10n.deliveryFeesResetAll)),
              SizedBox(height: AppSpacing.sm),
              OutlinedButton(onPressed: () => Navigator.of(sheet).pop(false), child: Text(l10n.commonCancel)),
            ],
          ),
        ),
      ),
    );
    if (confirmed != true || !mounted) return;
    final result = await _model.seed(overwrite: true);
    if (!mounted) return;
    if (result.errorOrNull case final error?) {
      AppToast.info(context, apiErrorMessage(error, l10n));
    } else {
      AppToast.success(context, l10n.deliveryFeesResetAllDone);
    }
  }

  Future<void> _save(FeeRowDraft draft) async {
    final l10n = L10n.of(context);
    FocusScope.of(context).unfocus();
    final result = await _model.save(draft);
    if (!mounted) return;
    if (result.errorOrNull case final error?) {
      AppToast.info(context, apiErrorMessage(error, l10n));
    } else {
      AppToast.success(context, l10n.deliveryFeesSaved(_name(draft)));
    }
  }

  Future<void> _resetRow(FeeRowDraft draft) async {
    final l10n = L10n.of(context);
    final result = await _model.resetRow(draft);
    if (!mounted) return;
    if (result.errorOrNull case final error?) {
      AppToast.info(context, apiErrorMessage(error, l10n));
    } else {
      AppToast.success(context, l10n.deliveryFeesResetDone(_name(draft)));
    }
  }

  /// The wilaya's name in the merchant's language — the table carries French
  /// and Arabic.
  String _name(FeeRowDraft draft) {
    final row = draft.saved;
    return Localizations.localeOf(context).languageCode == 'ar' && row.nameAr.isNotEmpty ? row.nameAr : row.name;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);
    final gutter = EdgeInsets.symmetric(horizontal: AppSpacing.gutter);

    return ListenableBuilder(
      listenable: _model,
      builder: (context, _) => BackIntercept(
        active: _model.hasUnsaved,
        onBack: () => showLeaveSheet(context, body: l10n.productEditLeaveBody),
        child: Scaffold(
          backgroundColor: AppColors.ink,
          resizeToAvoidBottomInset: true,
          body: SafeArea(
            child: RefreshIndicator(
              onRefresh: _model.load,
              color: AppColors.textPrimary,
              backgroundColor: AppColors.surface,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.only(top: 0.47.h, bottom: AppSpacing.xl),
                children: [
                  Padding(
                    padding: gutter.copyWith(bottom: AppSpacing.lg),
                    child: Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: AppBackButton(semanticLabel: l10n.commonBack),
                    ),
                  ),
                  Padding(
                    padding: gutter,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(l10n.deliveryFeesEyebrow, style: AppText.labelMeta),
                        SizedBox(height: 1.54.w),
                        Text(l10n.deliveryFeesTitle, style: AppText.displayM),
                        SizedBox(height: 1.54.w),
                        Text(
                          l10n.deliveryFeesSubtitle,
                          style: AppText.bodyS.copyWith(color: AppColors.textSecondary, height: 1.32),
                        ),
                        SizedBox(height: AppSpacing.xl),
                        Wrap(
                          spacing: AppSpacing.sm,
                          runSpacing: AppSpacing.sm,
                          children: [
                            ToolChip(
                              icon: AppIcons.refresh,
                              label: l10n.deliveryFeesFillMissing,
                              active: false,
                              onTap: _model.isSeeding || _model.isFirstLoad ? () {} : _fillMissing,
                            ),
                            _PlainChip(
                              label: l10n.deliveryFeesResetAll,
                              onTap: _model.isSeeding || _model.isFirstLoad ? null : _resetAll,
                            ),
                          ],
                        ),
                        SizedBox(height: AppSpacing.xl),
                        AppTextField(
                          label: l10n.deliverySearchLabel,
                          controller: _search,
                          focusNode: _searchFocus,
                          placeholder: l10n.deliveryFeesSearch,
                          textInputAction: TextInputAction.search,
                          inputFormatters: [LengthLimitingTextInputFormatter(60)],
                          onSubmitted: (_) => _searchFocus.unfocus(),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: AppSpacing.lg),
                  ..._rows(l10n),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _rows(L10n l10n) {
    final gutter = EdgeInsets.symmetric(horizontal: AppSpacing.gutter);

    if (_model.isFirstLoad || _model.isSeeding) {
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

    if (_model.total == 0 && _model.error != null) {
      return [
        Padding(
          padding: gutter,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ApiErrorLine(error: _model.error),
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: OutlinedButton(onPressed: _model.load, child: Text(l10n.commonRetry)),
              ),
            ],
          ),
        ),
      ];
    }

    final rows = _model.rows;
    return [
      SectionLabel(label: l10n.deliveryFeesSection, trailing: '${rows.length}'),
      if (rows.isEmpty)
        Padding(
          padding: gutter,
          child: EmptyBox(icon: AppIcons.search, title: l10n.deliveryNoMatchTitle, body: l10n.productsNoMatchBody),
        )
      else
        Padding(
          padding: gutter,
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              border: Border.all(color: AppColors.rule, width: AppStroke.hairline),
              borderRadius: BorderRadius.circular(AppRadius.card),
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                for (final (index, draft) in rows.indexed) ...[
                  if (index > 0)
                    const Divider(height: AppStroke.hairline, thickness: AppStroke.hairline, color: AppColors.rule),
                  _FeeRowCard(
                    key: ValueKey(draft.saved.wilayaId),
                    draft: draft,
                    onChanged: _model.touched,
                    onSave: () => _save(draft),
                    onReset: () => _resetRow(draft),
                  ),
                ],
              ],
            ),
          ),
        ),
    ];
  }
}

/// One wilaya: its code and names, default or custom, and its three prices.
class _FeeRowCard extends StatefulWidget {
  const _FeeRowCard({
    super.key,
    required this.draft,
    required this.onChanged,
    required this.onSave,
    required this.onReset,
  });

  final FeeRowDraft draft;
  final VoidCallback onChanged;
  final VoidCallback onSave;
  final VoidCallback onReset;

  @override
  State<_FeeRowCard> createState() => _FeeRowCardState();
}

class _FeeRowCardState extends State<_FeeRowCard> {
  final _focus = List.generate(3, (_) => FocusNode());

  // Typing in a price moves the row's buttons (Enregistrer appears).
  late final List<TextEditingController> _fields = [widget.draft.home, widget.draft.stopdesk, widget.draft.returns];

  void _changed() => widget.onChanged();

  @override
  void initState() {
    super.initState();
    for (final c in _fields) {
      c.addListener(_changed);
    }
  }

  @override
  void dispose() {
    for (final c in _fields) {
      c.removeListener(_changed);
    }
    for (final f in _focus) {
      f.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);
    final draft = widget.draft;
    final row = draft.saved;
    final digits = [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(7)];

    Widget price(String label, TextEditingController c, int i) => Expanded(
          child: AppTextField(
            label: label,
            controller: c,
            focusNode: _focus[i],
            placeholder: '0',
            keyboardType: TextInputType.number,
            textInputAction: i < 2 ? TextInputAction.next : TextInputAction.done,
            inputFormatters: digits,
            enabled: !draft.busy,
            onSubmitted: (_) => i < 2 ? _focus[i + 1].requestFocus() : _focus[i].unfocus(),
          ),
        );

    final dirty = draft.isDirty;
    return Padding(
      padding: EdgeInsets.all(3.59.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Text(row.code, style: AppText.labelMeta),
              SizedBox(width: 2.05.w),
              Flexible(child: Text(row.name, style: AppText.title, overflow: TextOverflow.ellipsis)),
              if (row.nameAr.isNotEmpty) ...[
                SizedBox(width: 1.54.w),
                Flexible(
                  child: Text(
                    row.nameAr,
                    style: AppText.bodyS.copyWith(color: AppColors.textMuted),
                    overflow: TextOverflow.ellipsis,
                    textDirection: TextDirection.rtl,
                  ),
                ),
              ],
              SizedBox(width: AppSpacing.sm),
              OrderStatusPill(
                label: row.isCustom ? l10n.deliveryFeesCustom : l10n.deliveryFeesDefault,
                tone: row.isCustom ? PillTone.settled : PillTone.moving,
              ),
            ],
          ),
          SizedBox(height: AppSpacing.md),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              price(l10n.deliveryFeesHome, draft.home, 0),
              SizedBox(width: AppSpacing.sm),
              price(l10n.deliveryFeesStopdesk, draft.stopdesk, 1),
              SizedBox(width: AppSpacing.sm),
              price(l10n.deliveryFeesReturn, draft.returns, 2),
            ],
          ),
          if (draft.busy || dirty || row.isCustom) ...[
            SizedBox(height: AppSpacing.md),
            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: draft.busy
                  ? const SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.textMuted),
                    )
                  : dirty
                      ? FilledButton(
                          onPressed: draft.isValid ? widget.onSave : null,
                          style: FilledButton.styleFrom(minimumSize: Size(0, 9.23.w)),
                          child: Text(l10n.commonSave),
                        )
                      : OutlinedButton(
                          onPressed: widget.onReset,
                          style: OutlinedButton.styleFrom(minimumSize: Size(0, 9.23.w)),
                          child: Text(l10n.deliveryFeesReset),
                        ),
            ),
          ],
        ],
      ),
    );
  }
}

/// A header chip without an icon — the frame's *Tout réinitialiser*.
class _PlainChip extends StatelessWidget {
  const _PlainChip({required this.label, required this.onTap});

  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      enabled: onTap != null,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.rule, width: AppStroke.hairline),
            borderRadius: BorderRadius.circular(AppRadius.card),
          ),
          child: Text(
            label,
            style: AppText.bodyS.copyWith(color: onTap == null ? AppColors.textMuted : AppColors.textSecondary),
          ),
        ),
      ),
    );
  }
}
