import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:provider/provider.dart';

import '../../../app/routes.dart';
import '../../../core/error/app_exception.dart';
import '../../../core/extensions/responsive_extension.dart';
import '../../../core/utils/money.dart';
import '../../../data/models/dashboard_stats.dart';
import '../../../data/models/stock_mode.dart';
import '../../../data/models/stock_overview.dart';
import '../../../data/repositories/dashboard_repository.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../../viewmodels/stock_mode_view_model.dart';
import '../../viewmodels/stock_overview_view_model.dart';
import '../../widgets/api_error_message.dart';
import '../../widgets/app_filter_chip.dart';
import '../../widgets/app_icon.dart';
import '../../widgets/home_widgets.dart';
import '../../widgets/icon_square_button.dart';

/// `16 — Aperçu du stock` — the Stock tab, the web's `/dashboard/stock`.
///
/// Same order as the web page: title, the Simple / Avancé switch and its hint,
/// the seven figures, the two monthly blocks (Advanced only), then the recent
/// movements. The mode is the app-wide [StockModeViewModel] — the web's
/// `localStorage.stockMode` — the same one the tutorial's `T2` sets. (The web
/// also filters its sidebar by it; the app's menu has no mode-dependent rows
/// yet.)
///
/// **The movements table became rows.** Five columns do not fit 390dp: the
/// product is the title, the date and the reason the meta line, and the signed
/// quantity with its direction sits on the right. An exit is muted, as the
/// web greys `out`.
///
/// The web's ↻ button is the pull-to-refresh here.
class StockOverviewScreen extends StatefulWidget {
  const StockOverviewScreen({super.key});

  @override
  State<StockOverviewScreen> createState() => _StockOverviewScreenState();
}

class _StockOverviewScreenState extends State<StockOverviewScreen> {
  late final StockOverviewViewModel _model = StockOverviewViewModel(
    dashboard: context.read<DashboardRepository>(),
  );

  /// Only used when no [StockModeViewModel] is provided — a bare test host.
  StockMode _fallbackMode = StockMode.simple;

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

  /// The frame's *Ajouter un produit*. Pushed, as from `17`, so back returns
  /// here; a created product makes every figure and the movements stale.
  Future<void> _addProduct() async {
    final created = await GoRouter.of(context).push<bool>(Routes.productNew);
    if (created != true || !mounted) return;
    await _model.load();
  }

