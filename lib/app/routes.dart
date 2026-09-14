/// Every route path in one place, so a deep link from a notification and a
/// `context.go` from a widget cannot drift apart.
///
/// Paths are flat and id-bearing on purpose: a push payload carries a
/// conversation id, and the notification tap has to reach that conversation
/// directly rather than dropping the merchant on home to hunt for it
/// (brief Q6). `PushMessage.route` builds strings that match these.
class Routes {
  const Routes._();

  // ---- Pre-auth ----
  static const splash = '/';
  static const onboarding = '/onboarding';
  static const login = '/login';
  static const signup = '/signup';
  static const forgotPassword = '/forgot-password';
  static const passwordSent = '/password-sent';

  /// The shell routes — the five bottom-nav destinations of brief §16:
  /// Accueil, File, Boîte, Stock, Commandes.
  static const home = '/home';
  static const queue = '/queue';
  static const inbox = '/inbox';
  static const stock = '/stock';
  static const orders = '/orders';

  // ---- Pushed on top of the shell ----
  static const conversation = '/conversation/:id';
  static String conversationOf(String id) => '/conversation/$id';

  static const product = '/products/:id';
  static String productOf(String id) => '/products/$id';

  static const order = '/orders/:id';
  static String orderOf(String id) => '/orders/$id';

  static const notifications = '/notifications';
  static const settings = '/settings';

  /// Paths reachable without a session. Everything else redirects to [login].
  static const publicPaths = <String>{
    splash,
    onboarding,
    login,
    signup,
    forgotPassword,
    passwordSent,
  };
}
