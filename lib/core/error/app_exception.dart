/// A failure the UI can act on, translated from whatever the transport threw.
///
/// View models never see a `DioException`; the network layer maps everything
/// into one of these so a screen can decide between "show a retry button"
/// (network), "send them to login" (unauthorized) and "show the message"
/// (validation) without knowing anything about HTTP.
sealed class AppException implements Exception {
  const AppException(this.message, {this.statusCode, this.data});

  /// Safe to show to a merchant. Backend messages are already localised by the
  /// API where it has them; otherwise the UI substitutes a localised string
  /// based on the runtime type.
  final String message;
  final int? statusCode;
  final Map<String, dynamic>? data;

  @override
  String toString() => '$runtimeType($statusCode): $message';
}

/// No usable connection, DNS failure, or the request never reached the server.
class NetworkException extends AppException {
  const NetworkException([super.message = 'No connection']);
}

/// The request reached the server but took too long.
class TimeoutException extends AppException {
  const TimeoutException([super.message = 'Request timed out']);
}

/// 401 / 403 — the token is missing, expired or rejected. The auth layer
/// listens for this and clears the session.
class UnauthorizedException extends AppException {
  const UnauthorizedException([super.message = 'Session expired'])
      : super(statusCode: 401);
}

/// 404.
class NotFoundException extends AppException {
  const NotFoundException([super.message = 'Not found'])
      : super(statusCode: 404);
}

/// 400 / 422 — the server rejected the payload. [fieldErrors] carries per-field
/// messages when the backend supplies them, so a form can mark its own inputs.
class ValidationException extends AppException {
  const ValidationException(
    super.message, {
    super.statusCode,
    super.data,
    this.fieldErrors = const {},
  });

  final Map<String, String> fieldErrors;
}

/// 5xx.
class ServerException extends AppException {
  const ServerException(super.message, {super.statusCode});
}

/// The request was cancelled — a screen was disposed mid-flight, or a search
/// query was superseded. Usually swallowed rather than shown.
class CancelledException extends AppException {
  const CancelledException([super.message = 'Cancelled']);
}

/// Anything not covered above, including a response that failed to parse.
class UnknownException extends AppException {
  const UnknownException(super.message, {super.data});
}
