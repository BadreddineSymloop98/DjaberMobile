import 'package:djaber_mobile/core/error/app_exception.dart';
import 'package:djaber_mobile/core/error/result.dart';
import 'package:djaber_mobile/data/models/agent.dart';
import 'package:djaber_mobile/data/models/catalogue.dart';
import 'package:djaber_mobile/data/models/connected_page.dart';
import 'package:djaber_mobile/data/models/conversation.dart';
import 'package:djaber_mobile/data/models/dashboard_stats.dart';
import 'package:djaber_mobile/data/models/page_summary.dart';
import 'package:djaber_mobile/data/models/product.dart';
import 'package:djaber_mobile/data/models/stock_overview.dart';
import 'package:djaber_mobile/data/repositories/agent_repository.dart';
import 'package:djaber_mobile/data/repositories/catalogue_repository.dart';
import 'package:djaber_mobile/data/repositories/dashboard_repository.dart';
import 'package:djaber_mobile/data/repositories/notification_repository.dart';
import 'package:djaber_mobile/data/repositories/page_repository.dart';
import 'package:djaber_mobile/data/repositories/product_repository.dart';

import 'auth_host.dart';

/// Repositories that answer from memory instead of the network.
///
/// Subclasses of the real ones rather than interfaces: the screen and the view
/// model depend on the concrete types, and overriding the three methods that
/// matter keeps the rest — the parsing, the endpoint constants — honest.
///
/// Each one can be told to fail, because a partial failure is a state
/// `09 — Accueil` is specifically built to survive: one dead endpoint must not
/// take the whole screen with it.
class FakeDashboardRepository extends DashboardRepository {
  FakeDashboardRepository({
    this.stats0 = const DashboardStats(),
    this.sales0 = const SalesStats(),
    this.conversations = const {},
    this.statsFails = false,
    this.salesFails = false,
    this.movements = const [],
    this.purchases0 = const PurchaseStats(),
    this.purchasesFails = false,
  }) : super(api: apiForTest());

  final DashboardStats stats0;
  final SalesStats sales0;

  /// `16 — Aperçu du stock`: the dashboard's movements, and the purchases block.
  final List<StockMovement> movements;
  final PurchaseStats purchases0;
  final bool purchasesFails;

  @override
  Future<Result<StockOverview>> overview() async => statsFails
      ? const Result.failure(ServerException('unreachable'))
      : Result.success(StockOverview(stats: stats0, movements: movements));

  @override
  Future<Result<PurchaseStats>> purchaseStats() async => purchasesFails
      ? const Result.failure(ServerException('unreachable'))
      : Result.success(purchases0);

  /// Keyed by our own page row id, as [DashboardRepository.conversationsFor]
  /// takes it.
  final Map<String, List<Conversation>> conversations;

  final bool statsFails;
  final bool salesFails;

  /// Page ids asked for, in order — so a test can prove the queue fans out
  /// across every connected Page rather than only the first.
  final asked = <String>[];

  @override
  Future<Result<DashboardStats>> stats() async => statsFails
      ? const Result.failure(ServerException('unreachable'))
      : Result.success(stats0);

  @override
  Future<Result<SalesStats>> salesStats() async => salesFails
      ? const Result.failure(ServerException('unreachable'))
      : Result.success(sales0);

  @override
  Future<Result<List<Conversation>>> conversationsFor(String pageId) async {
    asked.add(pageId);
    final rows = conversations[pageId];
    return rows == null
        ? const Result.failure(ServerException('unreachable'))
        : Result.success(rows);
  }
}

class FakePageRepository extends PageRepository {
  FakePageRepository({
    this.pages = const [],
    this.fails = false,
    this.summaries = const {},
    this.draft,
  }) : super(api: apiForTest());

  /// Reassign to play a page connected (or removed) behind the screen's back.
  List<ConnectedPage> pages;
  final bool fails;

  /// Page id → its card. A page with none answers with a failure.
  final Map<String, PageSummary> summaries;

  /// What `generate-agent` answers; null makes it fail.
  final GeneratedAgentDraft? draft;

  final disconnected = <String>[];
  final applied = <({String pageId, String instructions})>[];

  @override
  Future<Result<List<ConnectedPage>>> list() async => fails
      ? const Result.failure(ServerException('unreachable'))
      : Result.success(pages);

  @override
  Future<Result<PageSummary>> summary(String pageId) async {
    final summary = summaries[pageId];
    return summary == null ? const Result.failure(ServerException('unreachable')) : Result.success(summary);
  }

  @override
  Future<Result<void>> disconnect(String pageId) async {
    disconnected.add(pageId);
    pages = [for (final page in pages) if (page.id != pageId) page];
    return const Result.success(null);
  }

  @override
  Future<Result<String>> authUrlFor(PagePlatform platform) async =>
      const Result.success('https://www.facebook.com/v18.0/dialog/oauth');

