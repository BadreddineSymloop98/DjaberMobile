import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../../core/extensions/responsive_extension.dart';
import '../../../core/utils/logger.dart';
import '../../../data/models/connected_page.dart';
import '../../../data/repositories/page_repository.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../../viewmodels/session_view_model.dart';
import '../../widgets/app_icon.dart';

/// How the web view ended.
enum OAuthOutcome {
  /// Our backend answered the callback — it has handled the grant.
  granted,

  /// Meta granted, but our backend could not save the page — its callback page
  /// said so. [OAuthResult.report] carries why.
  failed,

  /// The merchant refused in Meta's dialog.
  denied,

  /// The merchant closed the web view themselves.
  ///
  /// A distinct outcome, not a failure: nothing went wrong, they changed their
  /// mind. This is the cancel path §21.10 lists as open — it is now answered
  /// here, by returning the merchant to `T5` with nothing said.
  dismissed,
}

/// What the web view hands back when it closes.
class OAuthResult {
  const OAuthResult(this.outcome, {this.report});

  final OAuthOutcome outcome;

  /// What the backend's callback page reported, when it could be read. Null
  /// on a refusal, a dismissal, or a close that came after the page was gone.
  final OAuthCallbackReport? report;
}

/// `T5b — Autorisation Facebook (web view)`.
///
/// The chrome around Meta's own authorisation page: a close control, the host
/// in an address pill, and a loading state. It deliberately does **not** mock
/// Facebook's page — that is Meta's, rendered live.
///
/// **Why a web view rather than an external browser.** The backend's callback
/// finishes by posting a message to `window.opener` and closing, or — with no
/// opener, which is every non-popup case — redirecting to the *web app's*
/// dashboard. Handing that to the system browser would strand the merchant on
/// a desktop web page with no way back into the app. Inside a web view the app
/// lets the callback load, stops the dashboard redirect that follows it, and
/// carries on.
///
/// The device never holds a Meta token: the `code` goes to our backend, which
/// exchanges it server-side.
class OAuthWebViewScreen extends StatefulWidget {
  const OAuthWebViewScreen({
    super.key,
    required this.authUrl,
    required this.platform,
    this.reader = const OAuthFlowReader(),
  });

  final String authUrl;
  final PagePlatform platform;

  /// Injected so a test can drive the URL rules without a web view.
  final OAuthFlowReader reader;

  @override
  State<OAuthWebViewScreen> createState() => _OAuthWebViewScreenState();
}

class _OAuthWebViewScreenState extends State<OAuthWebViewScreen> {
  late final WebViewController _controller;
  bool _loading = true;
  String _host = '';
  bool _finished = false;

  /// Held from [initState] because [dispose] cannot look anything up.
  late final SessionViewModel _session;

