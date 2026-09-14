/// A failure the UI can act on, translated from whatever the transport threw.
///
/// ## The backend's error contract (v1)
///
/// As of 2026-09-10 the backend answers **every** non-2xx with one shape:
///
/// ```json
/// {
///   "error":   "Bad Request",
///   "code":    "VALIDATION_FAILED",
///   "message": "Certains champs sont invalides. Veuillez vérifier le formulaire.",
///   "fields":  [ { "field": "quantity", "code": "FIELD_MUST_BE_POSITIVE",
///                  "message": "Le champ « quantity » doit être supérieur à zéro." } ],
///   "params":  { "limit": 1, "item": "agent" }
/// }
/// ```
///
/// Three consequences, and they replace everything this file used to say:
///
/// 1. **[message] is already translated** into the language the app asked for
///    via `Accept-Language`, which `LocaleViewModel` has always sent. Display
///    it. Do not translate it again, and never match on its text — the words
///    change with the locale.
/// 2. **[code] is the stable key.** Branch on it, not on the message and
///    rarely on the raw status. Codes outlive wording and status changes.
/// 3. **[fields] names the offending inputs** on a validation failure, each
///    with its own translated message, so a form can mark its own controls.
///
/// This is a reversal. Until this contract shipped, every backend message was
/// a hardcoded English literal and `Accept-Language` was read nowhere — so the
/// app matched English substrings to pick its own French copy, the way the web
/// still does in `translateBackendError`. All of that is now dead weight and
/// has been removed; the substring table it relied on described strings the
/// server no longer sends.
sealed class AppException implements Exception {
  const AppException(
    this.message, {
    this.statusCode,
    this.code,
    this.fields = const [],
    this.params = const {},
    this.data,
  });

  /// Safe to show to a merchant, and **already in their language**.
  final String message;

  final int? statusCode;

  /// The contract's stable machine key — `PRODUCT_SKU_ALREADY_EXISTS`,
  /// `PLAN_LIMIT_REACHED`. Null only when the body carried none, which now
  /// means a transport failure or a malformed response.
  ///
  /// Never shown to a merchant. It is for `switch` statements and logs.
  final String? code;

  /// Per-input errors, on a 400. Empty everywhere else.
  final List<ApiFieldError> fields;

  /// Values the server used inside [message] — `limit`, `max`, `allowed`,
  /// `sku`. Read them only to build copy the contract does not already give
  /// you, such as a plan-limit upsell that needs the number on its own.
  final Map<String, dynamic> params;

  /// The whole decoded body, for logging an unexpected shape.
  final Map<String, dynamic>? data;

  /// Nothing reached the server — offline, DNS, timeout. The one case with no
  /// server message, so the app supplies its own.
  bool get isNetwork => this is NetworkException || this is TimeoutException;

  /// A 400 naming the inputs at fault. Put [fields] on the form.
  bool get isValidation => this is ValidationException;

  /// The session is gone. There is no refresh endpoint — clear it and show
  /// login.
  bool get isUnauthorized => this is UnauthorizedException;

  /// A 422: the request was well-formed and the *situation* forbids it — a
  /// delivered order cannot be deleted, stock would go negative. The message
  /// is the merchant's instruction; show it as it is.
  bool get isBusinessRule => this is BusinessRuleException;

  /// Worth offering a Retry.
  ///
  /// Transport failures, our own 5xx, and 429. **Never a 4xx** — repeating a
  /// request the server has already reasoned about just delays the answer.
  bool get isRetryable =>
      isNetwork ||
      this is ServerException ||
      this is RateLimitedException ||
      (statusCode != null && statusCode! >= 500);

  /// The translated message for one input, or null if the server did not
  /// fault it.
  String? fieldMessage(String field) {
    for (final f in fields) {
      if (f.field == field) return f.message;
    }
    return null;
  }

  /// [fields] as a map for a form to hold, keyed by input name.
  ///
  /// Nested paths keep the shape the server sent — `items[0].quantity`.
  Map<String, String> get fieldMessages => {
        for (final f in fields) f.field: f.message,
      };

  @override
  String toString() =>
      '$runtimeType($statusCode${code == null ? '' : ' $code'}): $message';
}

/// One faulted input inside a [ValidationException].
class ApiFieldError {
  const ApiFieldError({
    required this.field,
    required this.message,
    this.code,
    this.params = const {},
  });

