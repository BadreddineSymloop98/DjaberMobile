// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class L10nEn extends L10n {
  L10nEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Djaber.ai';

  @override
  String get appTagline => 'Social AI Agent';

  @override
  String get commonBack => 'Back';

  @override
  String get commonDismiss => 'Dismiss';

  @override
  String get commonCancel => 'Cancel';

  @override
  String get commonSave => 'Save';

  @override
  String get commonRetry => 'Retry';

  @override
  String get commonDelete => 'Delete';

  @override
  String get commonConfirm => 'Confirm';

  @override
  String get commonSearch => 'Search';

  @override
  String get commonLoading => 'Loading…';

  @override
  String get commonSeeAll => 'See all';

  @override
  String get commonEmpty => 'Nothing here';

  @override
  String get commonNext => 'Next';

  @override
  String get commonSkip => 'Skip';

  @override
  String get commonStart => 'Get started';

  @override
  String get onboardingAnswersTitle => 'The agent replies to your customers';

  @override
  String get onboardingAnswersBody =>
      'It knows your catalogue, your stock and your prices. It answers Facebook and Instagram messages for you, day and night.';

  @override
  String get onboardingEscalationTitle => 'You step in when it is needed';

  @override
  String get onboardingEscalationBody =>
      'When the AI can no longer follow, it stops and tells you. You reply from your phone, then hand the conversation back to it.';

  @override
  String get onboardingStockTitle => 'Your stock in your pocket';

  @override
  String get onboardingStockBody =>
      'Products, purchases, sales and orders. Check a quantity while the customer waits, and correct it on the spot.';

  @override
  String get onboardingSampleCustomer => 'Amina B.';

  @override
  String get onboardingSampleMessage => 'Is the black one available in M?';

  @override
  String get onboardingSampleReply =>
      'Yes — 4 left in M. Delivery to Oran is 600 DA.';

  @override
  String get onboardingSampleEscalation =>
      'The customer is asking for a refund.';

  @override
  String get onboardingSampleNeedsHuman => 'Needs you';

  @override
  String get onboardingSampleHandling => 'Agent handling';

  @override
  String get onboardingShortcutProducts => 'Products';

  @override
  String get onboardingShortcutOrders => 'Orders';

  @override
  String get onboardingShortcutMovements => 'Movements';

  @override
  String get errorNetwork => 'No connection. Check your network and try again.';

  @override
  String get errorTimeout => 'The request took too long.';

  @override
  String get errorUnauthorized => 'Your session expired. Sign in again.';

  @override
  String get errorServer => 'Something went wrong on our side.';

  @override
  String get toastProductCreated => 'Product created';

  @override
  String get toastAgentCreated => 'AI agent created';

  @override
  String get toastPageConnected => 'Page connected';

  @override
  String get errorGeneric => 'Something went wrong. Please try again.';

  @override
  String get langEnglish => 'English';

  @override
  String get langFrench => 'Français';

  @override
  String get langArabic => 'العربية';

  @override
  String get obStockValue => '1.24';

  @override
  String get obStockValueUnit => 'M DA';

  @override
  String get obStockValueLabel => 'Stock value';

  @override
  String get obKpiProducts => 'Products';

  @override
  String get obKpiProductsValue => '128';

  @override
  String get obKpiPurchases => 'Purchases';

  @override
  String get obKpiPurchasesValue => '6';

  @override
  String get obKpiSales => 'Sales';

  @override
  String get obKpiSalesValue => '24';

  @override
  String get obKpiOrders => 'Ord';

  @override
  String get obKpiOrdersValue => '12';

  @override
  String get obInStock => 'In stock';

  @override
  String get obStockRow1Name => 'Satin dress — Black — M';

  @override
  String get obStockRow1Meta => 'Threshold 5 · Out of stock';

  @override
  String get obStockRow1Qty => '0';

  @override
  String get obStockRow2Name => 'Oud perfume 50 ml';

  @override
  String get obStockRow2Meta => 'Threshold 10';

  @override
  String get obStockRow2Qty => '3';

  @override
  String get obStockRow3Name => 'Leather bag — Camel';

  @override
  String get obStockRow3Meta => 'Threshold 5';

  @override
  String get obStockRow3Qty => '7';

  @override
  String get obEsc1Kind => 'AI stuck';

  @override
  String get obEsc1Time => '2 min';

  @override
  String get obEsc1Name => 'Amina B.';

  @override
  String get obEsc1Body => 'She wants to change the size — order already paid.';

  @override
  String get obEsc2Kind => 'Order to approve';

  @override
  String get obEsc2Time => '18 min';

  @override
  String get obEsc2Name => '#1042 — Bab Ezzouar';

  @override
  String get obEsc2Body => '2400 DA · created by the AI';

  @override
  String get obEsc3Kind => 'Out of stock';

  @override
  String get obEsc3Time => '1 h';

  @override
  String get obEsc3Name => 'Satin dress — Black — M';

  @override
  String get obEsc3Body => '0 in stock · 3 orders waiting';

  @override
  String get obEsc4Kind => 'Negotiation';

  @override
  String get obEsc4Time => '3 h';

  @override
  String get obEsc4Name => 'Sofiane K.';

  @override
  String get obEsc4Body => 'ndir lik 2 000 DA w nakhdo';

  @override
  String get authLoginTitle => 'Sign in';

  @override
  String get authLoginSubtitle => 'Sign in to your account to continue';

  @override
  String get authSignupTitle => 'Create account';

  @override
  String get authSignupSubtitle => 'Get started in less than a minute';

  @override
  String get authEmail => 'Email';

  @override
  String get authPassword => 'Password';

  @override
  String get authFirstName => 'First name';

  @override
  String get authLastName => 'Last name';

  @override
  String get authPasswordHint => 'At least 8 characters';

  @override
  String get authRemember => 'Remember me';

  @override
  String get authLoginSubmit => 'Sign In';

  @override
  String get authSignupSubmit => 'Create account';

  @override
  String get authForgot => 'Forgot your password?';

  @override
  String get authNoAccount => 'Don’t have an account?';

  @override
  String get authSignupLink => 'Get started';

  @override
  String get authHaveAccount => 'Already have an account?';

  @override
  String get authSigninLink => 'Sign In';

  @override
  String get authEmailPlaceholder => 'you@example.com';

  @override
  String get authFirstNamePlaceholder => 'Jane';

  @override
  String get authLastNamePlaceholder => 'Doe';

  @override
  String get authErrEmailRequired => 'Email is required';

  @override
  String get authErrInvalidEmail => 'Please enter a valid email address';

  @override
  String get authErrPasswordRequired => 'Password is required';

  @override
  String get authErrPasswordTooShort =>
      'Password must be at least 8 characters';

  @override
  String get authErrFirstNameRequired => 'First name is required';

  @override
  String get authErrLastNameRequired => 'Last name is required';

  @override
  String get authForgotBack => 'Back to Login';

  @override
  String get authForgotTitle => 'Forgot Password?';

  @override
  String get authForgotSubtitle => 'Enter your email to receive a reset link';

  @override
  String get authForgotEmail => 'Email Address';

  @override
  String get authForgotEmailPlaceholder => 'you@company.com';

  @override
  String get authForgotSubmit => 'Send Reset Link';

  @override
  String get authForgotSecure =>
      'Your password reset link is encrypted and expires in 1 hour';

  @override
  String get authForgotRemember => 'Remember your password?';

  @override
  String get authSentTitle => 'Check Your Email';

  @override
  String get authSentMessage => 'We’ve sent a password reset link to';

  @override
  String get authSentNoReceive => 'Didn’t receive the email?';

  @override
  String get authSentTryAnother => 'Try another email address';

  @override
  String get menuOverview => 'Overview';

  @override
  String get menuInbox => 'Inbox';

  @override
  String get menuSocial => 'Social Media';

  @override
  String get menuServices => 'Services';

  @override
  String get menuProducts => 'Products';

  @override
  String get menuAgents => 'Agents';

  @override
  String get menuCommercial => 'Commercial';

  @override
  String get menuSoon => 'Soon';

  @override
  String get menuNotifications => 'Notifications';

  @override
  String get menuAnalytics => 'Analytics';

  @override
  String get menuReports => 'Reports';

  @override
  String get menuSettings => 'Settings';

  @override
  String get menuWebOnly => 'on the web';

  @override
  String get tutorialStepAlreadyDone => 'Already done — moving on';

  @override
  String get exitHint => 'Tap back again to leave';

  @override
  String get menuPages => 'Pages';

  @override
  String get menuPlan => 'Your Plan';

  @override
  String get menuPlanUnknown => '—';

  @override
  String get menuSignOut => 'Sign out';

  @override
  String get tutorialStepMode => 'Choose your stock mode';

  @override
  String get tutorialStepProduct => 'Create your first product';

  @override
  String get tutorialStepAgent => 'Create your AI agent';

  @override
  String get tutorialStepPage => 'Connect your page';

  @override
  String get tutorialWelcomeTitle => 'Welcome to Djaber.ai';

  @override
  String get tutorialWelcomeBody =>
      'Let\'s get your shop running together. Four steps, and your agent starts answering your customers.';

  @override
  String get tutorialStockTitle => 'First, your stock';

  @override
  String get tutorialStockBody =>
      'You choose how to manage your stock, then you create your first product — name, price, quantity.';

  @override
  String get tutorialAgentTitle => 'Then your agent';

  @override
  String get tutorialAgentBody =>
      'Create it in three fields, connect your Facebook page, and it answers from the first question on.';

  @override
  String get commonContinue => 'Continue';

  @override
  String get commonActive => 'ACTIVE';

  @override
  String tutorialStepCounter(int step, int total) {
    return 'STEP $step OF $total';
  }

  @override
  String get tutorialModeTitle => 'How do you manage your stock?';

  @override
  String get tutorialModeSubtitle =>
      'This choice decides what you see in the app. You can change it at any time in settings.';

  @override
  String get stockModeSimple => 'Simple';

  @override
  String get stockModeAdvanced => 'Advanced';

  @override
  String get stockModeSimpleDesc =>
      'Products, Categories & Orders — manage your inventory and orders without the complexity.';

  @override
  String get stockModeAdvancedDesc =>
      'Full suite — Suppliers, Clients, Sales, Purchases, Caisse, Movements, Delivery & more.';

  @override
  String get tutorialProductTitle => 'Your first product';

  @override
  String get tutorialProductSubtitle =>
      'This is what your agent will sell. The description is what it reads to answer customers.';

  @override
  String get tutorialProductSubmit => 'Create the product';

  @override
  String get productName => 'Name';

  @override
  String get productNamePlaceholder => 'Satin dress — Black';

  @override
  String get productSku => 'Reference (SKU)';

  @override
  String get productSkuPlaceholder => 'PRD-001';

  @override
  String get productDescription => 'Description';

  @override
  String get productDescriptionPlaceholder =>
      'Describe the product — the agent uses this to sell it';

  @override
  String get productCostPrice => 'Cost price (DA)';

  @override
  String get productSellingPrice => 'Selling price (DA)';

  @override
  String get productQuantity => 'Initial quantity';

  @override
  String get productErrRequired => 'This field is required';

  @override
  String get productErrNotANumber => 'Enter a number';

  @override
  String get productErrMustBePositive => 'Must be greater than 0';

  @override
  String get productErrBelowCost =>
      'Must be greater than or equal to the cost price';

  @override
  String get productsEyebrow => 'CATALOGUE';

  @override
  String get productsTitle => 'Products';

  @override
  String productsSummary(int count, String value) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count products',
      one: '1 product',
      zero: 'No products yet',
    );
    return 'What your agent sells. $_temp0, $value of stock value.';
  }

  @override
  String get productsSearchLabel => 'SEARCH';

  @override
  String get productsSearchPlaceholder => 'Search products…';

  @override
  String get productsFilterAll => 'All';

  @override
  String get productsFilterLowStock => 'Low stock';

  @override
  String get productsSectionAll => 'ALL PRODUCTS';

  @override
  String get productsSectionLowStock => 'LOW STOCK';

  @override
  String get productsInStock => 'IN STOCK';

  @override
  String get productsOutOfStock => 'OUT OF STOCK';

  @override
  String productsThreshold(int count) {
    return 'THRESHOLD $count';
  }

  @override
  String get productsEmptyTitle => 'No products yet';

  @override
  String get productsEmptyBody =>
      'Add your first product and your agent will be able to sell it.';

  @override
  String get productsNoMatchTitle => 'Nothing matches';

  @override
  String get productsNoMatchBody => 'Try another word, or clear the filter.';

  @override
  String get productsAdd => 'Add Product';

  @override
  String get productAddTitle => 'Add Product';

  @override
  String get productAlertThreshold => 'Alert threshold';

  @override
  String get productAlertThresholdHint => 'Leave empty for no alert';

  @override
  String get productCategory => 'Category';

  @override
  String get productCategoryNone => 'No category';

  @override
  String get productUnit => 'Unit';

  @override
  String get productUnitNone => 'Select unit';

  @override
  String get productPhotos => 'Add photos';

  @override
  String get productPhotosHint => 'JPEG, PNG, WEBP · 5MB MAX';

  @override
  String get productHasVariants => 'This product has variants';

  @override
  String get productHasVariantsHint =>
      'Sizes or colours — the quantity is set per variant';

  @override
  String get productAddSubmit => 'Create product';

  @override
  String productsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count products',
      one: '1 product',
      zero: 'No products',
    );
    return '$_temp0';
  }

  @override
  String get productPhotosSoon => 'Photos can be added from the web for now';

  @override
  String get productPhotosTooLarge => 'Photos over 5 MB were not added.';

  @override
  String get productPhotosWrongType =>
      'Only JPEG, PNG, WEBP or GIF photos can be added.';

  @override
  String get productPhotosTooMany => 'Up to 10 photos per product.';

  @override
  String get productPhotosUploadFailed =>
      'Product created, but its photos could not be uploaded.';

  @override
  String get productPhotoRemove => 'Remove photo';

  @override
  String get productPhotoCamera => 'Take a photo';

  @override
  String get productPhotoGallery => 'Choose from gallery';

  @override
  String get tutorialAgentSubtitle =>
      'It answers your customers with your catalogue and your prices. Three fields are enough — everything else can be tuned later.';

  @override
  String get tutorialAgentSubmit => 'Create the agent';

  @override
  String get agentName => 'Agent name';

  @override
  String get agentNamePlaceholder => 'e.g. Sales assistant';

  @override
  String get agentPersonality => 'Personality';

  @override
  String get agentToneProfessional => 'Professional';

  @override
  String get agentToneProfessionalDesc => 'Formal and business-oriented';

  @override
  String get agentToneFriendly => 'Friendly';

  @override
  String get agentToneFriendlyDesc => 'Warm and approachable';

  @override
  String get agentToneCasual => 'Casual';

  @override
  String get agentToneCasualDesc => 'Relaxed and conversational';

  @override
  String get agentToneTechnical => 'Technical';

  @override
  String get agentToneTechnicalDesc => 'Detailed and precise';

  @override
  String get agentInstructions => 'Instructions';

  @override
  String get agentInstructionsPlaceholder =>
      'How it should answer, and when to hand over to you';

  @override
  String get tutorialConnectTitle => 'Connect your page';

  @override
  String get tutorialConnectSubtitle =>
      'This is the last step. Your agent answers in that page\'s inbox — the moment it is connected, it is working.';

  @override
  String get connectPermissionsHeading => 'Facebook will ask you for';

  @override
  String get connectPermissionPages => 'See the list of your pages';

  @override
  String get connectPermissionMessages => 'Read and send the page\'s messages';

  @override
  String get connectPermissionInfo => 'Access the page\'s information';

  @override
  String get connectFacebook => 'Connect Facebook';

  @override
  String get connectInstagram => 'Connect Instagram';

  @override
  String get oauthLoading => 'Loading Facebook…';

  @override
  String get oauthLoadingHint => 'Facebook\'s authorisation page appears here.';

  @override
  String get connectLater => 'Connect later';

  @override
  String get oauthDenied =>
      'Authorisation cancelled. You can try again whenever you like.';

  @override
  String get connectFailed =>
      'Your page could not be connected. Try again, or connect it later.';

  @override
  String get connectNothingNew =>
      'No new page came through. Make sure you pick a page when asked, then try again.';

  @override
  String get connectLinkFailed =>
      'Page connected, but not yet linked to your agent. You can link it from your agent\'s settings.';

  @override
  String get tutorialReadyTitle => 'Your agent is live';

  @override
  String get tutorialReadySubtitle =>
      'It is already answering your page\'s messages, with your catalogue and your prices. Add more products whenever you like.';

  @override
  String get tutorialReadyTitlePending => 'Almost there';

  @override
  String get tutorialReadySubtitlePending =>
      'Your catalogue and your agent are ready. All that is left is connecting your page — your agent starts answering the moment it is.';

  @override
  String get tutorialReadySubmit => 'Open the app';

  @override
  String get tutorialReadyModeSimple =>
      'Simple — products, categories and orders';

  @override
  String get tutorialReadyModeAdvanced => 'Advanced — the full suite';

  @override
  String get homeGreetingMorning => 'Good morning';

  @override
  String get homeGreetingAfternoon => 'Good afternoon';

  @override
  String get homeGreetingEvening => 'Good evening';

  @override
  String get homeSnapshot => 'here is a snapshot';

  @override
  String get homeQueue => 'To handle';

  @override
  String get homeQueueStuck => 'AI stuck';

  @override
  String get homeQueueEmpty =>
      'Nothing waiting. The agent is handling every conversation.';

  @override
  String get homeQueueNoPage =>
      'No page connected, so no conversation can reach you yet.';

  @override
  String homeQueueMore(int count) {
    return '+ $count more';
  }

  @override
  String homeAgeMinutes(int count) {
    return '$count MIN';
  }

  @override
  String homeAgeHours(int count) {
    return '$count H';
  }

  @override
  String homeAgeDays(int count) {
    return '$count D';
  }

  @override
  String get homeNoPageTitle => 'No page connected';

  @override
  String get homeNoPageBody =>
      'Your agent has nowhere to answer yet. Connect your Facebook or Instagram page and it starts working on the first message.';

  @override
  String get homeOverview => 'Overview';

  @override
  String get homeKpiPages => 'Connected pages';

  @override
  String get homeKpiProducts => 'Products';

  @override
  String homeKpiLowStock(int count) {
    return '$count low stock';
  }

  @override
  String get homeKpiRevenue => 'Revenue (30d)';

  @override
  String homeKpiSales(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count sales',
      one: '$count sale',
    );
    return '$_temp0';
  }

  @override
  String get homeKpiStockValue => 'Stock value';

  @override
  String get homeQuickActions => 'Quick actions';

  @override
  String get homeActionConnectTitle => 'Connect a page';

  @override
  String get homeActionConnectBody => 'Link your Facebook page';

  @override
  String get homeActionProductsTitle => 'Add products';

  @override
  String get homeActionProductsBody => 'Build your catalogue';

  @override
  String get homeActionAgentsTitle => 'AI agents';

  @override
  String get homeActionAgentsBody => 'Manage your assistants';

  @override
  String get homeYourPages => 'Your pages';

  @override
  String get homeManageAll => 'MANAGE ALL →';

  @override
  String get homePagesEmpty => 'No page connected yet.';

  @override
  String get homePageActive => 'ACTIVE';

  @override
  String get homePageInactive => 'PAUSED';

  @override
  String homePageConnectedOn(DateTime date) {
    final intl.DateFormat dateDateFormat = intl.DateFormat.MMMMd(localeName);
    final String dateString = dateDateFormat.format(date);

    return 'CONNECTED $dateString';
  }

  @override
  String get platformFacebook => 'Facebook';

  @override
  String get platformInstagram => 'Instagram';

  @override
  String get homeGetStarted => 'Get started';

  @override
  String get homeStepConnectTitle => 'Connect a page';

  @override
  String get homeStepConnectBody => 'Link Facebook to start chatting';

  @override
  String get homeStepProductsTitle => 'Add products';

  @override
  String get homeStepProductsBody => 'Build up your catalogue';

  @override
  String get homeStepAgentTitle => 'Configure your AI agent';

  @override
  String get homeStepAgentBody => 'Set the tone and the behaviour';

  @override
  String get homeStepSaleTitle => 'Make your first sale';

  @override
  String get homeStepSaleBody => 'Watch the AI handle the requests';

  @override
  String get navHome => 'HOME';

  @override
  String get navQueue => 'QUEUE';

  @override
  String get navInbox => 'INBOX';

  @override
  String get navStock => 'STOCK';

  @override
  String get navOrders => 'ORD';

  @override
  String get commonNotBuilt => 'not built yet';

  @override
  String get agentsTitle => 'AI Agents';

  @override
  String get agentsSubtitle =>
      'Create and manage AI agents that sell your products on connected pages';

  @override
  String get agentsActive => 'AI active';

  @override
  String get agentsInactive => 'AI paused';

  @override
  String get agentsStatPages => 'Pages';

  @override
  String get agentsStatProducts => 'Products';

  @override
  String get agentsStatModel => 'Model';

  @override
  String get agentsAllProducts => 'All';

  @override
  String get agentsNoPages => 'Not answering on any page yet';

  @override
  String get agentsPause => 'Pause the agent';

  @override
  String get agentsResume => 'Resume the agent';

  @override
  String get agentsPausedToast => 'Agent paused — it no longer replies';

  @override
  String get agentsResumedToast => 'Agent active — it replies again';

  @override
  String get agentsEmptyTitle => 'No agent yet';

  @override
  String get agentsEmptyBody =>
      'Create an AI agent to automatically respond to messages on your connected pages and sell your products.';

  @override
  String get agentsEmptyCta => 'Create your agent';

  @override
  String get agentsActionInsights => 'Issues to review';

  @override
  String get agentsActionTest => 'Test the agent';

  @override
  String get agentsActionDetails => 'Details and stats';

  @override
  String get agentsActionDelete => 'Delete the agent';

  @override
  String get agentsDeleteTitle => 'Delete the agent?';

  @override
  String agentsDeleteBody(String name) {
    return '$name will be deleted and will stop replying on your pages. You can create a new agent afterwards.';
  }

  @override
  String get agentsDeleteConfirm => 'Delete';

  @override
  String get agentsDeletedToast => 'Agent deleted';

  @override
  String get agentsInsightsTitle => 'Pending issues';

  @override
  String get agentsInsightsEmpty =>
      'No pending issues — your agent is handling everything.';

  @override
  String get agentsInsightsNone => 'Nothing here.';

  @override
  String get agentsInsightUnclear => 'Unclear';

  @override
  String get agentsInsightUnknown => 'Unknown topic';

  @override
  String get agentsInsightHandoff => 'Handed to you';

  @override
  String get agentsInsightCustomer => 'Customer';

  @override
  String get agentsInsightAgent => 'AI response';

  @override
  String get agentsInsightResolve => 'Resolve';

  @override
  String get agentsInsightDismiss => 'Dismiss';

  @override
  String get agentsInsightAddAndResolve => 'Add and resolve';

  @override
  String get agentsInsightInstructionHint =>
      'Add an instruction so the agent handles this better next time…';

  @override
  String get agentsInsightResolved => 'Resolved';

  @override
  String get agentsInsightDismissed => 'Dismissed';

  @override
  String get agentsInsightPending => 'Pending';

  @override
  String get agentsInsightFailed => 'The issue could not be updated.';

  @override
  String agentsTestTitle(String name) {
    return 'Test — $name';
  }

  @override
  String get agentsTestEmpty => 'Send a message to test';

  @override
  String get agentsTestNote => 'A dry run: no credits used, no orders created.';

  @override
  String get agentsTestPlaceholder => 'Type a message…';

  @override
  String get agentsTestSend => 'Send';

  @override
  String get agentsTestFailed => 'No reply — try again.';

  @override
  String get agentsDetailsConversations => 'Conversations';

  @override
  String agentsDetailsConversationsFoot(int received, int sent) {
    return '$received received · $sent sent';
  }

  @override
  String get agentsDetailsMessages => 'Messages';

  @override
  String agentsDetailsLastActive(String date) {
    return 'Last: $date';
  }

  @override
  String get agentsDetailsNoActivity => 'No activity yet';

  @override
  String get agentsDetailsOrders => 'Orders created';

  @override
  String agentsDetailsResolvedFoot(int count) {
    return '$count resolved';
  }

  @override
  String get agentsDetailsInsights => 'Agent insights';

  @override
  String get agentsDetailsAll => 'All';

  @override
  String get agentsDetailsInstructions => 'Custom instructions';

  @override
  String get agentsDetailsNoInstructions => 'No instructions yet.';

  @override
  String get agentsDetailsEdit => 'Edit';

  @override
  String get agentsDetailsSave => 'Save';

  @override
  String get agentsDetailsSaved => 'Instructions saved';

  @override
  String get agentsDetailsSavedMerged =>
      'Instructions saved — lines added on the web were kept';

  @override
  String get agentsDetailsConflictTitle => 'Changed on the web';

  @override
  String get agentsDetailsConflictBody =>
      'These instructions were changed while you were editing. The current version:';

  @override
  String get agentsDetailsUseLatest => 'Use this version';

  @override
  String get agentsDetailsKeepMine => 'Replace with mine';

  @override
  String get agentsNotFound => 'Agent not found.';

  @override
  String agentsTestEmptyFor(String name) {
    return 'Send a message to test $name';
  }

  @override
  String get agentsTestProduct => 'Product';

  @override
  String agentsTestProductId(String id) {
    return 'ID: $id…';
  }

  @override
  String get agentsPresetsTitle => 'Start with a ready-made agent';

  @override
  String get agentsPresetsBody =>
      'Each one is fully configured for Algerian selling — Darija, Arabic and French, delivery quoting, and order handling. Pick one to launch in seconds, then fine-tune anything.';

  @override
  String get agentsPresetVisionVoice => 'VISION + VOICE';

  @override
  String get agentsPresetVoice => 'VOICE';

  @override
  String get agentsPresetCloserTagline =>
      'Turns conversations into confirmed orders';

  @override
  String get agentsPresetCloser1 =>
      'Guides the customer from question to confirmed order';

  @override
  String get agentsPresetCloser2 =>
      'Quotes delivery per wilaya and closes with the full total';

  @override
  String get agentsPresetCloser3 => 'Understands photos and voice notes';

  @override
  String get agentsPresetSupportTagline =>
      'Answers fast, escalates problems to you';

  @override
  String get agentsPresetSupport1 =>
      'Handles product and order questions politely';

  @override
  String get agentsPresetSupport2 =>
      'Escalates complaints and refunds to a human';

  @override
  String get agentsPresetSupport3 => 'Calm, accurate, and to the point';

  @override
  String get agentsPresetAdvisorTagline =>
      'Helps customers pick the right product';

  @override
  String get agentsPresetAdvisor1 =>
      'Compares options and explains differences';

  @override
  String get agentsPresetAdvisor2 => 'Matches a customer photo to your catalog';

  @override
  String get agentsPresetAdvisor3 =>
      'Great for catalogs with variants and specs';

  @override
  String get agentsPresetExpressTagline =>
      'Ultra-fast replies for high message volume';

  @override
  String get agentsPresetExpress1 => 'Short, quick answers for busy pages';

  @override
  String get agentsPresetExpress2 => 'Lowest credit use — text and voice only';

  @override
  String get agentsPresetExpress3 => 'Still places and cancels orders';

  @override
  String get agentsPresetUse => 'Use this agent  →';

  @override
  String get agentsPresetOwn => 'Prefer to build your own?';

  @override
  String get agentsPresetScratch => 'Start from scratch';

  @override
  String get agentsCreatedToast => 'Agent created';

  @override
  String get agentFormSubtitle =>
      'Set up an agent to answer your conversations. Only the name is required — everything else has a default.';

  @override
  String get agentFormBasics => 'Basic information';

  @override
  String get agentFormDescription => 'Description';

  @override
  String get agentFormDescriptionPlaceholder =>
      'Briefly describe what this agent does…';

  @override
  String get agentFormInstructions => 'Custom instructions';

  @override
  String get agentFormInstructionsPlaceholder =>
      'How to respond, what to avoid, how to handle certain cases…';

  @override
  String get agentFormInstructionsHint =>
      'These instructions guide the agent’s behavior in conversations.';

  @override
  String get agentFormAdvanced => 'Advanced settings';

  @override
  String get agentFormAdvancedHint => 'Optional — sensible defaults apply.';

  @override
  String get agentFormBehavior => 'Behavior';

  @override
  String get agentFormBehaviorSummary => 'Closing · Human handoff';

  @override
  String get agentFormClosing => 'Conversation closing';

  @override
  String get agentFormClosingPlaceholder =>
      'Examples:\n• After an order: “Thank you! Your order is on its way.”\n• Customer says bye: “Thanks for chatting, come back anytime!”\n• Angry customer: “Sorry — let me get a human to help you.”';

  @override
  String get agentFormClosingHint =>
      'When and how the AI closes conversations. If empty, it uses sensible defaults (thanks after an order, answers goodbyes).';

  @override
  String get agentFormHandoff => 'Human intervention rules';

  @override
  String get agentFormHandoffPlaceholder =>
      'Examples:\n• Refund or return → stop the AI, notify me\n• Discount request → let me handle it\n• Complaint → transfer the conversation to me';

  @override
  String get agentFormHandoffHint =>
      'When the AI should stop and let a human take over. Normal greetings (slm, cava, hi) are always handled by the AI.';

  @override
  String get agentFormDisplay => 'Product display';

  @override
  String get agentFormDisplayDefault => 'Default style';

  @override
  String get agentFormDisplayCustom => 'Custom';

  @override
  String get agentFormDisplayHint =>
      'How the AI presents products. Tap a tag to insert it — the AI fills in real product data.';

  @override
  String get agentFormTemplate => 'Template';

  @override
  String get agentFormTemplatePlaceholder => 'Tap the tags above or type here…';

  @override
  String get agentFormTagCard => 'Product card';

  @override
  String get agentFormTagName => 'Name';

  @override
  String get agentFormTagPrice => 'Price (DA)';

  @override
  String get agentFormTagDescription => 'Description';

  @override
  String get agentFormTagStock => 'Stock qty';

  @override
  String get agentFormTagNewLine => '↵ New line';

  @override
  String get agentFormPreview => 'Preview';

  @override
  String get agentFormPreviewLive => 'Live preview';

  @override
  String get agentFormPreviewCustomer => 'Show me your products';

  @override
  String get agentFormPreviewDefault =>
      'Here’s what we have!\n[PRODUCT_CARD]\nWould you like to order?';

  @override
  String get agentFormPreviewSampleName => 'Sample product';

  @override
  String get agentFormPreviewSampleDescription => 'A great product';

  @override
  String get agentFormModel => 'AI model';

  @override
  String agentFormModelSummary(String model, String temperature, int tokens) {
    return '$model · $temperature · $tokens tokens';
  }

  @override
  String get agentFormModelPicker => 'Model';

  @override
  String agentFormModelCost(String usd) {
    return '≈ $usd / 1000 msgs';
  }

  @override
  String get agentFormModelsLoading => 'Loading available models…';

  @override
  String get agentFormModelsUnavailable =>
      'AI models are temporarily unavailable. Please try again later.';

  @override
  String get agentFormTraitBestQuality => 'Best quality';

  @override
  String get agentFormTraitFastAffordable => 'Fast & affordable';

  @override
  String get agentFormTraitLongContext128k => '128k context';

  @override
  String get agentFormTraitLegacyFast => 'Legacy, fast';

  @override
  String get agentFormTraitBestBalanced => 'Best balanced';

  @override
  String get agentFormTraitFastCheap => 'Fast & cheap';

  @override
  String get agentFormTraitMostCapable => 'Most capable';

  @override
  String get agentFormTraitLatestFast => 'Latest, fast';

  @override
  String get agentFormTraitLongContext1m => '1M context';

  @override
  String get agentFormTraitBestOpenSource => 'Best open-source';

  @override
  String get agentFormTraitUltraFast => 'Ultra fast';

  @override
  String get agentFormTraitMixtureOfExperts => 'MoE, 32k context';

  @override
  String get agentFormTraitReasoning => 'Reasoning model';

  @override
  String get agentFormTemperature => 'Temperature';

  @override
  String get agentFormPrecise => 'Precise';

  @override
  String get agentFormCreative => 'Creative';

  @override
  String get agentFormMaxTokens => 'Max tokens';

  @override
  String get agentFormMaxTokensHint => 'Maximum response length · 100 – 4096';

  @override
  String get agentFormImages => 'Image recognition';

  @override
  String get agentFormImagesHint =>
      'The AI sees customer photos and compares them with your products. 5 credits per image (vs 1 for text).';

  @override
  String get agentFormVoice => 'Voice notes';

  @override
  String get agentFormVoiceHint =>
      'The AI transcribes voice notes (AR, FR, EN, Darja). 3 credits per note. When off, the agent asks for a text instead.';

  @override
  String get agentFormDelay => 'Response delay';

  @override
  String agentFormDelayValue(int seconds) {
    return '$seconds s';
  }

  @override
  String get agentFormDelayMax => '10 s';

  @override
  String get agentFormDelayHint =>
      'Waits for more messages before replying — customers often send several short ones, and this combines them.';

  @override
  String get agentFormPages => 'Connected pages';

  @override
  String get agentFormPagesHint =>
      'The pages this agent answers on. Each page can only have one agent.';

  @override
  String agentFormPagesSummary(int selected, int total) {
    return '$selected of $total selected';
  }

  @override
  String agentFormPagesCount(int selected, int total) {
    return '$selected of $total';
  }

  @override
  String get agentFormPagesNone => 'No pages connected';

  @override
  String get agentFormPagesEmpty =>
      'No pages connected yet. Connect a Facebook or Instagram page first, then link it to this agent.';

  @override
  String agentFormPageTaken(String agent) {
    return 'Already on $agent';
  }

  @override
  String get agentFormPageActive => 'Active';

  @override
  String get agentFormPageInactive => 'Inactive';

  @override
  String get agentFormSelectAll => 'Select all';

  @override
  String get agentFormClear => 'Clear';

  @override
  String get agentFormProducts => 'Products';

  @override
  String get agentFormSellAll => 'Sell all products';

  @override
  String get agentFormSellAllHint =>
      'The agent knows your entire catalog. Turn off to choose.';

  @override
  String get agentFormProductsAll => 'All products';

  @override
  String agentFormProductsChosen(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count products chosen',
      one: '1 product chosen',
      zero: 'No product chosen',
    );
    return '$_temp0';
  }

  @override
  String get agentFormProductSearch => 'Search';

  @override
  String get agentFormProductSearchPlaceholder => 'Search products…';

  @override
  String get agentFormProductsNone => 'No products available';

  @override
  String get agentFormProductsNoMatch => 'No products match your search';

  @override
  String get agentsNewTitle => 'New agent';
}
