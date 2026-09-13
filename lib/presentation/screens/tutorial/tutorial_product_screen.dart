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
import '../../viewmodels/session_view_model.dart';
import '../../viewmodels/tutorial_product_view_model.dart';
import '../../viewmodels/tutorial_view_model.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/app_toast.dart';
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

  /// Looked up once in [initState]: [dispose] runs too late to read the tree.
  late final TutorialViewModel _tutorial;

  @override
  void initState() {
    super.initState();
    // Leaving the app replays the splash, which replaces this screen — so put
    // back whatever the merchant had typed before it was torn down.
    _tutorial = context.read<TutorialViewModel>();
    _model.restore(_tutorial.draftFor(Routes.tutorialProduct));
    // The selling price's validity depends on the cost price, so the form has
    // to re-evaluate when the cost changes, not only when selling does.
    _model.costPrice.controller.addListener(_model.onCostPriceChanged);
  }

  @override
  void dispose() {
    // A step that went through has spent its values; any other close keeps
    // them for when the step opens again.
    if (_model.created != null || _model.alreadyExists) {
      _tutorial.clearDraft(Routes.tutorialProduct);
    } else {
      _tutorial.saveDraft(Routes.tutorialProduct, _model.draft);
    }
    _model.dispose();
    super.dispose();
  }

  Future<void> _create() async {
    final product = await _model.submitAndCreate();
    // The router is looked up only on the success path, not before the
    // attempt. Capturing it up front would make a screen that merely *fails
    // validation* depend on a GoRouter being in the tree — which is exactly
    // what made the sign-out button untestable in isolation.
    // `alreadyExists` is a success for this step's purpose: the merchant has
    // a product, which is what "create your first product" was asking for.
    // See [TutorialProductViewModel.alreadyExists].
    if ((product == null && !_model.alreadyExists) || !mounted) return;
    // Raised before the navigation, and read on the step after it: the root
    // ScaffoldMessenger outlives the route change. A failure is not toasted —
    // it stays in the inline line above the button, where the merchant can
    // still see it while they fix the field.
    if (product != null) {
      AppToast.success(context, L10n.of(context).toastProductCreated);
    } else {
      AppToast.info(context, L10n.of(context).tutorialStepAlreadyDone);
    }
    await context.read<SessionViewModel>()
        .rememberTutorialStep(Routes.tutorialAgent);
    if (!mounted) return;
    GoRouter.of(context).go(Routes.tutorialAgent);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);

    return ChangeNotifierProvider<TutorialProductViewModel>.value(
      value: _model,
      child: Consumer<TutorialProductViewModel>(
        builder: (context, model, _) {
          // Our own validators first, then the server's.
          //
          // Ours run on every keystroke and are what the merchant is
          // correcting right now; the server's arrive once, on submit, and
          // describe the state at that moment. Showing a stale server message
          // over a field the merchant has since fixed would be worse than
          // showing nothing — so a live client error wins, and the server's
          // fills in for the rules only it knows.
          String? errorFor(FormFieldModel field, String apiName) {
            final local = model.visibleError(field);
            if (local != null) return tutorialFieldMessage(local, l10n);
            return model.serverFieldErrors[apiName];
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
                  errorText: errorFor(model.name, 'name'),
                  placeholder: l10n.productNamePlaceholder,
                  textCapitalization: TextCapitalization.sentences,
                  textInputAction: TextInputAction.next,
                  // Every hop on this form is named. It used to rely on
                  // Flutter's default `nextFocus()`, on the reasoning that the
                  // six fields are adjacent so reading-order traversal could
                  // only land on the right one — and the widget test agreed.
                  // On a handset it did not: **next** from the description
                  // went nowhere instead of to the cost price. Traversal
                  // depends on the focus tree and the policy resolved at run
                  // time; naming the target depends on neither, which is why
                  // `T4`, both auth screens and `18` were already written this
                  // way.
                  onSubmitted: (_) => model.sku.focusNode.requestFocus(),
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
                  errorText: errorFor(model.sku, 'sku'),
                  placeholder: l10n.productSkuPlaceholder,
                  textCapitalization: TextCapitalization.characters,
                  textInputAction: TextInputAction.next,
                  onSubmitted: (_) => model.description.focusNode.requestFocus(),
                  inputFormatters: [LengthLimitingTextInputFormatter(255)],
                ),
                _gap,
                AppTextField(
                  label: l10n.productDescription,
                  controller: model.description.controller,
                  focusNode: model.description.focusNode,
                  errorText: errorFor(model.description, 'description'),
                  placeholder: l10n.productDescriptionPlaceholder,
                  textCapitalization: TextCapitalization.sentences,
                  textInputAction: TextInputAction.next,
                  onSubmitted: (_) => model.costPrice.focusNode.requestFocus(),
                  inputFormatters: [LengthLimitingTextInputFormatter(5000)],
                ),
                _gap,
                AppTextField(
                  label: l10n.productCostPrice,
                  isRequired: true,
                  controller: model.costPrice.controller,
                  focusNode: model.costPrice.focusNode,
                  errorText: errorFor(model.costPrice, 'costPrice'),
                  placeholder: '0',
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  textInputAction: TextInputAction.next,
                  onSubmitted: (_) => model.sellingPrice.focusNode.requestFocus(),
                  inputFormatters: [_amountFormatter],
                ),
                _gap,
                AppTextField(
                  label: l10n.productSellingPrice,
                  isRequired: true,
                  controller: model.sellingPrice.controller,
                  focusNode: model.sellingPrice.focusNode,
                  errorText: errorFor(model.sellingPrice, 'sellingPrice'),
                  placeholder: '0',
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  textInputAction: TextInputAction.next,
                  onSubmitted: (_) => model.quantity.focusNode.requestFocus(),
                  inputFormatters: [_amountFormatter],
                ),
                _gap,
                AppTextField(
                  label: l10n.productQuantity,
                  isRequired: true,
                  controller: model.quantity.controller,
                  focusNode: model.quantity.focusNode,
                  errorText: errorFor(model.quantity, 'quantity'),
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

