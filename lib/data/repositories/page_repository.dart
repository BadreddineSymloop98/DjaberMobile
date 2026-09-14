import '../../core/config/app_config.dart';
import '../../core/constants/api_endpoints.dart';
import '../../core/error/result.dart';
import '../../core/network/api_client.dart';
import '../models/connected_page.dart';

/// Connected Pages, against `/api/pages`.
class PageRepository {
  PageRepository({required ApiClient api}) : _api = api;

  final ApiClient _api;

  /// `GET /api/pages` → `{ pages: [...] }`.
  ///
  /// The access token is not in the response — the controller's own `select`
  /// leaves it out — so nothing on the device ever holds it.
  Future<Result<List<ConnectedPage>>> list() {
    return _api.get<List<ConnectedPage>>(
      Api.pages,
      parse: (json) {
        final map = json as Map<String, dynamic>;
        final rows = map['pages'];
        if (rows is! List) return const <ConnectedPage>[];
        return rows
            .whereType<Map<String, dynamic>>()
            .map(ConnectedPage.fromJson)
            .toList(growable: false);
      },
    );
  }

  /// Asks the backend where to send the merchant to grant access.
  ///
  /// `GET /api/pages/connect/{facebook|instagram}` → `{ authUrl }`. The URL is
  /// Meta's own OAuth dialog, carrying our app id, the scopes, and the user id
  /// as `state`. The app opens it in a web view; the redirect at the end goes
  /// to the **backend's** callback, which does the token exchange server-side.
  /// The device never sees a Meta token.
  Future<Result<String>> authUrlFor(PagePlatform platform) {
    return _api.get<String>(
      platform == PagePlatform.instagram
          ? Api.connectInstagram
          : Api.connectFacebook,
      parse: (json) => (json as Map<String, dynamic>)['authUrl'] as String,
    );
  }
}

/// Reads an OAuth web view's navigation and says what it means.
///
/// Pulled out of the screen because it is the one genuinely tricky part of the
/// flow and the only part worth testing: everything else is a web view doing
/// what a web view does.
///
/// **How the flow actually ends.** `pages.controller.ts` finishes the callback
/// by serving a page whose script does one of two things: `postMessage` to
/// `window.opener` and close — the browser-popup case — or, when there is no
/// opener, `window.location.replace(FRONTEND_URL + '/dashboard?section=pages')`.
/// A web view has no opener, so it takes the second branch and navigates to
/// the **web app's dashboard**, which is not somewhere a phone should end up.
///
/// So the app watches for our own callback path instead, which it knows
/// without knowing `FRONTEND_URL`, and treats the dashboard redirect as a
/// backstop.
class OAuthFlowReader {
  const OAuthFlowReader({String? backendBaseUrl})
      : _base = backendBaseUrl ?? AppConfig.apiBaseUrl;

  final String _base;

  /// Meta appends `?error=access_denied` when the merchant refuses or backs
  /// out of the dialog.
  static bool isDenial(String url) {
    final query = Uri.tryParse(url)?.queryParameters ?? const {};
    return query.containsKey('error') ||
        query.containsKey('error_code') ||
        query['error_reason'] != null;
  }

  /// True once the merchant has granted access and Meta has handed control
  /// back to our backend. The page that loads here is the backend's own
  /// closing page, not something the merchant should read.
  bool isCallback(String url) =>
      url.startsWith('$_base${Api.facebookCallbackPath}') ||
      url.startsWith('$_base${Api.instagramCallbackPath}');

  /// The backstop: the callback's fallback branch bounced us at the web app.
  /// Reaching this means the grant already succeeded.
  static bool isWebDashboard(String url) {
    final uri = Uri.tryParse(url);
    return uri != null && uri.path.startsWith('/dashboard');
  }

  /// What the web view should do about [url].
  OAuthStep read(String url) {
    if (isDenial(url)) return OAuthStep.denied;
    if (isCallback(url) || isWebDashboard(url)) return OAuthStep.finished;
    return OAuthStep.keepGoing;
  }
}

enum OAuthStep {
  /// Still inside Meta's dialog. Let the web view carry on.
  keepGoing,

  /// The merchant granted access; close the web view and refetch the pages.
  finished,

  /// The merchant refused or backed out.
  denied,
}
