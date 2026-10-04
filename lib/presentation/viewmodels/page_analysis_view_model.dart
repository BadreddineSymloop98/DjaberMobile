import 'package:flutter/widgets.dart';

import '../../core/error/app_exception.dart';
import '../../data/models/page_detail.dart';
import '../../data/repositories/page_repository.dart';
import 'base_view_model.dart';

/// Where the analysis wizard is.
enum AnalysisStep { start, scanning, review, importing, done }

/// One candidate as the merchant edits it before importing.
class CandidateDraft {
  CandidateDraft(this.source)
    : name = TextEditingController(text: source.name),
      description = TextEditingController(text: source.description),
      price = TextEditingController(text: source.priceDA > 0 ? '${source.priceDA}' : ''),
      stock = TextEditingController();

  final ExtractedProduct source;
  final TextEditingController name;
  final TextEditingController description;
  final TextEditingController price;

  /// Required (decided 2026-10-04, as the frame marks it): 0 or more.
  final TextEditingController stock;

  final FocusNode nameFocus = FocusNode();
  final FocusNode descriptionFocus = FocusNode();
  final FocusNode priceFocus = FocusNode();
  final FocusNode stockFocus = FocusNode();

  /// A candidate with a price is picked by default; one without is shown
  /// unticked, the post may not be a sale at all.
  late bool selected = source.priceDA > 0;

  double? get priceValue => double.tryParse(price.text.trim().replaceAll(',', '.'));
  int? get stockValue => int.tryParse(stock.text.trim());

  bool get nameMissing => name.text.trim().isEmpty;
  bool get priceMissing => (priceValue ?? 0) <= 0;
  bool get stockMissing => stockValue == null || stockValue! < 0;
  bool get isComplete => !nameMissing && !priceMissing && !stockMissing;

  ImportProductItem toItem() => ImportProductItem(
    name: name.text,
    priceDA: priceValue ?? 0,
    quantity: stockValue ?? 0,
    description: description.text,
    imageUrl: source.imageUrl,
    sourcePostId: source.postId,
  );

  void dispose() {
    for (final c in [name, description, price, stock]) {
      c.dispose();
    }
    for (final f in [nameFocus, descriptionFocus, priceFocus, stockFocus]) {
      f.dispose();
    }
  }
}

/// `Analyse de la page par IA` — the web's `page/[id]/analyze`.
///
/// Start → scanning (a vision model over up to 30 posts; minutes, so it gets a
/// long timeout) → review the candidates, edit and pick → import into the main
/// stock → done. A Meta permission problem (403 `needsReconnect`) shows the
/// frame's reconnect box on the start step instead.
class PageAnalysisViewModel extends BaseViewModel {
  PageAnalysisViewModel({required PageRepository pages, required this.pageId}) : _pages = pages;

  final PageRepository _pages;
  final String pageId;

  AnalysisStep _step = AnalysisStep.start;
  AnalysisStep get step => _step;

  bool _needsReconnect = false;
  bool get needsReconnect => _needsReconnect;

  /// The server's reason the vision service is off, when it is.
  String? _warning;
  String? get warning => _warning;

  AppException? _failure;
  AppException? get failure => _failure;

  /// The scan ran and found no product in the posts — said, not swallowed.
  bool _foundNothing = false;
  bool get foundNothing => _foundNothing;

  int _scanned = 0;
  int get scanned => _scanned;

  List<CandidateDraft> _candidates = const [];
  List<CandidateDraft> get candidates => _candidates;

  List<CandidateDraft> get selected => [
    for (final c in _candidates)
      if (c.selected) c,
  ];
  int get incompleteSelected => selected.where((c) => !c.isComplete).length;

  bool get canImport =>
      _step == AnalysisStep.review && selected.isNotEmpty && incompleteSelected == 0;

  ImportResult? _result;
  ImportResult? get result => _result;

  Future<void> analyze() async {
    if (_step == AnalysisStep.scanning) return;
    _step = AnalysisStep.scanning;
    _needsReconnect = false;
    _warning = null;
    _failure = null;
    _foundNothing = false;
    safeNotify();
    final result = await _pages.analyze(pageId);
    if (isDisposed) return;
    final error = result.errorOrNull;
    if (error != null) {
      _step = AnalysisStep.start;
      _needsReconnect = error is ForbiddenException && error.data?['needsReconnect'] == true;
      if (!_needsReconnect) _failure = error;
      safeNotify();
      return;
    }
    final analysis = result.valueOrNull!;
    _disposeCandidates();
    _scanned = analysis.scanned;
    _warning = analysis.warning;
    _candidates = [for (final p in analysis.extracted) CandidateDraft(p)];
    for (final c in _candidates) {
      for (final field in [c.name, c.price, c.stock]) {
        field.addListener(safeNotify);
      }
    }
    _foundNothing = _candidates.isEmpty && _warning == null;
    _step = _candidates.isEmpty ? AnalysisStep.start : AnalysisStep.review;
    safeNotify();
  }

  void toggle(CandidateDraft c) {
    c.selected = !c.selected;
    safeNotify();
  }

  void selectAll(bool value) {
    for (final c in _candidates) {
      c.selected = value;
    }
    safeNotify();
  }

  /// `import-products` with the picked, completed candidates.
  Future<AppException?> importSelected() async {
    if (!canImport) return null;
    _step = AnalysisStep.importing;
    safeNotify();
    final result = await _pages.importProducts(pageId, [for (final c in selected) c.toItem()]);
    if (isDisposed) return null;
    if (result.errorOrNull case final error?) {
      _step = AnalysisStep.review;
      safeNotify();
      return error;
    }
    _result = result.valueOrNull;
    _step = AnalysisStep.done;
    safeNotify();
    return null;
  }

  /// After *done*, or to scan again from the start.
  void restart() {
    _disposeCandidates();
    _candidates = const [];
    _result = null;
    _step = AnalysisStep.start;
    safeNotify();
  }

  void _disposeCandidates() {
    for (final c in _candidates) {
      c.dispose();
    }
  }

  @override
  void dispose() {
    _disposeCandidates();
    super.dispose();
  }
}
