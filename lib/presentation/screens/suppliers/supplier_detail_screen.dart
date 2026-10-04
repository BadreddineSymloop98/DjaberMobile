import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:provider/provider.dart';

import '../../../core/extensions/responsive_extension.dart';
import '../../../core/utils/money.dart';
import '../../../core/utils/phone.dart';
import '../../../data/models/supplier.dart';
import '../../../data/repositories/supplier_repository.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../../viewmodels/suppliers_view_model.dart';
import '../../widgets/api_error_message.dart';
import '../../widgets/app_icon.dart';
import '../../widgets/app_toast.dart';
import '../../widgets/back_scope.dart';
import '../../widgets/home_widgets.dart';
import '../../widgets/icon_square_button.dart';
import '../../widgets/list_widgets.dart';
import 'supplier_form_sheet.dart';
import 'suppliers_screen.dart' show SupplierStatusBadge;

/// `Supplier details` (Figma `644:10736`) — the web's *Supplier Details* modal
/// as a screen: name and status, phone / e-mail / address, notes, purchases,
/// total spent and *Membre depuis*, then *Voir les achats* and *Modifier le
/// fournisseur*.
///
/// Returns `true` to the list when the supplier was edited.
class SupplierDetailScreen extends StatefulWidget {
  const SupplierDetailScreen({super.key, required this.supplierId, this.initial});

  final String supplierId;

  /// The list's row, when the list opened this screen.
  final Supplier? initial;

  @override
  State<SupplierDetailScreen> createState() => _SupplierDetailScreenState();
}

class _SupplierDetailScreenState extends State<SupplierDetailScreen> {
  late final SupplierDetailViewModel _model = SupplierDetailViewModel(
    suppliers: context.read<SupplierRepository>(),
    supplierId: widget.supplierId,
    initial: widget.initial,
  );

  bool _edited = false;

  @override
  void initState() {
    super.initState();
    // Without a row to show, read one now; with one, stay on it and let a pull
    // to refresh re-read.
    if (widget.initial == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _model.load());
    }
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  Future<void> _edit(Supplier supplier) async {
    final l10n = L10n.of(context);
    final saved = await showSupplierFormSheet(
      context,
      suppliers: context.read<SupplierRepository>(),
      // No list here to check names against; a clash is still refused by the
      // server (as a 500 on update).
      knownNames: const {},
      editing: supplier,
    );
    if (saved == null || !mounted) return;
    setState(() => _edited = true);
    AppToast.success(context, l10n.supplierUpdated);
    // The update response has no purchase count or spend — re-read the list row.
    await _model.load();
  }

  void _viewPurchases() => AppToast.info(context, L10n.of(context).supplierPurchasesSoon);

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
    final supplier = _model.supplier;

    if (supplier == null) {
      if (_model.error == null && !_model.notFound) {
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
      return [
        if (_model.notFound)
          Text(l10n.supplierNotFound, style: AppText.bodyS.copyWith(color: AppColors.textMuted))
        else
          ApiErrorLine(error: _model.error),
        SizedBox(height: AppSpacing.md),
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: OutlinedButton(onPressed: _model.load, child: Text(l10n.commonRetry)),
        ),
      ];
    }

    final tag = Localizations.localeOf(context).toLanguageTag();
    final notes = supplier.notes?.trim();

    Widget section(String label) => Padding(
          padding: EdgeInsets.fromLTRB(AppSpacing.xs, AppSpacing.xl, AppSpacing.xs, AppSpacing.md),
          child: Text(label.toUpperCase(), style: AppText.labelSection),
        );

    return [
      if (_model.refreshError != null) ApiErrorLine(error: _model.refreshError),
      Padding(
        padding: EdgeInsets.symmetric(horizontal: AppSpacing.xs),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.supplierDetailEyebrow, style: AppText.labelMeta),
            SizedBox(height: AppSpacing.md),
            Text(supplier.name, style: AppText.displayM),
            SizedBox(height: AppSpacing.xs),
            SupplierStatusBadge(active: supplier.isActive, boxed: false),
          ],
        ),
      ),
      SizedBox(height: AppSpacing.xl),
      ListBox(
        children: [
          _Fact(
            label: l10n.clientPhone,
            value: (supplier.phone ?? '').isEmpty ? '—' : Phone.format(supplier.phone!),
          ),
          _Fact(label: l10n.authEmail, value: supplier.email ?? '—'),
          _Fact(label: l10n.clientAddress, value: supplier.address ?? '—'),
        ],
      ),
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
      SizedBox(height: AppSpacing.xl),
      KpiPair(
        KpiTile(
          label: l10n.supplierDetailPurchases,
          value: Money.grouped(supplier.purchaseCount, tag),
          icon: AppIcons.truck,
          iconColor: AppColors.accentMoney,
        ),
        KpiTile(
          label: l10n.clientsStatTotalSpent,
          value: Money.grouped(supplier.totalSpent.round(), tag),
          unit: 'DA',
          icon: AppIcons.dollar,
          iconColor: AppColors.accentMoney,
        ),
      ),
      SizedBox(height: AppSpacing.sm),
      KpiTile(
        label: l10n.supplierDetailMemberSince,
        value: supplier.createdAt == null ? '—' : DateFormat.yMd(tag).format(supplier.createdAt!.toLocal()),
        icon: AppIcons.clock,
        iconColor: AppColors.accentMoney,
      ),
      SizedBox(height: AppSpacing.xxl),
      FilledButton(onPressed: _viewPurchases, child: Text(l10n.supplierViewPurchases)),
      SizedBox(height: AppSpacing.sm),
      OutlinedButton(onPressed: () => _edit(supplier), child: Text(l10n.supplierEditTitle)),
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
          Expanded(child: Text(value, textAlign: TextAlign.end, style: AppText.title)),
        ],
      ),
    );
  }
}