  factory ApiFieldError.fromJson(Map<String, dynamic> json) => ApiFieldError(
        // `path` is express-validator's name for it, which the legacy
        // `errors[]` array still uses; the contract's `fields[]` says `field`.
        field: (json['field'] ?? json['path'] ?? json['param'] ?? '').toString(),
        message: (json['message'] ?? json['msg'] ?? '').toString(),
        code: json['code'] as String?,
        params: json['params'] is Map
            ? Map<String, dynamic>.from(json['params'] as Map)
            : const {},
      );

  /// The input's name, as the request sent it.
  final String field;

  /// Already translated.
  final String message;

  /// `FIELD_REQUIRED`, `FIELD_MUST_BE_POSITIVE`, `FIELD_INVALID_EMAIL`.
  final String? code;

  final Map<String, dynamic> params;

  @override
  String toString() => '$field($code): $message';
}

/// No usable connection, DNS failure, or the request never reached the server.
///
/// The contract's status `0`. The only failure with no server message, so
/// [message] here is a placeholder the UI replaces with a localised string.
class NetworkException extends AppException {
  const NetworkException([super.message = 'No connection']);
}

/// The request reached the server but took too long.
class TimeoutException extends AppException {
  const TimeoutException([super.message = 'Request timed out']);
}

/// 401 — no token, or expired. `INVALID_TOKEN`, `UNAUTHORIZED`,
/// `AUTH_INVALID_CREDENTIALS`.
///
/// Tokens last 7 days and there is nothing to refresh against, so the auth
/// layer clears the session.
class UnauthorizedException extends AppException {
  const UnauthorizedException(
    super.message, {
    super.code,
    super.params,
    super.data,
  }) : super(statusCode: 401);
}

/// 403 — no right to this, or a plan cap. `PLAN_LIMIT_REACHED` carries
/// `params['limit']`.
class ForbiddenException extends AppException {
  const ForbiddenException(
    super.message, {
    super.code,
    super.params,
    super.data,
  }) : super(statusCode: 403);
}

/// 402 — `INSUFFICIENT_CREDITS`. The AI has stopped replying, which is the one
/// failure the merchant most needs to understand.
class PaymentRequiredException extends AppException {
  const PaymentRequiredException(
    super.message, {
    super.code,
    super.params,
    super.data,
  }) : super(statusCode: 402);
}

/// 404 — missing, or never theirs. The server does not distinguish the two on
/// purpose, so neither does the app.
class NotFoundException extends AppException {
  const NotFoundException(
    super.message, {
    super.code,
    super.params,
    super.data,
  }) : super(statusCode: 404);
}

/// 400 — the payload was rejected and [fields] says which inputs.
class ValidationException extends AppException {
  const ValidationException(
    super.message, {
    super.statusCode,
    super.code,
    super.fields,
    super.params,
    super.data,
  });
}

/// 409 — a duplicate. `PRODUCT_SKU_ALREADY_EXISTS`, `AUTH_EMAIL_TAKEN`,
/// `CLIENT_PHONE_EXISTS`.
///
/// Distinct from [ValidationException] because the fix is different: nothing
/// about the input is malformed, the value is taken. The message names it, and
/// `params` usually carries the value itself.
class ConflictException extends AppException {
  const ConflictException(
    super.message, {
    super.code,
    super.params,
    super.data,
  }) : super(statusCode: 409);
}

/// 413 — `FILE_TOO_LARGE`. `params['maxMb']` is the limit.
class PayloadTooLargeException extends AppException {
  const PayloadTooLargeException(
    super.message, {
    super.code,
    super.params,
    super.data,
  }) : super(statusCode: 413);
}

/// 422 — a business rule. `ORDER_DELETE_DELIVERED`, `STOCK_INSUFFICIENT`,
/// `REPLY_OUTSIDE_WINDOW`.
class BusinessRuleException extends AppException {
  const BusinessRuleException(
    super.message, {
    super.code,
    super.params,
    super.data,
  }) : super(statusCode: 422);
}

/// 429 — too many requests. Retryable after a wait.
class RateLimitedException extends AppException {
  const RateLimitedException(
    super.message, {
    super.code,
    super.params,
    super.data,
  }) : super(statusCode: 429);
}

/// 5xx.
class ServerException extends AppException {
  const ServerException(
    super.message, {
    super.statusCode,
    super.code,
    super.params,
  });
}

/// The request was cancelled — a screen was disposed mid-flight, or a search
/// query was superseded. Usually swallowed rather than shown.
class CancelledException extends AppException {
  const CancelledException([super.message = 'Cancelled']);
}

/// Anything not covered above, including a response that failed to parse.
class UnknownException extends AppException {
  const UnknownException(super.message, {super.statusCode, super.code, super.data});
}
