import '../../core/error/app_exception.dart';
import '../../core/utils/validators.dart';
import '../../data/models/client.dart';
import '../../data/repositories/client_repository.dart';
import 'clients_view_model.dart';
import 'form_field_model.dart';

/// What is wrong with a client field, before anything is sent.
enum ClientFieldError {
  required,

  /// A name with no letter or digit in it — the web's `hasAlphanumeric`.
  noLetters,

  /// Not 8–15 digits, or characters a phone does not have.
  invalidPhone,

  invalidEmail,

  /// Another client already has this number.
  phoneTaken,
}

/// `Add / edit a client` — the web's modal, as a sheet.
///
/// The web's rules, in its order: a name with at least one letter or digit, a
/// phone that is **required** (a client has to receive their order) and 8 to 15
/// digits, an e-mail that is optional but well-formed, and no other client with
/// the same number.
class ClientFormViewModel extends FormViewModel {
  ClientFormViewModel({
    required ClientRepository clients,
    required Map<String, Client> knownPhones,
    this.editing,
  })  : _clients = clients,
        _knownPhones = knownPhones {
    name.controller.text = editing?.name ?? '';
    email.controller.text = editing?.email ?? '';
    phone.controller.text = editing?.phone ?? '';
    address.controller.text = editing?.address ?? '';
    notes.controller.text = editing?.notes ?? '';
    attachFields();
  }

  final ClientRepository _clients;
  final Map<String, Client> _knownPhones;

  /// The client being edited, or null when adding.
  final Client? editing;
  bool get isEditing => editing != null;

  final name = FormFieldModel(validator: Validators.optional);
  final email = FormFieldModel(validator: Validators.optional);
  final phone = FormFieldModel(validator: Validators.optional);
  final address = FormFieldModel(validator: Validators.optional);
  final notes = FormFieldModel(validator: Validators.optional);

  @override
  List<FormFieldModel> get fields => [name, email, phone, address, notes];

  static final _letterOrDigit = RegExp(r'[A-Za-z0-9؀-ۿÀ-ɏ]');
  static final _phoneChars = RegExp(r'^\+?[0-9\s\-().]{8,20}$');
  static final _email = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');

  ClientFieldError? get nameError {
    final text = name.value.trim();
    if (text.isEmpty) return ClientFieldError.required;
    if (!_letterOrDigit.hasMatch(text)) return ClientFieldError.noLetters;
    return null;
  }

  ClientFieldError? get phoneError {
    final text = phone.value.trim();
    if (text.isEmpty) return ClientFieldError.required;
    final digits = RegExp('[0-9]').allMatches(text).length;
    if (!_phoneChars.hasMatch(text) || digits < 8 || digits > 15) {
      return ClientFieldError.invalidPhone;
    }
    final owner = duplicateOwner;
    if (owner != null) return ClientFieldError.phoneTaken;
    return null;
  }

  /// The client that already has the typed number, other than this one.
  Client? get duplicateOwner {
    final owner = _knownPhones[normalizePhone(phone.value.trim())];
    if (owner == null || owner.id == editing?.id) return null;
    return owner;
  }

  ClientFieldError? get emailError {
    final text = email.value.trim();
    if (text.isEmpty) return null;
    return _email.hasMatch(text) ? null : ClientFieldError.invalidEmail;
  }

  bool _attempted = false;

  /// Shown on focus or after a submit, like every other form's errors.
  ClientFieldError? visible(FormFieldModel field, ClientFieldError? error) {
    if (error == null) return null;
    return (_attempted || field.hasFocus) ? error : null;
  }

  AppException? _submitError;
  AppException? get submitError => _submitError;

  /// Creates or updates. Returns the saved client, or null.
  Future<Client?> save() async {
    _attempted = true;
    _submitError = null;
    final firstBad = nameError != null
        ? name
        : emailError != null
            ? email
            : phoneError != null
                ? phone
                : null;
    if (firstBad != null) {
      firstBad.focusNode.requestFocus();
      safeNotify();
      return null;
    }

    final current = editing;
    return run<Client>(
      () => current == null
          ? _clients.create(
              name: name.value,
              phone: phone.value,
              email: email.value,
              address: address.value,
              notes: notes.value,
            )
          : _clients.update(
              current.id,
              name: name.value,
              phone: phone.value,
              email: email.value,
              address: address.value,
              notes: notes.value,
            ),
      onError: (error) => _submitError = error,
      tag: current == null ? 'createClient' : 'updateClient',
    );
  }
}
