/// The authenticated merchant.
///
/// Fields mirror what `POST /api/auth/login` and `GET /api/auth/profile`
/// return — see `backend/src/controllers/auth.controller.ts`.
///
/// Parsing is hand-written rather than generated. The backend is not uniformly
/// strict about types (an id arrives as a number on some routes and a string on
/// others), so every model funnels through the tolerant helpers in
/// `core/utils/json.dart`. That tolerance is the point; codegen would be
/// stricter and would fail on live data.
class User {
  const User({
    required this.id,
    required this.email,
    this.firstName,
    this.lastName,
    this.role,
    this.companyName,
    this.plan,
    this.credits,
  });

  final String id;
  final String email;
  final String? firstName;
  final String? lastName;
  final String? role;
  final String? companyName;
  final String? plan;

  /// AI credits remaining. When these run out the agent pauses and the app's
  /// whole promise stops working — the web dashboard shows
  /// "Crédits épuisés — l'agent IA est en pause". The brief flags this as
  /// interrupt-shaped and therefore belonging on the phone.
  final int? credits;

  String get displayName {
    final parts = [firstName, lastName].whereType<String>().where((s) => s.isNotEmpty);
    return parts.isEmpty ? email : parts.join(' ');
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

  bool get isAgentPaused => (credits ?? 1) <= 0;

  factory User.fromJson(Map<String, dynamic> json) => User(
        id: json['id']?.toString() ?? '',
        email: json['email']?.toString() ?? '',
        firstName: json['firstName']?.toString(),
        lastName: json['lastName']?.toString(),
        role: json['role']?.toString(),
        companyName: json['companyName']?.toString(),
        plan: (json['plan'] is Map)
            ? (json['plan'] as Map)['name']?.toString()
            : json['plan']?.toString(),
        credits: json['credits'] is num ? (json['credits'] as num).toInt() : null,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        if (firstName != null) 'firstName': firstName,
        if (lastName != null) 'lastName': lastName,
        if (role != null) 'role': role,
        if (companyName != null) 'companyName': companyName,
        if (plan != null) 'plan': plan,
        if (credits != null) 'credits': credits,
      };

  User copyWith({int? credits, String? companyName}) => User(
        id: id,
        email: email,
        firstName: firstName,
        lastName: lastName,
        role: role,
        companyName: companyName ?? this.companyName,
        plan: plan,
        credits: credits ?? this.credits,
      );
}
