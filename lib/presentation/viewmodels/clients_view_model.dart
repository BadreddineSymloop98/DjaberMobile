import '../../core/error/result.dart';
import '../../data/models/client.dart';
import '../../data/repositories/client_repository.dart';
import 'base_view_model.dart';

/// *Statut* in the filter sheet — the web's `'' | 'true' | 'false'`.
enum ClientStatusFilter { all, active, inactive }

/// The filter sheet's values. Immutable, so the sheet edits a draft and the
/// screen compares it with what is applied.
///
/// The dates are **not** here: they live on the screen as their own chips, as
/// on the web and in the frame, and apply the moment a day is picked.
class ClientFilters {
  const ClientFilters({
    this.status = ClientStatusFilter.all,
    this.source,
    this.minOrders,
    this.maxOrders,
    this.minSpent,
    this.maxSpent,
  });

  final ClientStatusFilter status;

  /// Null for *Tous*.
  final ClientSource? source;
  final int? minOrders;
  final int? maxOrders;
  final double? minSpent;
  final double? maxSpent;

  /// The web's `activeFilterCount`: each range counts once.
  int get activeCount =>
      (status != ClientStatusFilter.all ? 1 : 0) +
      (source != null ? 1 : 0) +
      ((minOrders ?? 0) > 0 || (maxOrders ?? 0) > 0 ? 1 : 0) +
      ((minSpent ?? 0) > 0 || (maxSpent ?? 0) > 0 ? 1 : 0);

  bool get isEmpty => activeCount == 0;

  @override
  bool operator ==(Object other) =>
      other is ClientFilters &&
      other.status == status &&
      other.source == source &&
      other.minOrders == minOrders &&
      other.maxOrders == maxOrders &&
      other.minSpent == minSpent &&
      other.maxSpent == maxSpent;

  @override
  int get hashCode => Object.hash(status, source, minOrders, maxOrders, minSpent, maxSpent);
}

/// A phone as the duplicate check compares it: spaces, dashes and brackets
/// removed — the web's own `replace(/\s|-|\(|\)/g, '')`.
String normalizePhone(String phone) => phone.replaceAll(RegExp(r'[\s\-()]'), '');

/// `Clients` — the web's `stock/clients` page.
///
/// Two searches (name or e-mail, and phone), the filter sheet and the two date
/// chips all go to the server. The four figures at the top are computed from
/// the list the server returned, **as the web computes them** — so they follow
/// the filters: a search for "Amina" shows one client's total spend, not the
/// shop's.
class ClientsViewModel extends BaseViewModel {
  ClientsViewModel({required ClientRepository clients}) : _clients = clients;

  final ClientRepository _clients;

  List<Client> _list = const [];
  List<Client> get clients => _list;

  String _search = '';
  String _phone = '';
  ClientFilters _filters = const ClientFilters();
  DateTime? _startDate;
  DateTime? _endDate;

  ClientFilters get filters => _filters;
  DateTime? get startDate => _startDate;
  DateTime? get endDate => _endDate;

  bool _loadedOnce = false;
  bool get isFirstLoad => !_loadedOnce;

  bool get isNarrowed =>
      _search.trim().isNotEmpty ||
      _phone.trim().isNotEmpty ||
      !_filters.isEmpty ||
      _startDate != null ||
      _endDate != null;

  // ---- The four figures (web: `stats` useMemo) ----

  int get totalCount => _list.length;
  int get activeCount => _list.where((c) => c.isActive).length;
  int get withOrdersCount => _list.where((c) => c.totalOrders > 0).length;
  double get totalSpent => _list.fold(0, (sum, c) => sum + c.totalSpent);

  /// Normalized phone → client, from what the server has returned. The form
  /// checks against it to say *which* client already has a number, as the
  /// web does, before the server's bare 400.
  ///
  /// Replaced on an unfiltered load (the whole list), merged on a filtered one.
  Map<String, Client> _knownPhones = const {};
  Map<String, Client> get knownPhones => _knownPhones;

  Future<void> load() async {
    final narrowed = isNarrowed;
    await run(
      () => _clients.list(
        search: _search,
        phone: _phone,
        isActive: switch (_filters.status) {
          ClientStatusFilter.all => null,
          ClientStatusFilter.active => true,
          ClientStatusFilter.inactive => false,
        },
        source: _filters.source,
        minOrders: _filters.minOrders,
        maxOrders: _filters.maxOrders,
        minSpent: _filters.minSpent,
        maxSpent: _filters.maxSpent,
        startDate: _startDate,
        endDate: _endDate,
      ),
      onSuccess: (value) {
        _list = value;
        final phones = {
          for (final c in value)
            if (c.phone != null) normalizePhone(c.phone!): c,
        };
        _knownPhones = narrowed ? {..._knownPhones, ...phones} : phones;
      },
      silent: _loadedOnce,
      tag: 'clients',
    );
    _loadedOnce = true;
    safeNotify();
  }

  void setSearch(String value) {
    if (value == _search) return;
    _search = value;
    load();
  }

  void setPhone(String value) {
    if (value == _phone) return;
    _phone = value;
    load();
  }

  void applyFilters(ClientFilters value) {
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

  Future<Result<void>> delete(Client client) async {
    final result = await _clients.delete(client.id);
    if (isDisposed) return result;
    if (result.isSuccess) await load();
    return result;
  }
}
