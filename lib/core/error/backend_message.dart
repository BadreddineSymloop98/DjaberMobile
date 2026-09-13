import 'app_exception.dart';

/// Whether the server gave us a sentence worth showing.
///
/// Since the error contract shipped (2026-09-10) the answer is almost always
/// yes: every non-2xx carries a `message` already translated into the
/// merchant's language, so the app's job is to *display* it, not to derive it.
///
/// What remains is a thin guard for the cases where there is no sentence at
/// all — a transport failure that never reached the server, a malformed body,
/// a status with an empty message. Those get the app's own localised copy
/// instead. It is deliberately much smaller than it was: the previous version
/// carried a table of English status names and a 404-handler pattern, because
/// the app used to have to *choose* copy by matching the server's English. It
/// no longer does, and matching on message text is now explicitly wrong —
/// the words change with the locale.
///
/// ```dart
/// preciseBackendMessage(error) ?? l10n.errorGeneric
/// ```
String? preciseBackendMessage(AppException error) {
  final message = error.message.trim();
  if (message.isEmpty) return null;

  // A transport failure carries a placeholder from the constructor default
  // ("No connection", "Request timed out") rather than anything the server
  // said, and those are English and for us. The UI maps these by type to
  // `errorNetwork` / `errorTimeout` before ever reaching here; this is the
  // backstop for a caller that forgets.
  if (error.isNetwork) return null;

  // Our own diagnostic from `ApiClient._send` when parsing threw.
  if (message.startsWith('Unexpected response:')) return null;

  return message;
}
