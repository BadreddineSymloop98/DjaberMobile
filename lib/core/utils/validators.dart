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

  /// Not a number at all. Possible even behind a numeric keyboard: some
  /// Android IMEs still offer a comma, and a merchant can paste anything.
  notANumber,

  /// Zero or negative where the backend demands greater than zero.
  ///
  /// `user-stock.controller.ts` rejects a cost price, selling price or
  /// initial quantity of 0 outright — worth its own message, because "required"
  /// would be wrong for a field that visibly contains `0`.
  mustBePositive,

  /// A selling price below the cost price. The backend refuses it:
  /// *"Selling price must be greater than or equal to cost price"*.
  belowCostPrice,

  /// A confirmation that does not repeat the value it confirms — the second
  /// password on the reset screen.
  mismatch,
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

  /// The confirmation of another field: present, and exactly the same text.
  ///
  /// Cross-field like [sellingPrice], so it takes the other field's text
  /// rather than being a bare [FieldValidator]. Not trimmed, for the same
  /// reason as [newPassword].
  static FieldValidator matches(String Function() otherText) => (String value) {
        if (value.isEmpty) return FieldError.required;
        return value == otherText() ? null : FieldError.mismatch;
      };

  /// A name. The backend asks only for non-empty; trimmed here so a field
  /// holding only spaces does not pass.
  static FieldError? name(String value) =>
      value.trim().isEmpty ? FieldError.required : null;

  // ---- Product form ----
  //
  // From `backend/src/controllers/user-stock.controller.ts` (`createProduct`),
  // not from taste. The server is stricter than the form looks: a price or a
  // quantity of zero is refused, and the selling price may not sit below the
  // cost price.

  /// Never invalid — the product description, which the backend accepts empty.
  ///
  /// Length ceilings (255 for name and SKU, 5000 for the description) are
  /// enforced at the keyboard with a `LengthLimitingTextInputFormatter`, the
  /// way the email field is capped at 254, rather than as an error message.
  /// What the merchant sees stays what gets sent.
  static FieldError? optional(String value) => null;

  /// Parses the loose forms a merchant actually types: a comma decimal
  /// separator, which is the French convention and what an Algerian handset
  /// offers, and spaces used as thousands separators.
  static double? parseAmount(String value) {
    final cleaned = value.trim().replaceAll(' ', '').replaceAll(',', '.');
    if (cleaned.isEmpty) return null;
    return double.tryParse(cleaned);
  }

  /// A price in DA. Required, numeric, and strictly greater than zero.
  static FieldError? price(String value) {
    if (value.trim().isEmpty) return FieldError.required;
    final amount = parseAmount(value);
    if (amount == null) return FieldError.notANumber;
    if (amount <= 0) return FieldError.mustBePositive;
    return null;
  }

  /// The selling price, which must also clear the cost price.
  ///
  /// Cross-field, so it takes the other field's raw text rather than being a
  /// bare [FieldValidator]. While the cost price is itself unreadable there is
  /// nothing to compare against, and this stays quiet rather than blaming the
  /// wrong field.
  static FieldValidator sellingPrice(String Function() costPriceText) =>
      (String value) {
        final own = price(value);
        if (own != null) return own;
        final cost = parseAmount(costPriceText());
        if (cost == null) return null;
        return parseAmount(value)! < cost ? FieldError.belowCostPrice : null;
      };

  /// A variant's cost or selling price: optional, and legitimately zero.
  ///
  /// The variant endpoint clamps its numbers to `>= 0` and has neither the
  /// above-zero nor the selling-above-cost rule of the product itself (live
  /// docs); the web's editor starts every row at `0`. Only something
  /// unreadable is wrong.
  static FieldError? optionalAmount(String value) {
    if (value.trim().isEmpty) return null;
    final amount = parseAmount(value);
    if (amount == null) return FieldError.notANumber;
    if (amount < 0) return FieldError.mustBePositive;
    return null;
  }

  /// The low-stock alert threshold: optional, and legitimately zero.
  ///
  /// Deliberately not [quantity]. The server defaults `minQuantity` to 0 and
  /// treats 0 as "no threshold set" — `Product.isLowStock` reads it that way
  /// too — so a blank field and a typed `0` are both correct answers. Only a
  /// negative number or something unparseable is wrong.
  static FieldError? threshold(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return null;
    final parsed = int.tryParse(trimmed.replaceAll(' ', ''));
    if (parsed == null) return FieldError.notANumber;
    if (parsed < 0) return FieldError.mustBePositive;
    return null;
  }

  /// An initial quantity: a whole number, greater than zero.
  static FieldError? quantity(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return FieldError.required;
    final parsed = int.tryParse(trimmed.replaceAll(' ', ''));
    if (parsed == null) return FieldError.notANumber;
    if (parsed <= 0) return FieldError.mustBePositive;
    return null;
  }
}
