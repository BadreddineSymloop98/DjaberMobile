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

  // ---- The first-run tutorial (brief §21.5) ----
  //
  // Reached only after account creation, and only until it is finished or
  // skipped. Not public: it needs a session, because its steps create real
  // records against it.

  /// `T1a`–`T1c` — the three intro pages, as one swipeable screen.
  static const tutorial = '/tutorial';

  /// `T2 — Mode stock`, step 1 of 4.
  static const tutorialMode = '/tutorial/mode';

  /// `T3 — Produit`, step 2 of 4.
  static const tutorialProduct = '/tutorial/product';

  /// `T4 — Agent IA`, step 3 of 4.
  static const tutorialAgent = '/tutorial/agent';

  /// `T5 — Connecter la page`, step 4 of 4.
  static const tutorialConnect = '/tutorial/connect';

  /// `T6 — Prêt`, the closing screen.
  static const tutorialReady = '/tutorial/ready';

  /// The tutorial's steps in order, which is what makes "how far did they
  /// get?" a question with an answer.
  ///
  /// Used two ways: the router resumes at the furthest step a merchant
  /// reached, and `T6` compares against it to decide which lines of its recap
  /// are genuinely done. The intro is first because a merchant who has only
  /// seen it has completed nothing.
  static const tutorialFlow = <String>[
    tutorial,
    tutorialMode,
    tutorialProduct,
    tutorialAgent,
    tutorialConnect,
    tutorialReady,
  ];

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

  /// `17 — Produits` — the catalogue. Pushed over the shell rather than
  /// living in it: the bottom nav's Stock tab is `16 — Aperçu du stock`, which
  /// is still unbuilt, and this is reached from the drawer and from home.
  static const products = '/products';

  /// `14 — Agents IA` — the merchant's agent. Reached from home's action
  /// card and the drawer, like [products].
  static const agents = '/agents';

  /// `15 — Agents · démarrer` — ready-made agents, or start from scratch.
  /// **Declared before [agent] in the router**, which would otherwise read
  /// `new` as an agent id.
  static const agentNew = '/agents/new';

  /// "Partir de zéro": name, personality, instructions.
  static const agentNewScratch = '/agents/new/scratch';

  /// An agent's details, KPIs and instructions — the web's
  /// `/dashboard/agents/{id}`. Pushed over [agents].
  static const agent = '/agents/:id';
  static String agentOf(String id) => '/agents/$id';

  /// Its sandbox test chat. Pushed over [agents].
  static const agentTest = '/agents/:id/test';
  static String agentTestOf(String id) => '/agents/$id/test';

  /// `15c — Modifier l'agent`: the full agent form, filled. Pushed over
  /// [agent], whose *Modifier l'agent* button opens it, as the web's details
  /// page does.
  static const agentEdit = '/agents/:id/edit';
  static String agentEditOf(String id) => '/agents/$id/edit';

  /// `12 — Pages connectées` (`13 — Connecter une page` when there are none).
  /// Reached from home and from the drawer's *Réseaux sociaux*.
  static const pages = '/pages';

  /// `18 — Ajouter un produit`.
  ///
  /// **Must be declared before [product] in the router.** go_router matches in
  /// declaration order, so `/products/:id` would otherwise swallow this with
  /// `id == 'new'`.
  static const productNew = '/products/new';

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
