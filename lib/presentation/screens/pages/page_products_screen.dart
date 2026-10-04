import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../app/routes.dart';
import '../../../core/extensions/responsive_extension.dart';
import '../../../core/utils/money.dart';
import '../../../data/models/connected_page.dart';
import '../../../data/models/product.dart';
import '../../../data/repositories/agent_repository.dart';
import '../../../data/repositories/product_repository.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../../viewmodels/page_products_view_model.dart';
import '../../widgets/api_error_message.dart';
import '../../widgets/app_icon.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/app_toast.dart';
import '../../widgets/back_scope.dart';
import '../../widgets/icon_square_button.dart';
import '../../widgets/leave_sheet.dart';
import '../../widgets/list_widgets.dart';
import '../orders/order_status_pill.dart';
import '../sales/sale_widgets.dart';

/// `Page products` (Figma `687:19957`, `· sélection` `687:20151`, `· aucun
/// agent` `687:20301`) — the web's `page/[pageId]/stock`.
///
/// *Vendre tous les produits*, or a chosen few from the catalogue, for the
/// agent that answers on this page. Leaving with an unsaved choice asks first.
class PageProductsScreen extends StatefulWidget {
  const PageProductsScreen({super.key, required this.pageId, this.page});

  final String pageId;

  /// For the title; a deep link draws with a blank name until it is known.
  final ConnectedPage? page;

  @override
  State<PageProductsScreen> createState() => _PageProductsScreenState();
}

class _PageProductsScreenState extends State<PageProductsScreen> {
  late final PageProductsViewModel _model = PageProductsViewModel(
    agents: context.read<AgentRepository>(),
    products: context.read<ProductRepository>(),
    pageId: widget.pageId,
  );

