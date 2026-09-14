/// Field validation, mirroring what the backend actually enforces.
///
/// The rules come from `backend/src/routes/auth.routes.ts`, not from taste:
///
/// ```
/// register: email isEmail, password isLength{min:8},
///           firstName notEmpty, lastName notEmpty
/// login:    email isEmail, password notEmpty
/// ```
///
/// Note the asymmetry — login only requires a *non-empty* password, because a
/// merchant whose account predates the 8-character rule must still be able to
/// sign in. Enforcing 8 on the login screen would lock them out of their own
/// account with a client-side rule the server never applied.
///
/// Validators return a [FieldError] rather than a string so they stay pure and
/// testable; the UI maps the code to the localised message. That also keeps
/// the wording in one place — the web's own `auth.errors.*`.
library;

/// What is wrong with a field. One value per message the web already has.
enum FieldError {
  /// Empty, and the field is required.
  required,

  /// Present but not a usable email address.
  invalidEmail,

  /// Shorter than the minimum the backend enforces.
  tooShort,
}

typedef FieldValidator = FieldError? Function(String value);

class Validators {
  const Validators._();

  /// The backend's minimum, and the number in the web's own hint copy
  /// ("Au moins 8 caractères").
  static const int passwordMinLength = 8;

  /// Deliberately permissive about the local part and strict about the domain:
  /// it must have a dot and a plausible TLD.
  ///
  /// A stricter regex rejects addresses that are legal and in use; a looser one
  /// lets `a@b` through, which is the actual mistake merchants make. The server
  /// remains the authority — this only catches typos before a round trip.
  static final RegExp _email = RegExp(
    r"^[A-Za-z0-9.!#$%&'*+/=?^_`{|}~-]+"
    r'@[A-Za-z0-9](?:[A-Za-z0-9-]{0,61}[A-Za-z0-9])?'
    r'(?:\.[A-Za-z0-9](?:[A-Za-z0-9-]{0,61}[A-Za-z0-9])?)+$',
  );

  /// Required, and a valid address.
  static FieldError? email(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return FieldError.required;
    if (!_email.hasMatch(trimmed)) return FieldError.invalidEmail;
    return null;
  }

  /// Sign-in: present, nothing more. See the note above.
  static FieldError? password(String value) =>
      value.isEmpty ? FieldError.required : null;

  /// Sign-up: present and at least [passwordMinLength].
  ///
  /// Not trimmed — leading and trailing spaces are legitimate characters in a
  /// password, and silently dropping them would mean the merchant's account is
  /// created with a different secret than the one they typed.
  static FieldError? newPassword(String value) {
    if (value.isEmpty) return FieldError.required;
    if (value.length < passwordMinLength) return FieldError.tooShort;
    return null;
  }

  /// A name. The backend asks only for non-empty; trimmed here so a field
  /// holding only spaces does not pass.
  static FieldError? name(String value) =>
      value.trim().isEmpty ? FieldError.required : null;
}
