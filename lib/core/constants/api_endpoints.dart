/// Every backend path the mobile app uses.
///
/// Read from `backend/src/routes/*.ts` — `auth.routes.ts`, `devices.routes.ts`,
/// `pages.routes.ts`, `page-config.routes.ts` and `user-stock.routes.ts`, which
/// is where the 134 stock endpoints live. Paths are kept here rather than
/// inline in repositories so a backend rename is one file to change.
///
/// Deliberately omitted: `/api/user-stock/reports/*`, `/analytics/*` and
/// `/caisse/*` — desk work that stays on the web (brief §14.3), and
/// `/api/admin/*`, which merchants never call.
class Api {
  const Api._();

  // ---- Auth (auth.routes.ts) ----
  static const login = '/api/auth/login';
  static const register = '/api/auth/register';
  static const profile = '/api/auth/profile';
  // NOTE: the web ships a /forgot-password page but it calls nothing — there is
  // no reset endpoint on the backend yet. The mobile screen will need one built
  // before it can work.

  // ---- Devices / push (devices.routes.ts) ----
  static const registerDevice = '/api/devices/register';
  static const unregisterDevice = '/api/devices/unregister';

  // ---- Pages (pages.routes.ts) ----
  static const pages = '/api/pages';
  static String page(String pageId) => '/api/pages/$pageId';
  static String pageSummary(String pageId) => '/api/pages/$pageId/summary';
  static String pageInsights(String pageId) => '/api/pages/$pageId/insights';
  static String pageAiSettings(String pageId) => '/api/pages/$pageId/ai-settings';
  static String pageSync(String pageId) => '/api/pages/$pageId/sync';

  // ---- Conversations (page-config.routes.ts) ----
  static String pageConversations(String pageId) =>
      '/api/pages/$pageId/conversations';
  static String conversationMessages(String conversationId) =>
      '/api/pages/conversations/$conversationId/messages';
  static String conversation(String conversationId) =>
      '/api/pages/conversations/$conversationId';
  static String conversationReply(String conversationId) =>
      '/api/pages/conversations/$conversationId/reply';

  // ---- Dashboard ----
  static const dashboard = '/api/user-stock/dashboard';

  // ---- Products ----
  static const products = '/api/user-stock/products';
  static String product(String id) => '/api/user-stock/products/$id';
  static String productAdjust(String id) =>
      '/api/user-stock/products/$id/adjust';
  static String productImages(String id) =>
      '/api/user-stock/products/$id/images';
  static String productImage(String id, String imageId) =>
      '/api/user-stock/products/$id/images/$imageId';
  static String productImagePrimary(String id, String imageId) =>
      '/api/user-stock/products/$id/images/$imageId/primary';
  static String productImagesReorder(String id) =>
      '/api/user-stock/products/$id/images/reorder';
  static String productVariants(String id) =>
      '/api/user-stock/products/$id/variants';
  static String productVariant(String id, String variantId) =>
      '/api/user-stock/products/$id/variants/$variantId';
  static String productVariantAdjust(String id, String variantId) =>
      '/api/user-stock/products/$id/variants/$variantId/adjust';

  // ---- Stock movements ----
  static const movements = '/api/user-stock/movements';

  // ---- Catalogue metadata ----
  static const categories = '/api/user-stock/categories';
  static String category(String id) => '/api/user-stock/categories/$id';
  static const units = '/api/user-stock/units';
  static String unit(String id) => '/api/user-stock/units/$id';

  // ---- Orders ----
  static const orders = '/api/user-stock/orders';
  static const orderStats = '/api/user-stock/orders/stats';
  static String order(String id) => '/api/user-stock/orders/$id';
  static String orderCalls(String id) => '/api/user-stock/orders/$id/calls';

  // ---- Sales ----
  static const sales = '/api/user-stock/sales';
  static const salesStats = '/api/user-stock/sales/stats';
  static String sale(String id) => '/api/user-stock/sales/$id';

  // ---- Purchases ----
  static const purchases = '/api/user-stock/purchases';
  static const purchasesStats = '/api/user-stock/purchases/stats';
  static String purchase(String id) => '/api/user-stock/purchases/$id';
  static String purchaseReceive(String id) =>
      '/api/user-stock/purchases/$id/receive';

  // ---- Clients & suppliers ----
  static const clients = '/api/user-stock/clients';
  static String client(String id) => '/api/user-stock/clients/$id';
  static String clientMetrics(String id) =>
      '/api/user-stock/clients/$id/metrics';
  static const suppliers = '/api/user-stock/suppliers';
  static String supplier(String id) => '/api/user-stock/suppliers/$id';

  // ---- Agents ----
  static const agents = '/api/user-stock/agents';
  static String agent(String id) => '/api/user-stock/agents/$id';
  static String agentTest(String id) => '/api/user-stock/agents/$id/test';
  static String agentMetrics(String id) => '/api/user-stock/agents/$id/metrics';
  static String agentInsights(String id) =>
      '/api/user-stock/agents/$id/insights';

  // ---- Notifications (brief Q7 — the API exists, mobile has never used it) ----
  static const notifications = '/api/user-stock/notifications';
  static const notificationsUnreadCount =
      '/api/user-stock/notifications/unread-count';
  static const notificationsReadAll = '/api/user-stock/notifications/read-all';
  static String notificationRead(String id) =>
      '/api/user-stock/notifications/$id/read';

  // ---- Delivery ----
  static const deliveryWilayas = '/api/user-stock/delivery/wilayas';
  static const deliveryFees = '/api/user-stock/delivery/fees';
  static const deliveryFeesQuote = '/api/user-stock/delivery/fees/quote';
  static String deliveryTrack(String orderId) =>
      '/api/user-stock/delivery/track/$orderId';
}
