import '../../core/error/app_exception.dart';
import '../../core/error/result.dart';
import '../../core/utils/validators.dart';
import '../../data/models/caisse.dart';
import '../../data/models/sale.dart';
import '../../data/repositories/caisse_repository.dart';
import 'base_view_model.dart';
import 'form_field_model.dart';

/// The filter sheet's two values; the date chips live on the screen.
class CaisseFilters {
  const CaisseFilters({this.type, this.category});

  final CaisseType? type;
  final CaisseCategory? category;

  int get activeCount => (type != null ? 1 : 0) + (category != null ? 1 : 0);
  bool get isEmpty => activeCount == 0;

  @override
  bool operator ==(Object other) =>
      other is CaisseFilters && other.type == type && other.category == category;

  @override
  int get hashCode => Object.hash(type, category);
}

/// `Caisse` — the web's `stock/caisse`: the period's four figures and every
/// ledger row, newest first, paged in as it scrolls.
class CaisseViewModel extends BaseViewModel {
  CaisseViewModel({required CaisseRepository caisse}) : _caisse = caisse;

  final CaisseRepository _caisse;

  static const pageSize = 30;

  List<CaisseTransaction> _list = const [];
  List<CaisseTransaction> get transactions => _list;

  int _total = 0;
  int get total => _total;

  CaisseStats? _stats;
  CaisseStats? get stats => _stats;

  /// The frame opens on *Ce mois-ci*, as the web does.
  SalePeriod _period = SalePeriod.month;
  SalePeriod get period => _period;

  String _search = '';
  CaisseFilters _filters = const CaisseFilters();
  DateTime? _startDate;
  DateTime? _endDate;

  CaisseFilters get filters => _filters;
  DateTime? get startDate => _startDate;
  DateTime? get endDate => _endDate;

  bool _loadedOnce = false;
  bool get isFirstLoad => !_loadedOnce;

  bool _loadingMore = false;
  bool get isLoadingMore => _loadingMore;
  bool get hasMore => _list.length < _total;

  int _query = 0;

  bool get isNarrowed =>
      _search.trim().isNotEmpty || !_filters.isEmpty || _startDate != null || _endDate != null;

  Future<Result<CaissePage>> _page(int offset) => _caisse.list(
    search: _search,
    type: _filters.type,
    category: _filters.category,
    dateFrom: _startDate,
    dateTo: _endDate,
    limit: pageSize,
    offset: offset,
  );

  Future<void> load() async {
    final query = ++_query;
    _loadingMore = false;
    await run(
      () => _page(0),
      onSuccess: (value) {
        if (query != _query) return;
        _list = value.transactions;
        _total = value.total;
      },
      silent: _loadedOnce,
      tag: 'caisse',
    );
    _loadedOnce = true;
    safeNotify();
  }

  Future<void> loadMore() async {
    if (_loadingMore || !hasMore || !_loadedOnce) return;
    final query = _query;
    _loadingMore = true;
    safeNotify();
    final result = await _page(_list.length);
    if (isDisposed || query != _query) return;
    _loadingMore = false;
    if (result.valueOrNull case final page?) {
      final known = {for (final t in _list) t.id};
      _list = [
        ..._list,
        for (final t in page.transactions)
          if (!known.contains(t.id)) t,
      ];
      _total = page.total;
    }
    safeNotify();
  }

  Future<void> loadStats() async {
    final period = _period;
    final result = await _caisse.stats(period);
    if (isDisposed || period != _period) return;
    if (result.valueOrNull case final value?) {
      _stats = value;
      safeNotify();
    }
  }

  Future<void> reload() => Future.wait([load(), loadStats()]);

  void setPeriod(SalePeriod value) {
    if (value == _period) return;
    _period = value;
    _stats = null;
    safeNotify();
    loadStats();
  }

  void setSearch(String value) {
    if (value == _search) return;
    _search = value;
    load();
  }

  void applyFilters(CaisseFilters value) {
    if (value == _filters) return;
    _filters = value;
    load();
  }

  void setStartDate(DateTime? value) {
    if (value == _startDate) return;
    _startDate = value;
    load();
  }

  void setEndDate(DateTime? value) {
    if (value == _endDate) return;
    _endDate = value;
    load();
  }

  /// After the form saved: the list is read again rather than patched — a new
  /// date can move the row anywhere, and the filters may now leave it out.
  Future<void> saved() => reload();

  final Set<String> _deleting = {};
  bool isDeleting(CaisseTransaction row) => _deleting.contains(row.id);

