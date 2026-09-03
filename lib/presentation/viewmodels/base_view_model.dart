import 'package:flutter/foundation.dart';

import '../../core/error/app_exception.dart';
import '../../core/error/result.dart';
import '../../core/utils/logger.dart';

/// What a screen can be doing.
enum ViewState { idle, loading, ready, empty, error }

/// The V-M half of MVVM.
///
/// A view model holds screen state and calls repositories; it never imports
/// `material.dart` and never touches a `BuildContext`. The view watches it
/// through `provider` and rebuilds. That split is what makes a screen's logic
/// testable without a widget tree.
///
/// [run] is the reason this base class exists: it wraps a repository call with
/// the loading flag, the error slot, and the disposal guard, so a screen's code
/// is one line per action instead of the same six lines repeated.
abstract class BaseViewModel extends ChangeNotifier {
  ViewState _state = ViewState.idle;
  AppException? _error;
  bool _disposed = false;

  /// Set while a *foreground* action is running — one that should show a
  /// spinner. A background poll deliberately does not set it: the inbox
  /// refreshing every 20 seconds must not flash a loader over content the
  /// merchant is reading.
  bool _busy = false;

  ViewState get state => _state;
  AppException? get error => _error;
  bool get isBusy => _busy;
  bool get isLoading => _state == ViewState.loading;
  bool get hasError => _state == ViewState.error;
  bool get isDisposed => _disposed;

  @protected
  void setState(ViewState value) {
    if (_state == value) return;
    _state = value;
    safeNotify();
  }

  @protected
  void setError(AppException? value) {
    _error = value;
    _state = value == null ? _state : ViewState.error;
    safeNotify();
  }

  @protected
  void clearError() {
    if (_error == null) return;
    _error = null;
    safeNotify();
  }

  /// `notifyListeners` that cannot throw after disposal.
  ///
  /// An in-flight request whose screen has been popped is normal here — the
  /// merchant taps back while a slow request is still running — and without
  /// this guard it crashes the app.
  @protected
  void safeNotify() {
    if (_disposed) return;
    notifyListeners();
  }

  /// Runs a repository call and folds the result into view state.
  ///
  /// ```dart
  /// Future<void> load() => run(
  ///       () => _repo.getProducts(),
  ///       onSuccess: (products) => _products = products,
  ///       isEmpty: () => _products.isEmpty,
  ///     );
  /// ```
  ///
  /// Set [silent] for a background refresh so the screen keeps showing its
  /// current content instead of a spinner.
  @protected
  Future<T?> run<T>(
    Future<Result<T>> Function() action, {
    void Function(T value)? onSuccess,
    void Function(AppException error)? onError,
    bool Function()? isEmpty,
    bool silent = false,
    String? tag,
  }) async {
    if (!silent) {
      _busy = true;
      _error = null;
      setState(ViewState.loading);
      safeNotify();
    }

    final result = await action();
    if (_disposed) return null;

    _busy = false;

    return result.fold(
      onSuccess: (value) {
        _error = null;
        onSuccess?.call(value);
        setState((isEmpty?.call() ?? false) ? ViewState.empty : ViewState.ready);
        safeNotify();
        return value;
      },
      onFailure: (error) {
        Log.w('${tag ?? runtimeType}: $error', tag: 'vm');
        onError?.call(error);
        // A silent refresh that fails keeps whatever is on screen. Replacing
        // a readable list with an error page because one poll missed is worse
        // than stale data.
        if (silent) {
          _error = error;
          safeNotify();
        } else {
          setError(error);
        }
        return null;
      },
    );
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
