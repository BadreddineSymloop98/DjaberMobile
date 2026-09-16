import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../../core/extensions/responsive_extension.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../../viewmodels/session_view_model.dart';
import '../../widgets/app_icon.dart';
import '../../widgets/back_scope.dart';
import '../../widgets/leave_sheet.dart';

/// How the merchant left the payment page.
enum CheckoutReturn {
  /// Chargily sent them to the success URL.
  success,

  /// Chargily sent them to the failure URL.
  failed,

  /// They closed the page themselves.
  closed,
}

/// Chargily Pay's hosted checkout, inside the app.
///
/// **Why a web view.** The checkout's `success_url` and `failure_url` point at
/// the *web* dashboard (`/dashboard?section=settings&payment=success|failed`),
/// per the live docs — an external browser would end the merchant on a desktop
/// page with no way back. Here that redirect is stopped and read instead, and
/// the settings screen then asks the backend how the checkout really ended.
class CheckoutWebViewScreen extends StatefulWidget {
  const CheckoutWebViewScreen({super.key, required this.checkoutUrl});

  final String checkoutUrl;

  /// The return a [url] means, or null while the checkout is still going.
  static CheckoutReturn? readReturn(String url) {
    final uri = Uri.tryParse(url);
    if (uri == null || !uri.path.contains('/dashboard')) return null;
    return switch (uri.queryParameters['payment']) {
      'success' => CheckoutReturn.success,
      'failed' => CheckoutReturn.failed,
      _ => null,
    };
  }

  @override
  State<CheckoutWebViewScreen> createState() => _CheckoutWebViewScreenState();
}

class _CheckoutWebViewScreenState extends State<CheckoutWebViewScreen> {
  late final WebViewController _controller;
  late final SessionViewModel _session;
  bool _loading = true;
  bool _finished = false;
  String _host = '';

  @override
  void initState() {
    super.initState();
    // Paying often means leaving for the bank's app or an SMS code; a splash
    // replay on return would drop the payment page with it.
    _session = context.read<SessionViewModel>()..holdSplashReplay();
    _host = Uri.tryParse(widget.checkoutUrl)?.host ?? '';
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(AppColors.ink)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) => _onUrl(url, loading: true),
          onPageFinished: (url) => _onUrl(url, loading: false),
          onUrlChange: (change) {
            final url = change.url;
            if (url != null) _onUrl(url);
          },
          onNavigationRequest: (request) {
            final back = CheckoutWebViewScreen.readReturn(request.url);
            if (back == null) return NavigationDecision.navigate;
            _finish(back);
            return NavigationDecision.prevent;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.checkoutUrl));
  }

  void _onUrl(String url, {bool? loading}) {
    final back = CheckoutWebViewScreen.readReturn(url);
    if (back != null) {
      _finish(back);
      return;
    }
    if (!mounted) return;
    setState(() {
      if (loading != null) _loading = loading;
      _host = Uri.tryParse(url)?.host ?? _host;
    });
  }

  void _finish(CheckoutReturn back) {
    if (_finished || !mounted) return;
    _finished = true;
    Navigator.of(context).pop(back);
  }

  @override
  void dispose() {
    _session.releaseSplashReplay();
    super.dispose();
  }

  /// Back and the × share this: abandoning a payment asks first. Chargily's
  /// own success and failure redirects call [_finish] directly and never ask.
  ///
  /// Always consumes the press ([_finish] pops with its result). [_finished]
  /// is checked again after the sheet: a success redirect can land while it
  /// is open, and must not be turned into `closed`.
  Future<bool> _onBack() async {
    if (_finished) return false;
    final l10n = L10n.of(context);
    final leave = await showLeaveSheet(
      context,
      title: l10n.checkoutLeaveTitle,
      body: l10n.checkoutLeaveBody,
    );
    if (leave && mounted && !_finished) _finish(CheckoutReturn.closed);
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);
    // Standalone: this is a pageless route over Settings, with no BackScope.
    return BackIntercept(
      active: !_finished,
      onBack: _onBack,
      child: Scaffold(
        backgroundColor: AppColors.ink,
        body: SafeArea(
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: AppSpacing.gutterTight, vertical: AppSpacing.md),
                decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.rule))),
                child: Row(
                  children: [
                    Semantics(
                      button: true,
                      label: l10n.commonDismiss,
                      child: GestureDetector(
                        onTap: _onBack,
                        behavior: HitTestBehavior.opaque,
                        child: SizedBox.square(
                          dimension: 6.15.w, // 24
                          child: Center(
                            child: AppIcon(AppIcons.close, size: 5.13.w, color: AppColors.textPrimary),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 2.56.w, vertical: 1.54.w),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          border: Border.all(color: AppColors.rule, width: AppStroke.hairline),
                          borderRadius: BorderRadius.circular(AppRadius.card),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            AppIcon(AppIcons.globe, size: 3.08.w),
                            SizedBox(width: 1.54.w),
                            Flexible(
                              child: Text(
                                _host,
                                style: AppText.labelMeta.copyWith(color: AppColors.textSecondary),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                                textDirection: TextDirection.ltr,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (_loading)
                SizedBox(
                  height: 0.51.w, // 2
                  child: const LinearProgressIndicator(backgroundColor: AppColors.ink, color: AppColors.textPrimary),
                ),
              Expanded(child: WebViewWidget(controller: _controller)),
            ],
          ),
        ),
      ),
    );
  }
}
