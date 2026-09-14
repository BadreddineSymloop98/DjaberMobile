import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../../core/extensions/responsive_extension.dart';
import '../../../data/models/connected_page.dart';
import '../../../data/repositories/page_repository.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../../widgets/app_icon.dart';

/// How the web view ended.
enum OAuthOutcome {
  /// Meta handed control back to our backend — the grant went through.
  granted,

  /// The merchant refused in Meta's dialog.
  denied,

  /// The merchant closed the web view themselves.
  ///
  /// A distinct outcome, not a failure: nothing went wrong, they changed their
  /// mind. This is the cancel path §21.10 lists as open — it is now answered
  /// here, by returning the merchant to `T5` with nothing said.
  dismissed,
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
/// sees the callback URL, closes the sheet itself, and carries on.
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

  @override
  void initState() {
    super.initState();
    _host = Uri.tryParse(widget.authUrl)?.host ?? '';
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      // The page behind the dialog is Meta's, on a black ground so the
      // transition from our chrome does not flash white.
      ..setBackgroundColor(AppColors.ink)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) => _onNavigated(url, loading: true),
          onPageFinished: (url) => _onNavigated(url, loading: false),
          onNavigationRequest: (request) {
            // Read before the load starts, so the backend's closing page and
            // the web-app redirect never actually render.
            final step = widget.reader.read(request.url);
            if (step == OAuthStep.keepGoing) return NavigationDecision.navigate;
            _finish(step == OAuthStep.denied
                ? OAuthOutcome.denied
                : OAuthOutcome.granted);
            return NavigationDecision.prevent;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.authUrl));
  }

  void _onNavigated(String url, {required bool loading}) {
    if (!mounted) return;
    setState(() {
      _loading = loading;
      _host = Uri.tryParse(url)?.host ?? _host;
    });
  }

  /// Pops once, whatever got us here — a granted flow can otherwise fire from
  /// both `onNavigationRequest` and a late `onPageStarted`.
  void _finish(OAuthOutcome outcome) {
    if (_finished || !mounted) return;
    _finished = true;
    Navigator.of(context).pop(outcome);
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