  @override
  void initState() {
    super.initState();
    // Leaving the app mid-login is normal here — Facebook sends a security
    // code by SMS, or asks for approval in its own app — and a splash replay
    // on return would drop this window and the login with it.
    _session = context.read<SessionViewModel>()..holdSplashReplay();
    _host = Uri.tryParse(widget.authUrl)?.host ?? '';
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      // The page behind the dialog is Meta's, on a black ground so the
      // transition from our chrome does not flash white.
      ..setBackgroundColor(AppColors.ink)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) {
            _onNavigated(url, loading: true);
            _readUrl(url);
          },
          onPageFinished: (url) {
            // The backend only answers the callback once it has done the work,
            // so the callback page finishing is a safe end — and the backstop
            // for a web view that never surfaces the redirect that follows.
            // The loading cover stays up, so that page is never seen.
            if (widget.reader.read(url) == OAuthStep.callback) {
              _finishGranted();
              return;
            }
            _onNavigated(url, loading: false);
            _readUrl(url);
          },
          // Server-side redirects do not reliably reach `onNavigationRequest`
          // — Meta ends the grant with a 302 chain, and a delegate that only
          // inspects navigation *requests* can miss every hop of it. This is
          // the signal that fires regardless.
          onUrlChange: (change) {
            final url = change.url;
            if (url != null) _readUrl(url);
          },
          onNavigationRequest: (request) {
            final step = widget.reader.read(request.url);
            // The callback is **let through**: it carries the code, and the
            // backend saves the Page while answering it. Preventing it here
            // was the bug — the code never left the phone.
            if (step == OAuthStep.keepGoing || step == OAuthStep.callback) {
              return NavigationDecision.navigate;
            }
            // A refusal carries no code, and the dashboard redirect only
            // happens after the backend has answered — stopping either loses
            // nothing, and the web app's page never renders.
            _end(step);
            return NavigationDecision.prevent;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.authUrl));
  }

  /// Ends the flow if [url] is the end of it.
  ///
  /// Called from every navigation signal the web view offers, not only
  /// `onNavigationRequest`, because a redirect that one does not surface would
  /// otherwise leave the merchant looking at a web view that never closed.
  /// [_finish] is idempotent, so several signals reporting the same URL cost
  /// nothing.
  ///
  /// The callback is deliberately **not** an end here: these signals fire
  /// while its request is still in flight, and closing then could abort it.
  void _readUrl(String url) {
    final step = widget.reader.read(url);
    if (step == OAuthStep.keepGoing || step == OAuthStep.callback) return;
    _end(step);
  }

  void _onNavigated(String url, {required bool loading}) {
    if (!mounted) return;
    setState(() {
      _loading = loading;
      _host = Uri.tryParse(url)?.host ?? _host;
    });
  }

  /// Pops once, whatever got us here — a granted flow can report from the
  /// dashboard request, a late `onPageStarted` and the callback's page-finished.
  void _finish(OAuthOutcome outcome, {OAuthCallbackReport? report}) {
    if (_finished || !mounted) return;
    _finished = true;
    Navigator.of(context).pop(OAuthResult(outcome, report: report));
  }

  /// Ends the flow for a terminal [step]: a refusal at once, a grant only
  /// after reading what the backend said about it.
  void _end(OAuthStep step) {
    if (step == OAuthStep.denied) {
      _finish(OAuthOutcome.denied);
    } else {
      _finishGranted();
    }
  }

  bool _reading = false;

  /// Reads the callback page's report, then closes as granted or failed.
  ///
  /// Reached while the callback page is still loaded — when its own load
  /// finishes, or when the dashboard redirect it starts is stopped — so the
  /// result inside its script can be read back. On a web view that only
  /// showed the redirect after it began, the page is already gone and the
  /// report is null; the connect step then decides from `GET /api/pages`.
  Future<void> _finishGranted() async {
    if (_finished || _reading) return;
    _reading = true;

    OAuthCallbackReport? report;
    try {
      final html = await _controller
          .runJavaScriptReturningResult('document.documentElement.outerHTML')
          .timeout(const Duration(seconds: 2));
      report = OAuthFlowReader.parseCallbackPage(
        OAuthFlowReader.unwrapJsString(html),
      );
    } on Exception catch (error) {
      Log.w('could not read the callback page: $error', tag: 'pages');
    }

    _finish(
      report == null || report.succeeded
          ? OAuthOutcome.granted
          : OAuthOutcome.failed,
      report: report,
    );
  }

  @override
  void dispose() {
    _session.releaseSplashReplay();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _finish(OAuthOutcome.dismissed);
      },
      child: Scaffold(
        backgroundColor: AppColors.ink,
        body: SafeArea(
          child: Column(
            children: [
              _Bar(
                host: _host,
                onClose: () => _finish(OAuthOutcome.dismissed),
              ),
              if (_loading) const _LoadingRule(),
              Expanded(
                child: Stack(
                  children: [
                    WebViewWidget(controller: _controller),
                    if (_loading)
                      ColoredBox(
                        color: AppColors.ink,
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                l10n.oauthLoading,
                                style: AppText.bodyS.copyWith(
                                  height: 1.32,
                                  color: AppColors.textMuted,
                                ),
                              ),
                              SizedBox(height: AppSpacing.md), // 12
                              Text(
                                l10n.oauthLoadingHint,
                                style: AppText.labelMeta,
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Close control, then the host in a pill — the frame's `Barre`.
class _Bar extends StatelessWidget {
  const _Bar({required this.host, required this.onClose});

  final String host;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.gutterTight, // 16
        vertical: AppSpacing.md, // 12
      ),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.rule)),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: onClose,
            behavior: HitTestBehavior.opaque,
            child: SizedBox.square(
              dimension: 6.15.w, // 24
              child: Center(
                child: AppIcon(
                  AppIcons.close,
                  size: 5.13.w, // 20
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ),
          SizedBox(width: AppSpacing.md), // 12
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: 2.56.w, // 10
                vertical: 1.54.w, // 6
              ),
              decoration: BoxDecoration(
                color: AppColors.surface,
                border: Border.all(
                  color: AppColors.rule,
                  width: AppStroke.hairline,
                ),
                borderRadius: BorderRadius.circular(AppRadius.card),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  AppIcon(AppIcons.globe, size: 3.08.w), // 12
                  SizedBox(width: 1.54.w), // 6
                  Flexible(
                    child: Text(
                      host,
                      style: AppText.labelMeta
                          .copyWith(color: AppColors.textSecondary),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      // A host is never mirrored, whatever the app's language.
                      textDirection: TextDirection.ltr,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// A hairline progress rule under the bar while a page loads.
class _LoadingRule extends StatelessWidget {
  const _LoadingRule();

  @override
  Widget build(BuildContext context) => SizedBox(
        height: 0.51.w, // 2
        child: const LinearProgressIndicator(
          backgroundColor: AppColors.ink,
          color: AppColors.textPrimary,
        ),
      );
}