  void _setMode(StockModeViewModel? modes, StockMode mode) {
    if (modes != null) {
      modes.setMode(mode);
    } else {
      setState(() => _fallbackMode = mode);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);
    final modes = context.watch<StockModeViewModel?>();
    final mode = modes?.mode ?? _fallbackMode;

    return ListenableBuilder(
      listenable: _model,
      builder: (context, _) => Scaffold(
        backgroundColor: AppColors.ink,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(
                  AppSpacing.gutter,
                  0.47.h, // 4
                  AppSpacing.gutter,
                  AppSpacing.lg, // 16
                ),
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
                    padding: EdgeInsets.only(bottom: AppSpacing.xxl),
                    children: [
                      _Header(mode: mode, onMode: (value) => _setMode(modes, value)),
                      ..._content(context, l10n, mode),
                    ],
                  ),
                ),
              ),
              // Pinned, as on `17`: the list above scrolls, the action does not.
              Padding(
                padding: EdgeInsets.fromLTRB(
                  AppSpacing.gutter,
                  AppSpacing.md, // 12
                  AppSpacing.gutter,
                  3.32.h, // 28
                ),
                child: FilledButton(
                  onPressed: _addProduct,
                  child: Text(l10n.productsAdd),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _content(BuildContext context, L10n l10n, StockMode mode) {
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

    final overview = _model.overview;
    if (overview == null) {
      return [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.gutter),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ApiErrorLine(error: _model.error),
              OutlinedButton(onPressed: _model.load, child: Text(l10n.commonRetry)),
            ],
          ),
        ),
      ];
    }

    final tag = Localizations.localeOf(context).toLanguageTag();
    final sales = _model.sales;
    final purchases = _model.purchases;

    return [
      _Figures(stats: overview.stats, tag: tag),
      SizedBox(height: AppSpacing.xxl),
      if (mode == StockMode.advanced) ...[
        _MonthBlock(
          label: l10n.stockSalesMonth,
          error: _model.salesError,
          tiles: sales == null ? null : _salesTiles(l10n, sales, tag),
        ),
        SizedBox(height: AppSpacing.xxl),
        _MonthBlock(
          label: l10n.stockPurchasesMonth,
          error: _model.purchasesError,
          tiles: purchases == null ? null : _purchaseTiles(l10n, purchases, tag),
        ),
        SizedBox(height: AppSpacing.xxl),
      ],
      SectionLabel(label: l10n.stockRecentMovements),
      Padding(
        padding: EdgeInsets.symmetric(horizontal: AppSpacing.gutterTight),
        child: _Movements(rows: overview.movements, tag: tag),
      ),
    ];
  }

  List<Widget> _salesTiles(L10n l10n, SalesStats sales, String tag) {
    final revenue = Money.short(sales.totalRevenue, tag);
    return [
      KpiTile(
        label: l10n.stockTotalSales,
        value: Money.grouped(sales.totalSales, tag),
        icon: AppIcons.shoppingCart,
        iconColor: AppColors.accentOrders,
      ),
      KpiTile(
        label: l10n.stockRevenue,
        value: revenue.value,
        unit: revenue.unit,
        icon: AppIcons.dollar,
        iconColor: AppColors.accentMoney,
      ),
      KpiTile(
        label: l10n.stockPaid,
        value: Money.grouped(sales.paidSales, tag),
        icon: AppIcons.dollar,
        iconColor: AppColors.accentMoney,
      ),
      KpiTile(
        label: l10n.stockPending,
        value: Money.grouped(sales.pendingSales, tag),
        icon: AppIcons.alert,
        iconColor: AppColors.accentAlert,
      ),
    ];
  }

  List<Widget> _purchaseTiles(L10n l10n, PurchaseStats purchases, String tag) {
    final spent = Money.short(purchases.totalSpent, tag);
    return [
      KpiTile(
        label: l10n.stockTotalPurchases,
        value: Money.grouped(purchases.totalPurchases, tag),
        icon: AppIcons.truck,
        iconColor: AppColors.accentOrders,
      ),
      KpiTile(
        label: l10n.stockTotalSpent,
        value: spent.value,
        unit: spent.unit,
        icon: AppIcons.dollar,
        iconColor: AppColors.accentMoney,
      ),
      KpiTile(
        label: l10n.stockPending,
        value: Money.grouped(purchases.pendingPurchases, tag),
        icon: AppIcons.alert,
        iconColor: AppColors.accentAlert,
      ),
      KpiTile(
        label: l10n.stockReceived,
        value: Money.grouped(purchases.receivedPurchases, tag),
        icon: AppIcons.box,
        iconColor: AppColors.accentStarred,
      ),
    ];
  }
}

/// Title, subtitle, the mode switch and what the mode shows.
class _Header extends StatelessWidget {
  const _Header({required this.mode, required this.onMode});

  final StockMode mode;
  final ValueChanged<StockMode> onMode;

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);
    final simple = mode == StockMode.simple;

    return Padding(
      padding: EdgeInsets.fromLTRB(AppSpacing.gutter, 0, AppSpacing.gutter, AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.stockOverviewTitle, style: AppText.displayM),
          SizedBox(height: AppSpacing.sm),
          Text(l10n.stockOverviewSubtitle, style: AppText.bodyS.copyWith(height: 1.32)),
          SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              AppFilterChip(
                label: l10n.stockModeSimple,
                selected: simple,
                onTap: () => onMode(StockMode.simple),
              ),
              SizedBox(width: AppSpacing.sm),
              AppFilterChip(
                label: l10n.stockModeAdvanced,
                selected: !simple,
                onTap: () => onMode(StockMode.advanced),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.md),
          Text(
            simple ? l10n.stockOverviewHintSimple : l10n.stockOverviewHintAdvanced,
            style: AppText.bodyS.copyWith(height: 1.4, color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }
}

/// The web's two stat grids: four figures, then categories, suppliers and the
/// units on hand. Colour marks the module, as the frame draws it.
class _Figures extends StatelessWidget {
  const _Figures({required this.stats, required this.tag});

  final DashboardStats stats;
  final String tag;

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);
    final stockValue = Money.short(stats.totalStockValue, tag);
    final retailValue = Money.short(stats.totalRetailValue, tag);
    String count(int value) => Money.grouped(value, tag);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.gutterTight),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _Pair(
            KpiTile(
              label: l10n.stockTotalProducts,
              value: count(stats.totalProducts),
              icon: AppIcons.box,
              iconColor: AppColors.accentStarred,
            ),
            KpiTile(
              label: l10n.stockLowStock,
              value: count(stats.lowStockProducts),
              icon: AppIcons.alert,
              iconColor: AppColors.accentAlert,
            ),
          ),
          SizedBox(height: AppSpacing.sm),
          _Pair(
            KpiTile(
              label: l10n.stockValue,
              value: stockValue.value,
              unit: stockValue.unit,
              icon: AppIcons.dollar,
              iconColor: AppColors.accentMoney,
            ),
            KpiTile(
              label: l10n.stockRetailValue,
              value: retailValue.value,
              unit: retailValue.unit,
              icon: AppIcons.dollar,
              iconColor: AppColors.accentMoney,
            ),
          ),
          SizedBox(height: AppSpacing.sm),
          _Pair(
            KpiTile(
              label: l10n.stockCategories,
              value: count(stats.totalCategories),
              icon: AppIcons.tag,
              iconColor: AppColors.accentStarred,
            ),
            KpiTile(
              label: l10n.stockSuppliers,
              value: count(stats.totalSuppliers),
              icon: AppIcons.users,
              iconColor: AppColors.accentClients,
            ),
          ),
          SizedBox(height: AppSpacing.sm),
          KpiTile(
            label: l10n.stockTotalItems,
            value: count(stats.totalItems),
            icon: AppIcons.box,
            iconColor: AppColors.accentStarred,
          ),
        ],
      ),
    );
  }
}