  @override
  Future<Result<GeneratedAgentDraft>> generateAgent(String pageId) async {
    final value = draft;
    return value == null ? const Result.failure(ServerException('unreachable')) : Result.success(value);
  }

  @override
  Future<Result<bool>> applyAgent(String pageId, GeneratedAgentDraft draft, {required String instructions}) async {
    applied.add((pageId: pageId, instructions: instructions));
    return const Result.success(true);
  }
}

class FakeAgentRepository extends AgentRepository {
  FakeAgentRepository({this.agents = const [], this.fails = false})
      : super(api: apiForTest());

  final List<Agent> agents;
  final bool fails;

  @override
  Future<Result<List<Agent>>> list() async =>
      fails ? const Result.failure(ServerException('unreachable')) : Result.success(agents);
}

/// Answers a product create without a network, either way.
///
/// Added for the success-toast tests: the toast is raised on the success path
/// only, so a fake that can do both is what separates "confirms a write" from
/// "confirms a tap".
class FakeProductRepository extends ProductRepository {
  FakeProductRepository({
    this.fails = false,
    this.error,
    this.rows = const [],
    this.listFails = false,
  }) : super(api: apiForTest());

  final bool fails;

  /// The failure to answer with. Defaults to the shape the real backend sends
  /// for a duplicate SKU — a 400 carrying a usable message.
  final AppException? error;

  /// The rows [list] answers with. Order is preserved — the screen does not
  /// sort, because the endpoint already did.
  final List<Product> rows;

  /// Set to prove the empty state, which is a different screen from a failure.
  final bool listFails;

  /// Every set of query arguments `list` was called with, in order. A filter
  /// that quietly never reaches the request is the failure mode worth
  /// asserting on: the rows would still change, because the fake is filtered
  /// too, and the screen would look right while paging was broken.
  final calls = <({String? search, String? categoryId, bool lowStock})>[];

  @override
  Future<Result<ProductPage>> list({
    String? search,
    String? categoryId,
    bool lowStock = false,
    int limit = 50,
    int offset = 0,
  }) async {
    calls.add((search: search, categoryId: categoryId, lowStock: lowStock));
    if (listFails) {
      return const Result.failure(ServerException('unreachable'));
    }
    // Filtered the way the server does, so a screen driving the filters sees
    // rows change rather than a constant list.
    final matched = rows.where((product) {
      if (lowStock && !product.isLowStock) return false;
      if (categoryId != null && product.categoryId != categoryId) return false;
      if (search != null && search.trim().isNotEmpty) {
        final needle = search.trim().toLowerCase();
        if (!product.name.toLowerCase().contains(needle) &&
            !product.sku.toLowerCase().contains(needle)) {
          return false;
        }
      }
      return true;
    }).toList(growable: false);
    return Result.success((products: matched, total: matched.length));
  }

  @override
  Future<Result<Product>> create({
    required String sku,
    required String name,
    String? description,
    required double costPrice,
    required double sellingPrice,
    required int quantity,
    int minQuantity = 0,
    String? categoryId,
    String? unitId,
    bool hasVariants = false,
  }) async {
    if (fails) {
      return Result.failure(
        error ??
            const ValidationException('SKU already exists', statusCode: 400),
      );
    }
    return Result.success(
      Product(
        id: 'p-1',
        sku: sku,
        name: name,
        description: description,
        costPrice: costPrice,
        sellingPrice: sellingPrice,
        quantity: quantity,
      ),
    );
  }
}

/// The two lookup lists behind the pickers on `18 — Ajouter un produit`.
///
/// Both default to **empty**, which is the state a new account is genuinely
/// in: categories are created on the web, so a merchant who has never been
/// there has none. The form has to stay usable in that state — a product can
/// be created with neither a category nor a unit — so it is the right default
/// for a test to start from.
class FakeCatalogueRepository extends CatalogueRepository {
  FakeCatalogueRepository({
    this.categoryList = const [],
    this.unitList = const [],
    this.fails = false,
  }) : super(api: apiForTest());

  final List<ProductCategory> categoryList;
  final List<ProductUnit> unitList;
  final bool fails;

  @override
  Future<Result<List<ProductCategory>>> categories() async => fails
      ? const Result.failure(ServerException('unreachable'))
      : Result.success(categoryList);

  @override
  Future<Result<List<ProductUnit>>> units() async => fails
      ? const Result.failure(ServerException('unreachable'))
      : Result.success(unitList);
}

/// Answers the drawer's unread-notification badge without a network.
///
/// [fails] exists because a failed count must leave the badge **absent**, not
/// zero — a badge is a claim about how much is waiting, and "we could not ask"
/// is not the same claim as "nothing".
class FakeNotificationRepository extends NotificationRepository {
  FakeNotificationRepository({this.count = 0, this.fails = false})
      : super(api: apiForTest());

  final int count;
  final bool fails;

  @override
  Future<Result<int>> unreadCount() async => fails
      ? const Result.failure(ServerException('unreachable'))
      : Result.success(count);
}
