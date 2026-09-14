import '../../core/utils/json.dart';

/// The authenticated merchant.
///
/// Fields are exactly what the backend sends — `backend/prisma/schema.prisma`
/// for the shape, `src/controllers/auth.controller.ts` for which subset each
/// endpoint returns:
///
/// | Endpoint | Returns |
/// |---|---|
/// | `POST /api/auth/login` | id, email, firstName, lastName, plan, isAdmin |
/// | `POST /api/auth/register` | the same **minus** isAdmin |
/// | `GET /api/auth/profile` | the above **plus** creditsUsed, creditsLimit, createdAt |
///
/// So credits are null straight after signing in and only arrive with the
/// profile. That is why [isAgentPaused] returns false when they are unknown —
/// "not yet loaded" must not read as "out of credits".
///
/// Parsing is hand-written rather than generated. Prisma sends a `Decimal` as
/// a string and an `Int` as a number, so every model funnels through the
/// tolerant helpers in `core/utils/json.dart`. That tolerance is the point;
/// codegen would be stricter and fail on live data.
class User {
  const User({
    required this.id,
    required this.email,
    this.firstName,
    this.lastName,
    this.plan,
    this.isAdmin = false,
    this.creditsUsed,
    this.creditsLimit,
    this.createdAt,
  });

  final String id;
  final String email;
  final String? firstName;
  final String? lastName;

  /// `individual` or `teams`, defaulted server-side to `individual`.
  ///
  /// The sign-up screen does not collect it, so every mobile registration
  /// lands on `individual` — brief Q3 (owner or team) as a concrete field.
  final String? plan;

  final bool isAdmin;

  /// AI credits consumed this billing period. Only present from `/profile`.
  final int? creditsUsed;

  /// The plan's monthly ceiling. Only present from `/profile`.
  final int? creditsLimit;

  final DateTime? createdAt;

  String get displayName {
    final parts =
        [firstName, lastName].whereType<String>().where((s) => s.isNotEmpty);
    return parts.isEmpty ? email : parts.join(' ');
  }

  /// The first name alone, for a greeting. Falls back to the part of the email
  /// before the `@` so a greeting never reads "Welcome back, ".
  String get greetingName {
    final first = firstName?.trim();
    if (first != null && first.isNotEmpty) return first;
    final at = email.indexOf('@');
    return at > 0 ? email.substring(0, at) : email;
  }

  /// Two letters for an avatar, falling back to the email.
  String get initials {
    final first = firstName?.trim();
    final last = lastName?.trim();
    if (first != null && first.isNotEmpty && last != null && last.isNotEmpty) {
      return '${first[0]}${last[0]}'.toUpperCase();
    }
    final source = (first?.isNotEmpty ?? false) ? first! : email;
    return source.isEmpty ? '?' : source.substring(0, 1).toUpperCase();
  }

  /// Credits left, or null while unknown.
  int? get creditsRemaining {
    final used = creditsUsed;
    final limit = creditsLimit;
    if (used == null || limit == null) return null;
    final left = limit - used;
    return left < 0 ? 0 : left;
  }

  /// True only when the backend has told us the allowance is spent.
  ///
  /// When credits run out the agent stops replying and the app's whole promise
  /// stops working — the web dashboard banners it as
  /// "Crédits épuisés — l'agent IA est en pause". On mobile it matters more,
  /// because the merchant will not be at a desk when it happens.
  ///
  /// Deliberately false while [creditsUsed] or [creditsLimit] is null: an
  /// earlier version compared a `credits` field the backend never sends, so
  /// this silently answered false for a different reason — because it was
  /// always null, not because the merchant had credit.
  bool get isAgentPaused {
    final used = creditsUsed;
    final limit = creditsLimit;
    if (used == null || limit == null) return false;
    return used >= limit;
  }

  factory User.fromJson(Map<String, dynamic> json) => User(
        id: Json.str(json['id']),
        email: Json.str(json['email']),
        firstName: Json.strOrNull(json['firstName']),
        lastName: Json.strOrNull(json['lastName']),
        plan: Json.strOrNull(json['plan']),
        isAdmin: Json.boolOf(json['isAdmin']),
        creditsUsed: Json.intOrNull(json['creditsUsed']),
        creditsLimit: Json.intOrNull(json['creditsLimit']),
        createdAt: Json.dateOrNull(json['createdAt']),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        if (firstName != null) 'firstName': firstName,
        if (lastName != null) 'lastName': lastName,
        if (plan != null) 'plan': plan,
        'isAdmin': isAdmin,
        if (creditsUsed != null) 'creditsUsed': creditsUsed,
        if (creditsLimit != null) 'creditsLimit': creditsLimit,
        if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
      };

  /// Merges a fresher record over this one without losing fields the newer
  /// response omits.
  ///
  /// The reason this exists: signing in returns no credits, and the profile
  /// fetch that follows returns them. Replacing the user wholesale on every
  /// response would keep dropping whichever fields that endpoint leaves out.
  User mergedWith(User newer) => User(
        id: newer.id,
        email: newer.email,
        firstName: newer.firstName ?? firstName,
        lastName: newer.lastName ?? lastName,
        plan: newer.plan ?? plan,
        isAdmin: newer.isAdmin || isAdmin,
        creditsUsed: newer.creditsUsed ?? creditsUsed,
        creditsLimit: newer.creditsLimit ?? creditsLimit,
        createdAt: newer.createdAt ?? createdAt,
      );
}
