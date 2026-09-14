import 'dart:convert';

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
/// **How the flow actually ends** — from `GET /api/pages/callback/facebook` in
/// the live API docs. Meta sends the web view to our backend's callback with
/// `?code=…`. That request *is* the connection: the backend exchanges the code
/// and saves the Page, and only then answers with an HTML page. That page's
/// script finds no `window.opener` — there never is one in a web view — and
/// does `location.replace(FRONTEND_URL + '/dashboard?section=pages')`.
///
/// So the callback must be **allowed to load**, and the flow ends on what
/// follows it: the dashboard redirect, or — where a web view does not surface
/// that redirect — the callback page finishing its load. Stopping the web view
/// at the callback itself cancels the one request that carries the code, and
/// nothing is ever saved. That was the bug this reader used to have.
class OAuthFlowReader {
  const OAuthFlowReader();

  /// Meta appends `?error=access_denied` when the merchant refuses or backs
  /// out of the dialog.
  static bool isDenial(String url) {
    final query = Uri.tryParse(url)?.queryParameters ?? const {};
    return query.containsKey('error') ||
        query.containsKey('error_code') ||
        query['error_reason'] != null;
  }

  /// True for our backend's callback — the request that saves the Page.
  ///
  /// **Matched on the path alone, deliberately.** The `redirect_uri` Meta sends
  /// the merchant back to is built server-side from `BACKEND_URL`, which the
  /// app cannot read, so it need not share a host with [AppConfig.apiBaseUrl].
  /// Pinning the host made the callback invisible whenever the two disagreed.
  ///
  /// Only Meta and our own backend take part in this flow, so a path this
  /// specific is identification enough without pinning the host.
  static bool isCallback(String url) {
    final path = Uri.tryParse(url)?.path;
    return path == Api.facebookCallbackPath ||
        path == Api.instagramCallbackPath;
  }

  /// Where the callback page sends the web view once the backend is done: the
  /// web app's dashboard. Reaching it means the callback has been answered.
  static bool isWebDashboard(String url) {
    final uri = Uri.tryParse(url);
    return uri != null && uri.path.startsWith('/dashboard');
  }

  /// What the backend's callback page reported, read from its HTML.
  ///
  /// The callback always answers `200` with a small page whose script carries
  /// the result — `{type: "facebook-oauth-success", pages: N}`,
  /// `{type: "instagram-oauth-success", username}`, or
  /// `{type: "…-oauth-error", error}` (`GET /api/pages/callback/*` in the live
  /// docs). The status cannot tell success from failure, so this is the only
  /// place a failure shows. Null when [html] is not that page.
  static OAuthCallbackReport? parseCallbackPage(String html) {
    final match =
        RegExp(r'var\s+payload\s*=\s*(\{.*?\})\s*;').firstMatch(html);
    if (match == null) return null;

    final Object? decoded;
    try {
      decoded = jsonDecode(match.group(1)!);
    } on FormatException {
      return null;
    }
    if (decoded is! Map<String, dynamic>) return null;

    final type = decoded['type'];
    if (type is! String) return null;
    if (type.endsWith('-oauth-success')) {
      final pages = decoded['pages'];
      final username = decoded['username'];
      return OAuthCallbackReport(
        succeeded: true,
        pageCount: pages is num ? pages.toInt() : null,
        username: username is String ? username : null,
      );
    }
    if (type.endsWith('-oauth-error')) {
      return OAuthCallbackReport(
        succeeded: false,
        reason: decoded['error']?.toString(),
      );
    }
    return null;
  }

  /// The string inside a `runJavaScriptReturningResult` answer.
  ///
  /// Android hands a string back JSON-encoded — quotes and escapes included —
  /// and iOS hands it back bare, so the same page reads differently per
  /// platform unless it is unwrapped first.
  static String unwrapJsString(Object? value) {
    if (value is! String) return '';
    if (value.length >= 2 && value.startsWith('"') && value.endsWith('"')) {
      try {
        final decoded = jsonDecode(value);
        if (decoded is String) return decoded;
      } on FormatException {
        // Not an encoded string after all — use it as it is.
      }
    }
    return value;
  }

  /// What the web view should do about [url].
  OAuthStep read(String url) {
    if (isDenial(url)) return OAuthStep.denied;
    if (isWebDashboard(url)) return OAuthStep.finished;
    if (isCallback(url)) return OAuthStep.callback;
    return OAuthStep.keepGoing;
  }
}

enum OAuthStep {
  /// Still inside Meta's dialog. Let the web view carry on.
  keepGoing,

  /// Our backend's callback, carrying the code. It **must** load — the backend
  /// saves the Page while answering it. Not the end of the flow yet.
  callback,

  /// The backend has answered the callback; close the web view and refetch
  /// the pages.
  finished,

  /// The merchant refused or backed out.
  denied,
}

/// The result the backend's callback page carried. See
/// [OAuthFlowReader.parseCallbackPage].
class OAuthCallbackReport {
  const OAuthCallbackReport({
    required this.succeeded,
    this.pageCount,
    this.username,
    this.reason,
  });

  final bool succeeded;

  /// Facebook: how many Pages the backend saved.
  final int? pageCount;

  /// Instagram: the account that was connected.
  final String? username;

  /// Why it failed, in the backend's own words. English and technical — for
  /// the log, not for the merchant.
  final String? reason;
}