/// A monthly block: its label, then two rows of two — or why it could not load.
class _MonthBlock extends StatelessWidget {
  const _MonthBlock({required this.label, required this.tiles, this.error});

  final String label;

  /// Four tiles; null when the figures have not loaded.
  final List<Widget>? tiles;
  final AppException? error;

  @override
  Widget build(BuildContext context) {
    final rows = tiles;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionLabel(label: label),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.gutterTight),
          child: rows == null
              ? ApiErrorLine(error: error)
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _Pair(rows[0], rows[1]),
                    SizedBox(height: AppSpacing.sm),
                    _Pair(rows[2], rows[3]),
                  ],
                ),
        ),
      ],
    );
  }
}

class _Movements extends StatelessWidget {
  const _Movements({required this.rows, required this.tag});

  final List<StockMovement> rows;
  final String tag;

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);

    if (rows.isEmpty) {
      return ListBox(
        children: [
          Padding(
            padding: EdgeInsets.all(AppSpacing.xl),
            child: Text(
              l10n.stockMovementsEmpty,
              textAlign: TextAlign.center,
              style: AppText.bodyS.copyWith(height: 1.4, color: AppColors.textMuted),
            ),
          ),
        ],
      );
    }

    return ListBox(
      children: [
        // The endpoint already caps at 10; the web slices again, and so do we.
        for (final row in rows.take(10)) _row(l10n, row),
      ],
    );
  }

  Widget _row(L10n l10n, StockMovement movement) {
    final signed = movement.signedQuantity;
    final faded = signed < 0 ? AppColors.textMuted : null;
    final date = movement.createdAt;
    final reason = movement.reason?.trim();
    final meta = [
      // "12 sept." → "12 SEPT": the row uppercases it, and the dot is noise.
      if (date != null) DateFormat('d MMM', tag).format(date.toLocal()).replaceAll('.', ''),
      if (reason != null && reason.isNotEmpty) reason,
    ].join('  ·  ');

    return AppListRow(
      title: movement.productName ?? '–',
      meta: meta,
      value: signed > 0 ? '+$signed' : (signed < 0 ? '−${signed.abs()}' : '0'),
      valueColor: faded,
      unit: switch (movement.type) {
        StockMovementType.stockIn => l10n.stockMoveIn,
        StockMovementType.stockOut => l10n.stockMoveOut,
        StockMovementType.adjustment => l10n.stockMoveAdjustment,
        StockMovementType.returned => l10n.stockMoveReturn,
        StockMovementType.unknown => null,
      },
      unitColor: faded,
    );
  }
}

/// Two tiles side by side, kept level when one label wraps (see home's `_Kpis`).
class _Pair extends StatelessWidget {
  const _Pair(this.first, this.second);

  final Widget first;
  final Widget second;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(child: first),
          SizedBox(width: AppSpacing.sm),
          Expanded(child: second),
        ],
      ),
    );
  }
}
