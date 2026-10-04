import '../../core/error/app_exception.dart';
import '../../core/error/result.dart';
import '../../data/models/recommendation.dart';
import '../../data/repositories/recommendation_repository.dart';
import 'base_view_model.dart';

/// *Toutes · Actives · Inactives*.
enum RecommendationStatus { all, active, inactive }

/// `Vente croisée / Montée en gamme` — the web's `stock/recommendations`.
///
/// The four figures cover every recommendation; the list follows the search
/// and the two chip rows. Switching one on or off shows at once and is undone
/// if the server refuses. Delete asks inline, in the card (Figma and the web),
/// with a line saying it may come back on the next generation (decided
/// 2026-10-04).
class RecommendationsViewModel extends BaseViewModel {
  RecommendationsViewModel({required RecommendationRepository recommendations})
    : _repo = recommendations;

  final RecommendationRepository _repo;

  List<Recommendation> _list = const [];
  List<Recommendation> get recommendations => _list;

  RecommendationStats? _stats;
  RecommendationStats? get stats => _stats;

  String _search = '';
  RecommendationType? _type;
  RecommendationStatus _status = RecommendationStatus.all;

  RecommendationType? get type => _type;
  RecommendationStatus get status => _status;

  bool _loadedOnce = false;
  bool get isFirstLoad => !_loadedOnce;

  bool get isNarrowed =>
      _search.trim().isNotEmpty || _type != null || _status != RecommendationStatus.all;

  int _query = 0;

  bool _generating = false;
  bool get isGenerating => _generating;

  Future<void> load() async {
    final query = ++_query;
    await run(
      () => _repo.list(
        search: _search,
        type: _type,
        isActive: switch (_status) {
          RecommendationStatus.all => null,
          RecommendationStatus.active => true,
          RecommendationStatus.inactive => false,
        },
      ),
      onSuccess: (value) {
        if (query == _query) _list = value;
      },
      silent: _loadedOnce,
      tag: 'recommendations',
    );
    _loadedOnce = true;
    safeNotify();
  }

  Future<void> loadStats() async {
    final result = await _repo.stats();
    if (isDisposed) return;
    if (result.valueOrNull case final value?) {
      _stats = value;
      safeNotify();
    }
  }

  Future<void> reload() => Future.wait([load(), loadStats()]);

  void setSearch(String value) {
    if (value == _search) return;
    _search = value;
    load();
  }

  void setType(RecommendationType? value) {
    if (value == _type) return;
    _type = value;
    load();
  }

  void setStatus(RecommendationStatus value) {
    if (value == _status) return;
    _status = value;
    load();
  }

  /// `POST /cross-sell/generate`, then everything is read again. Returns how
  /// many rows were created or refreshed, or the error.
  Future<Result<int>?> generate() async {
    if (_generating) return null;
    _generating = true;
    _confirming = null;
    safeNotify();
    final result = await _repo.generate();
    if (isDisposed) return result;
    _generating = false;
    safeNotify();
    if (result.isSuccess) await reload();
    return result;
  }

  // ---- Active ----

  final Set<String> _toggling = {};
  bool isToggling(Recommendation r) => _toggling.contains(r.id);

  /// Flips the flag on screen first, then asks the server; a refusal puts it
  /// back. Under *Actives* / *Inactives* the row stays until the next load, so
  /// a mis-tap can be undone in place.
  Future<AppException?> toggleActive(Recommendation r) async {
    if (!_toggling.add(r.id)) return null;
    final next = !r.isActive;
    _swap(r.id, (row) => row.copyWith(isActive: next));
    _shiftActive(next ? 1 : -1);
    final result = await _repo.setActive(r.id, isActive: next);
    if (isDisposed) return null;
    _toggling.remove(r.id);
    if (result.errorOrNull case final error?) {
      _swap(r.id, (row) => row.copyWith(isActive: r.isActive));
      _shiftActive(next ? -1 : 1);
      if (error is NotFoundException) _drop(r.id);
      safeNotify();
      return error;
    }
    safeNotify();
    return null;
  }

  void _shiftActive(int by) {
    final s = _stats;
    if (s == null) return;
    _stats = RecommendationStats(
      total: s.total,
      active: (s.active + by).clamp(0, s.total),
      totalImpressions: s.totalImpressions,
      totalConversions: s.totalConversions,
      conversionRate: s.conversionRate,
      totalRevenue: s.totalRevenue,
    );
  }

  // ---- Delete, confirmed in the card ----

  /// The card asking *Supprimer ?*, if any — one at a time.
  String? _confirming;
  bool isConfirming(Recommendation r) => _confirming == r.id;

  void askDelete(Recommendation r) {
    _confirming = r.id;
    safeNotify();
  }

  void cancelDelete() {
    if (_confirming == null) return;
    _confirming = null;
    safeNotify();
  }

  final Set<String> _deleting = {};
  bool isDeleting(Recommendation r) => _deleting.contains(r.id);

  /// `DELETE /cross-sell/{id}`. A 404 means it already went: the row goes too.
  Future<Result<void>> delete(Recommendation r) async {
    if (!_deleting.add(r.id)) return const Result.success(null);
    _confirming = null;
    safeNotify();
    final result = await _repo.delete(r.id);
    if (isDisposed) return result;
    _deleting.remove(r.id);
    final error = result.errorOrNull;
    if (error == null || error is NotFoundException) {
      _drop(r.id);
      await loadStats();
    }
    safeNotify();
    return result;
  }

  void _swap(String id, Recommendation Function(Recommendation) change) {
    _list = [for (final row in _list) row.id == id ? change(row) : row];
    safeNotify();
  }

  void _drop(String id) {
    _list = [
      for (final row in _list)
        if (row.id != id) row,
    ];
  }
}
