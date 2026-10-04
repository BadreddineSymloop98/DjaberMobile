import '../../core/error/app_exception.dart';
import '../../data/models/agent.dart';
import '../../data/models/agent_draft.dart';
import '../../data/models/product.dart';
import '../../data/repositories/agent_repository.dart';
import '../../data/repositories/product_repository.dart';
import 'base_view_model.dart';

/// `Produits de <page>` — which products the page's agent sells.
///
/// The selection belongs to the **agent**, not the page (the web's
/// `page/[id]/stock`): saving sends `sellAllProducts` and `productIds` to it.
/// When the agent answers on other pages too, the screen says so above the
/// button (decided 2026-10-04) — the selection applies there as well.
class PageProductsViewModel extends BaseViewModel {
  PageProductsViewModel({
    required AgentRepository agents,
    required ProductRepository products,
    required this.pageId,
  }) : _agents = agents,
       _products = products;

  final AgentRepository _agents;
  final ProductRepository _products;
  final String pageId;

  Agent? _agent;
  Agent? get agent => _agent;

  /// The other connected pages the same agent answers on.
  int get otherPages {
    final count = _agent?.connectedPageCount ?? 0;
    return count > 1 ? count - 1 : 0;
  }

  List<Product> _catalogue = const [];
  List<Product> get catalogue => _catalogue;

  /// The catalogue's real size, which may exceed what was loaded.
  int _catalogueTotal = 0;
  int get catalogueTotal => _catalogueTotal;

  bool _sellAll = true;
  bool get sellAll => _sellAll;

  bool _savedSellAll = true;

  /// Kept whole, even ids of products beyond the loaded page: saving sends the
  /// set back, and dropping what was not on screen would unlink it.
  Set<String> _selected = {};
  Set<String> _savedSelected = {};

  bool isSelected(Product p) => _selected.contains(p.id);
  int get selectedCount => _selected.length;

  String _query = '';

  bool _loadedOnce = false;
  bool get isFirstLoad => !_loadedOnce;

  List<Product> get visible {
    final needle = _query.trim().toLowerCase();
    if (needle.isEmpty) return _catalogue;
    return [
      for (final p in _catalogue)
        if (p.name.toLowerCase().contains(needle) || p.sku.toLowerCase().contains(needle)) p,
    ];
  }

  bool get isDirty =>
      _sellAll != _savedSellAll ||
      (!_sellAll &&
          (_selected.length != _savedSelected.length || !_selected.containsAll(_savedSelected)));

  /// Selling a chosen few, but none chosen: the agent would have nothing.
  bool get selectionEmpty => !_sellAll && _selected.isEmpty;

  bool get canSave => _agent != null && isDirty && !selectionEmpty && !isBusy;

  Future<void> load() async {
    await run(
      _agents.list,
      onSuccess: (agents) => _agent = agents.where((a) => a.pageIds.contains(pageId)).firstOrNull,
      silent: _loadedOnce,
      tag: 'pageProducts',
    );
    if (isDisposed) return;
    final agent = _agent;
    if (agent != null) {
      final draft = _agents.getDraft(agent.id);
      final products = _products.list(limit: 500);
      final draftResult = await draft;
      final productsResult = await products;
      if (isDisposed) return;
      if (productsResult.valueOrNull case final page?) {
        _catalogue = page.products;
        _catalogueTotal = page.total;
      }
      if (draftResult.valueOrNull case final AgentDraft d) {
        _sellAll = _savedSellAll = d.sellAllProducts;
        _selected = {...d.productIds};
        _savedSelected = {...d.productIds};
      }
    }
    _loadedOnce = true;
    safeNotify();
  }

  void setSellAll(bool value) {
    _sellAll = value;
    safeNotify();
  }

  void toggle(Product p) {
    if (!_selected.remove(p.id)) _selected.add(p.id);
    safeNotify();
  }

  /// *Tout sélectionner* over what the search shows; tapped again with all of
  /// it chosen, it clears them.
  void toggleAllVisible() {
    final ids = {for (final p in visible) p.id};
    if (_selected.containsAll(ids)) {
      _selected.removeAll(ids);
    } else {
      _selected.addAll(ids);
    }
    safeNotify();
  }

  bool get allVisibleSelected {
    final ids = visible.map((p) => p.id);
    return ids.isNotEmpty && _selected.containsAll(ids);
  }

  void setQuery(String value) {
    _query = value;
    safeNotify();
  }

  AppException? _saveError;
  AppException? get saveError => _saveError;

  Future<bool> save() async {
    final agent = _agent;
    if (agent == null || !canSave) return false;
    _saveError = null;
    final saved = await run(
      () => _agents.update(
        agentId: agent.id,
        changes: {
          'sellAllProducts': _sellAll,
          // Ignored by the backend while selling everything; sent empty then,
          // as the agent form does.
          'productIds': _sellAll ? const <String>[] : _selected.toList(),
        },
      ),
      onError: (error) => _saveError = error,
      tag: 'savePageProducts',
    );
    if (saved == null) return false;
    _savedSellAll = _sellAll;
    _savedSelected = {..._selected};
    safeNotify();
    return true;
  }
}