  final _search = TextEditingController();
  final _searchFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    _search.addListener(() => _model.setQuery(_search.text));
    WidgetsBinding.instance.addPostFrameCallback((_) => _model.load());
  }

  @override
  void dispose() {
    _search.dispose();
    _searchFocus.dispose();
    _model.dispose();
    super.dispose();
  }

  Future<bool> _onBack() async {
    if (_model.isBusy) return false;
    if (!_model.isDirty) return true;
    return showLeaveSheet(context, body: L10n.of(context).pageProductsLeave);
  }

  Future<void> _save() async {
    FocusScope.of(context).unfocus();
    final l10n = L10n.of(context);
    final ok = await _model.save();
    if (!mounted) return;
    if (!ok) {
      if (_model.saveError case final error?) AppToast.info(context, apiErrorMessage(error, l10n));
      return;
    }
    AppToast.success(context, l10n.pageProductsSaved);
  }

  /// Out to the catalogue or the agent, then read again on the way back.
  Future<void> _push(String route) async {
    await GoRouter.of(context).push(route);
    if (mounted && !_model.isDirty) await _model.load();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);

    return ListenableBuilder(
      listenable: _model,
      builder: (context, _) => BackIntercept(
        active: _model.isDirty || _model.isBusy,
        onBack: _onBack,
        child: Scaffold(
          backgroundColor: AppColors.ink,
          resizeToAvoidBottomInset: true,
          body: SafeArea(
            child: ListView(
              padding: EdgeInsets.fromLTRB(
                AppSpacing.gutterTight,
                0.47.h,
                AppSpacing.gutterTight,
                AppSpacing.xxl,
              ),
              children: _content(l10n),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _content(L10n l10n) {
    final tag = Localizations.localeOf(context).toLanguageTag();
    final name = widget.page?.pageName ?? '';
    final agent = _model.agent;

    final header = <Widget>[
      Padding(
        padding: EdgeInsets.only(bottom: AppSpacing.lg),
        child: Align(
          alignment: AlignmentDirectional.centerStart,
          child: AppBackButton(semanticLabel: l10n.commonBack),
        ),
      ),
      Text(l10n.pageProductsCrumb(name.toUpperCase()), style: AppText.labelMeta),
      SizedBox(height: 1.54.w),
      Text(l10n.pageProductsTitle(name), style: AppText.displayM),
      SizedBox(height: 1.54.w),
      Text(
        l10n.pageProductsSubtitle,
        style: AppText.bodyS.copyWith(color: AppColors.textSecondary, height: 1.32),
      ),
      SizedBox(height: AppSpacing.lg),
      Wrap(
        spacing: AppSpacing.sm,
        children: [
          ToolChip(
            icon: AppIcons.box,
            label: l10n.pageProductsManage,
            active: false,
            onTap: () => _push(Routes.products),
          ),
          ToolChip(
            icon: AppIcons.refresh,
            label: l10n.pageRefresh,
            active: false,
            onTap: _model.isBusy ? () {} : _model.load,
          ),
        ],
      ),
      SizedBox(height: AppSpacing.xl),
    ];

    final links = <Widget>[
      SizedBox(height: AppSpacing.xl),
      _NavRow(
        icon: AppIcons.box,
        title: l10n.pageProductsManageAll,
        body: l10n.pageProductsManageAllBody,
        onTap: () => _push(Routes.products),
      ),
      SizedBox(height: AppSpacing.sm),
      _NavRow(
        icon: AppIcons.bot,
        title: l10n.pageProductsConfigureAgent,
        body: l10n.pageProductsConfigureAgentBody,
        onTap: () => _push(agent == null ? Routes.agents : Routes.agentOf(agent.id)),
      ),
    ];

    if (_model.isFirstLoad) {
      return [
        ...header,
        Padding(
          padding: EdgeInsets.symmetric(vertical: AppSpacing.huge),
          child: const SaleSpinner(),
        ),
      ];
    }

    if (agent == null && _model.error != null) {
      return [
        ...header,
        ApiErrorLine(error: _model.error),
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: OutlinedButton(onPressed: _model.load, child: Text(l10n.commonRetry)),
        ),
      ];
    }

    if (agent == null) {
      return [
        ...header,
        SaleCard(
          child: Row(
            children: [
              AppIcon(AppIcons.bot, size: 4.62.w, color: AppColors.textSecondary),
              SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.pageProductsNoAgentTitle, style: AppText.title),
                    SizedBox(height: AppSpacing.xs),
                    Text(
                      l10n.pageProductsNoAgentBody,
                      style: AppText.bodyS.copyWith(color: AppColors.textMuted),
                    ),
                  ],
                ),
              ),
              SizedBox(width: AppSpacing.sm),
              FilledButton(onPressed: () => _push(Routes.agents), child: Text(l10n.menuAgents)),
            ],
          ),
        ),
        ...links,
      ];
    }

    final total = _model.catalogueTotal;
    final visible = _model.visible;

    return [
      ...header,
      GestureDetector(
        onTap: () => _model.setSellAll(!_model.sellAll),
        behavior: HitTestBehavior.opaque,
        child: SaleCard(
          child: Row(
            children: [
              AppIcon(AppIcons.box, size: 4.62.w, color: AppColors.textSecondary),
              SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.pageProductsSellAll, style: AppText.title),
                    SizedBox(height: AppSpacing.xs),
                    Text(
                      _model.sellAll
                          ? l10n.pageProductsSellAllBody(total)
                          : l10n.pageProductsSelectedOf(_model.selectedCount, total),
                      style: AppText.bodyS.copyWith(color: AppColors.textMuted),
                    ),
                  ],
                ),
              ),
              OrderTick(
                checked: _model.sellAll,
                onTap: () => _model.setSellAll(!_model.sellAll),
                label: l10n.pageProductsSellAll,
              ),
            ],
          ),
        ),
      ),
      if (!_model.sellAll) ...[
        SizedBox(height: AppSpacing.lg),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: AppTextField(
                label: l10n.productsSearchLabel,
                controller: _search,
                focusNode: _searchFocus,
                placeholder: l10n.recoSearch,
                textInputAction: TextInputAction.search,
                inputFormatters: [LengthLimitingTextInputFormatter(100)],
                onSubmitted: (_) => _searchFocus.unfocus(),
              ),
            ),
            SizedBox(width: AppSpacing.sm),
            Padding(
              padding: EdgeInsets.only(bottom: AppSpacing.xs),
              child: ToolChip(
                icon: AppIcons.check,
                label: _model.allVisibleSelected
                    ? l10n.pageProductsDeselectAll
                    : l10n.pageProductsSelectAll,
                active: false,
                onTap: _model.toggleAllVisible,
              ),
            ),
          ],
        ),
        SizedBox(height: AppSpacing.md),
        if (visible.isEmpty)
          EmptyBox(icon: AppIcons.box, title: l10n.newOrderNoProducts, body: l10n.recoNoMatchBody)
        else
          Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              border: Border.all(color: AppColors.rule, width: AppStroke.hairline),
              borderRadius: BorderRadius.circular(AppRadius.card),
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                for (final (index, product) in visible.indexed) ...[
                  if (index > 0)
                    const Divider(
                      height: AppStroke.hairline,
                      thickness: AppStroke.hairline,
                      color: AppColors.rule,
                    ),
                  _ProductRow(
                    product: product,
                    localeTag: tag,
                    selected: _model.isSelected(product),
                    onTap: () => _model.toggle(product),
                  ),
                ],
              ],
            ),
          ),
      ],
      SizedBox(height: AppSpacing.lg),
      SaleCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              _model.sellAll
                  ? l10n.pageProductsAllAvailable(total)
                  : l10n.pageProductsSelectedCount(_model.selectedCount),
              style: AppText.bodyS,
            ),
            if (_model.selectionEmpty) ...[
              SizedBox(height: AppSpacing.xs),
              Text(
                l10n.pageProductsNoneSelected,
                style: AppText.bodyS.copyWith(color: AppColors.accentAlert),
              ),
            ],
            // Decided 2026-10-04: the selection is the agent's, so other pages
            // it answers on change too — said before saving.
            if (_model.otherPages > 0) ...[
              SizedBox(height: AppSpacing.xs),
              Text(l10n.pageProductsShared(_model.otherPages), style: AppText.labelMeta),
            ],
            SizedBox(height: AppSpacing.md),
            FilledButton(
              onPressed: _model.canSave ? _save : null,
              child: _model.isBusy
                  ? SizedBox.square(
                      dimension: AppSpacing.gutterTight,
                      child: const CircularProgressIndicator(strokeWidth: 2, color: AppColors.ink),
                    )
                  : Text(l10n.pageProductsSave),
            ),
          ],
        ),
      ),
      ...links,
    ];
  }
}

