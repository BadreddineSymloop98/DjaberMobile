import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../app/routes.dart';
import '../../../core/extensions/responsive_extension.dart';
import '../../../data/repositories/product_repository.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../viewmodels/form_field_model.dart';
import '../../viewmodels/tutorial_product_view_model.dart';
import '../../widgets/app_text_field.dart';
import 'tutorial_messages.dart';
import 'tutorial_step_scaffold.dart';

/// `T3 — Produit`. Step 2 of 4.
///
/// The six fields the frame carries: the five `POST /api/user-stock/products`
/// requires on creation, plus **Description**, which is optional on the server
/// but is what the agent reads to sell the product — the web's own placeholder
/// says so. Category and unit are optional selects on the web, which is what
/// makes this shortened form produce a complete product rather than a stub.
///
/// **The copy is the frame's, not the web's.** The web's product form labels
/// are hardcoded English in `stock/products/page.tsx` — `"SKU *"`,
/// `"Cost Price (DA) *"` — with no `i18n.ts` keys behind them, so there is
/// nothing to source. The French here is the design's own and needs approval,
/// as does its English and Arabic (§21.6).
class TutorialProductScreen extends StatefulWidget {
  const TutorialProductScreen({super.key});

  @override
  State<TutorialProductScreen> createState() => _TutorialProductScreenState();
}

class _TutorialProductScreenState extends State<TutorialProductScreen> {
  late final TutorialProductViewModel _model = TutorialProductViewModel(
    products: context.read<ProductRepository>(),
  );

  @override
  void initState() {
    super.initState();
    // The selling price's validity depends on the cost price, so the form has
    // to re-evaluate when the cost changes, not only when selling does.
    _model.costPrice.controller.addListener(_model.onCostPriceChanged);
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  Future<void> _create() async {
    final product = await _model.submitAndCreate();
    // The router is looked up only on the success path, not before the
    // attempt. Capturing it up front would make a screen that merely *fails
    // validation* depend on a GoRouter being in the tree — which is exactly
    // what made the sign-out button untestable in isolation.
    if (product == null || !mounted) return;
    GoRouter.of(context).go(Routes.tutorialAgent);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);

    return ChangeNotifierProvider<TutorialProductViewModel>.value(
      value: _model,
      child: Consumer<TutorialProductViewModel>(
        builder: (context, model, _) {
          String? errorFor(FormFieldModel field) {
            final error = model.visibleError(field);
            return error == null ? null : tutorialFieldMessage(error, l10n);
          }

          return TutorialStepScaffold(
            step: 2,
            title: l10n.tutorialProductTitle,
            subtitle: l10n.tutorialProductSubtitle,
            footer: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TutorialErrorLine(error: model.submitError),
                FilledButton(
                  // Disabled while in flight. This matters more than a
                  // spinner: a double tap would otherwise send two products,
                  // and the second fails on the unique SKU for a product the
                  // merchant just successfully created.
                  onPressed: model.isBusy ? null : _create,
                  child: model.isBusy
                      ? SizedBox.square(
                          dimension: AppSpacing.gutterTight,
                          child: const CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.ink,
                          ),
                        )
                      : Text(l10n.tutorialProductSubmit),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AppTextField(
                  label: l10n.productName,
                  isRequired: true,
                  controller: model.name.controller,
                  focusNode: model.name.focusNode,
                  errorText: errorFor(model.name),
                  placeholder: l10n.productNamePlaceholder,
                  textCapitalization: TextCapitalization.sentences,
                  textInputAction: TextInputAction.next,
                  // The column is varchar(255); capped at the keyboard so what
                  // the merchant sees is what gets sent.
                  inputFormatters: [LengthLimitingTextInputFormatter(255)],
                ),
                _gap,
                AppTextField(
                  label: l10n.productSku,
                  isRequired: true,
                  controller: model.sku.controller,
                  focusNode: model.sku.focusNode,
                  errorText: errorFor(model.sku),
                  placeholder: l10n.productSkuPlaceholder,
                  textCapitalization: TextCapitalization.characters,
                  textInputAction: TextInputAction.next,
                  inputFormatters: [LengthLimitingTextInputFormatter(255)],
                ),
                _gap,
                AppTextField(
                  label: l10n.productDescription,
                  controller: model.description.controller,
                  focusNode: model.description.focusNode,
                  errorText: errorFor(model.description),
                  placeholder: l10n.productDescriptionPlaceholder,
                  textCapitalization: TextCapitalization.sentences,
                  textInputAction: TextInputAction.next,
                  inputFormatters: [LengthLimitingTextInputFormatter(5000)],
                ),
                _gap,
                AppTextField(
                  label: l10n.productCostPrice,
                  isRequired: true,
                  controller: model.costPrice.controller,
                  focusNode: model.costPrice.focusNode,
                  errorText: errorFor(model.costPrice),
                  placeholder: '0',
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  textInputAction: TextInputAction.next,
                  inputFormatters: [_amountFormatter],
                ),
                _gap,
                AppTextField(
                  label: l10n.productSellingPrice,
                  isRequired: true,
                  controller: model.sellingPrice.controller,
                  focusNode: model.sellingPrice.focusNode,
                  errorText: errorFor(model.sellingPrice),
                  placeholder: '0',
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  textInputAction: TextInputAction.next,
                  inputFormatters: [_amountFormatter],
                ),
                _gap,
                AppTextField(
                  label: l10n.productQuantity,
                  isRequired: true,
                  controller: model.quantity.controller,
                  focusNode: model.quantity.focusNode,
                  errorText: errorFor(model.quantity),
                  placeholder: '0',
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.done,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(9),
                  ],
                  onSubmitted: (_) => _create(),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  /// 14 between fields, from the frame — tighter than the 16 the auth screens
  /// use, because this form is six fields deep rather than four.
  Widget get _gap => SizedBox(height: 3.59.w); // 14
}

/// Digits, one decimal separator, and nothing else.
///
/// A comma is allowed through and normalised on parse: it is the French
/// decimal separator and what an Algerian handset's keyboard offers, and
/// rejecting it at the keyboard would make the field feel broken.
final _amountFormatter = FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]'));

