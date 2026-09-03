/// Tolerant readers for backend JSON.
///
/// The backend goes through Prisma and MySQL, so a `Decimal` column arrives as
/// a string (`"1250.00"`), an `Int` as a number, and a nullable relation as
/// `null` or an object depending on the include. Every model reads through
/// these rather than casting, so one loose field cannot throw away a whole
/// list of products.
class Json {
  const Json._();

  static String str(dynamic value, [String fallback = '']) =>
      value?.toString() ?? fallback;

  static String? strOrNull(dynamic value) {
    final s = value?.toString();
    return (s == null || s.isEmpty) ? null : s;
  }

  /// Reads an int from a number, or from a numeric string.
  static int intOf(dynamic value, [int fallback = 0]) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? fallback;
    return fallback;
  }

  static int? intOrNull(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  /// Reads a double. This is the one that matters for money: Prisma `Decimal`
  /// arrives as a string and a naive `as double` cast throws on every price.
  static double dbl(dynamic value, [double fallback = 0]) {
    if (value is double) return value;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? fallback;
    return fallback;
  }

  static double? dblOrNull(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  /// Accepts a real bool, and the `1` / `"true"` forms MySQL and query strings
  /// produce.
  static bool boolOf(dynamic value, [bool fallback = false]) {
    if (value is bool) return value;
    if (value is num) return value != 0;
    if (value is String) {
      final v = value.toLowerCase();
      if (v == 'true' || v == '1' || v == 'yes') return true;
      if (v == 'false' || v == '0' || v == 'no') return false;
    }
    return fallback;
  }

  /// Parses an ISO-8601 timestamp, returning UTC. Formatting for display is the
  /// UI's job, in the merchant's locale.
  static DateTime? dateOrNull(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is int) return DateTime.fromMillisecondsSinceEpoch(value, isUtc: true);
    return DateTime.tryParse(value.toString())?.toUtc();
  }

  static DateTime date(dynamic value) => dateOrNull(value) ?? DateTime.now().toUtc();

  static Map<String, dynamic> map(dynamic value) =>
      value is Map ? Map<String, dynamic>.from(value) : const {};

  static Map<String, dynamic>? mapOrNull(dynamic value) =>
      value is Map ? Map<String, dynamic>.from(value) : null;

  /// Maps a JSON array, skipping any entry that fails to parse rather than
  /// failing the whole list. One malformed product should not empty a screen.
  static List<T> list<T>(dynamic value, T Function(Map<String, dynamic>) parse) {
    if (value is! List) return const [];
    final out = <T>[];
    for (final item in value) {
      if (item is! Map) continue;
      try {
        out.add(parse(Map<String, dynamic>.from(item)));
      } catch (_) {
        continue;
      }
    }
    return out;
  }

  /// Pulls a list out of an envelope, accepting either a bare array or the
  /// `{ "products": [...] }` shape the backend usually returns.
  static List<T> listAt<T>(
    dynamic body,
    String key,
    T Function(Map<String, dynamic>) parse,
  ) {
    if (body is List) return list(body, parse);
    if (body is Map) return list(body[key], parse);
    return const [];
  }
}