class _ProductRow extends StatelessWidget {
  const _ProductRow({
    required this.product,
    required this.localeTag,
    required this.selected,
    required this.onTap,
  });

  final Product product;
  final String localeTag;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);
    final p = product;
    final image = p.imageUrls.isEmpty ? null : p.imageUrls.first;

    return Semantics(
      checked: selected,
      button: true,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Padding(
          padding: EdgeInsets.all(3.08.w),
          child: Row(
            children: [
              Container(
                width: 11.28.w,
                height: 11.28.w,
                decoration: BoxDecoration(
                  color: AppColors.surfaceRaised,
                  borderRadius: BorderRadius.circular(AppRadius.card),
                ),
                clipBehavior: Clip.antiAlias,
                child: image == null
                    ? Center(
                        child: AppIcon(AppIcons.box, size: 4.1.w, color: AppColors.textMuted),
                      )
                    : Image.network(
                        image,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => Center(
                          child: AppIcon(AppIcons.box, size: 4.1.w, color: AppColors.textMuted),
                        ),
                      ),
              ),
              SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      p.name,
                      style: AppText.bodyS.copyWith(color: AppColors.textPrimary),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 0.51.w),
                    Text(Money.exact(p.sellingPrice, localeTag), style: AppText.labelMeta),
                    SizedBox(height: 0.77.w),
                    OrderStatusPill(
                      label: l10n.newOrderInStock(p.quantity),
                      tone: p.quantity > 0 ? PillTone.settled : PillTone.moving,
                    ),
                  ],
                ),
              ),
              OrderTick(checked: selected, onTap: onTap, label: p.name),
            ],
          ),
        ),
      ),
    );
  }
}

/// The two rows at the bottom of the frame: the catalogue, the agent.
class _NavRow extends StatelessWidget {
  const _NavRow({required this.icon, required this.title, required this.body, required this.onTap});

  final List<String> icon;
  final String title;
  final String body;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final rtl = Directionality.of(context) == TextDirection.rtl;
    return Semantics(
      button: true,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: SaleCard(
          child: Row(
            children: [
              AppIcon(icon, size: 4.62.w, color: AppColors.textSecondary),
              SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: AppText.bodyS.copyWith(color: AppColors.textPrimary)),
                    SizedBox(height: 0.51.w),
                    Text(body, style: AppText.bodyS.copyWith(color: AppColors.textMuted)),
                  ],
                ),
              ),
              Transform.flip(
                flipX: rtl,
                child: AppIcon(AppIcons.chevronRight, size: 4.1.w, color: AppColors.textMuted),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