  /// `DELETE /caisse/{id}`. A 404 means it already went: the row goes too.
  Future<Result<void>> delete(CaisseTransaction row) async {
    if (!_deleting.add(row.id)) return const Result.success(null);
    safeNotify();
    final result = await _caisse.delete(row.id);
    if (isDisposed) return result;
    _deleting.remove(row.id);
    final error = result.errorOrNull;
    if (error == null || error is NotFoundException) {
      _list = [
        for (final t in _list)
          if (t.id != row.id) t,
      ];
      _total = _total > 0 ? _total - 1 : 0;
      safeNotify();
      await loadStats();
    } else {
      safeNotify();
    }
    return result;
  }
}

/// Why the form cannot be saved yet.
enum CaisseFormProblem { noAmount, amountNotPositive }

/// `Add / edit a transaction` — the sheet over the list.
///
/// New rows start as an **expense** in *Autre*, dated today: the web's
/// defaults, and the common case (money going out that no sale or purchase
/// recorded). Editing keeps the row's own time of day unless the day changes.
class CaisseFormViewModel extends FormViewModel {
  CaisseFormViewModel({required CaisseRepository caisse, this.editing}) : _caisse = caisse {
    attachFields();
    final row = editing;
    if (row != null) {
      amount.controller.text = _plain(row.amount);
      reference.controller.text = row.reference ?? '';
      description.controller.text = row.description ?? '';
      _type = row.type;
      // An old row may carry a category the form no longer offers; it is kept,
      // not silently changed.
      _category = row.category;
      _date = row.date.toLocal();
    }
  }

  final CaisseRepository _caisse;
  final CaisseTransaction? editing;

  bool get isEditing => editing != null;

  final amount = FormFieldModel(validator: Validators.optional);
  final reference = FormFieldModel(validator: Validators.optional);
  final description = FormFieldModel(validator: Validators.optional);

  @override
  List<FormFieldModel> get fields => [amount, reference, description];

  CaisseType _type = CaisseType.expense;
  CaisseType get type => _type;

  CaisseCategory _category = CaisseCategory.other;
  CaisseCategory get category => _category;

  /// The form's choices: the manual six, plus the row's own when editing an
  /// older one that used another.
  List<CaisseCategory> get categories => [
    ...CaisseCategory.manual,
    if (!CaisseCategory.manual.contains(_category)) _category,
  ];

  DateTime _date = DateTime.now();
  DateTime get date => _date;

  void setType(CaisseType value) {
    _type = value;
    safeNotify();
  }

  void setCategory(CaisseCategory? value) {
    if (value == null) return;
    _category = value;
    safeNotify();
  }

  /// The picked day; today's keeps the current time, another day keeps the
  /// row's own time (or the current one for a new row).
  void setDate(DateTime day) {
    final clock = editing?.date.toLocal() ?? DateTime.now();
    _date = DateTime(day.year, day.month, day.day, clock.hour, clock.minute, clock.second);
    safeNotify();
  }

  double? get _amount => double.tryParse(amount.value.trim().replaceAll(',', '.'));

  CaisseFormProblem? get problem {
    final value = _amount;
    if (amount.value.trim().isEmpty) return CaisseFormProblem.noAmount;
    if (value == null || value <= 0) return CaisseFormProblem.amountNotPositive;
    return null;
  }

  bool _tried = false;

  /// The amount's message is shown once the field has been used or a save
  /// tried — an empty sheet does not open on an error.
  CaisseFormProblem? get visibleProblem => (_tried || amount.value.isNotEmpty) ? problem : null;

  bool get isDirty {
    final row = editing;
    if (row == null) {
      return amount.value.trim().isNotEmpty ||
          reference.value.trim().isNotEmpty ||
          description.value.trim().isNotEmpty;
    }
    return _amount != row.amount ||
        _type != row.type ||
        _category != row.category ||
        reference.value.trim() != (row.reference ?? '') ||
        description.value.trim() != (row.description ?? '') ||
        !_sameDay(_date, row.date.toLocal());
  }

  static bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  AppException? _saveError;
  AppException? get saveError => _saveError;

  Future<CaisseTransaction?> save() async {
    _tried = true;
    if (problem != null || isBusy) {
      safeNotify();
      return null;
    }
    final row = editing;
    // Nothing changed: closing is the whole of the save.
    if (row != null && !isDirty) return row;
    _saveError = null;
    return run(
      () => row == null
          ? _caisse.create(
              type: _type,
              amount: _amount!,
              category: _category,
              reference: reference.value,
              description: description.value,
              date: _date,
            )
          : _caisse.update(
              row.id,
              type: _type,
              amount: _amount!,
              category: _category,
              reference: reference.value,
              description: description.value,
              date: _date,
            ),
      onError: (error) => _saveError = error,
      tag: 'saveCaisse',
    );
  }

  static String _plain(double value) =>
      value == value.roundToDouble() ? value.round().toString() : value.toStringAsFixed(2);
}
