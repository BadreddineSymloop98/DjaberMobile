import '../../core/error/app_exception.dart';
import '../../core/utils/phone.dart';
import '../../core/utils/validators.dart';
import '../../data/models/supplier.dart';
import '../../data/repositories/supplier_repository.dart';
import 'form_field_model.dart';

/// What is wrong with a supplier field, before anything is sent.
enum SupplierFieldError { required, noLetters, nameTaken, invalidEmail, invalidPhone }

/// `Add / edit a supplier` — the web's modal, as a sheet.
///
/// The web's rules: a name with at least one letter or digit; an e-mail and a
/// phone that are **optional** (unlike a client's phone) but well-formed when
/// given. Two more here: a name another supplier already has is refused before
/// sending, and editing shows *Actif* — which is how a deleted supplier comes
/// back.
class SupplierFormViewModel extends FormViewModel {
  SupplierFormViewModel({
    required SupplierRepository suppliers,
    required Set<String> knownNames,
    this.editing,
  })  : _suppliers = suppliers,
        _knownNames = knownNames,
        _isActive = editing?.isActive ?? true {
    name.controller.text = editing?.name ?? '';
    email.controller.text = editing?.email ?? '';
    phone.controller.text = Phone.format(editing?.phone ?? '');
    address.controller.text = editing?.address ?? '';
    notes.controller.text = editing?.notes ?? '';
    attachFields();
  }

  final SupplierRepository _suppliers;
  final Set<String> _knownNames;

  final Supplier? editing;
  bool get isEditing => editing != null;

  final name = FormFieldModel(validator: Validators.optional);
  final email = FormFieldModel(validator: Validators.optional);
  final phone = FormFieldModel(validator: Validators.optional);
  final address = FormFieldModel(validator: Validators.optional);
  final notes = FormFieldModel(validator: Validators.optional);

  @override
  List<FormFieldModel> get fields => [name, email, phone, address, notes];

  bool _isActive;
  bool get isActive => _isActive;

  void setActive(bool value) {
    if (value == _isActive) return;
    _isActive = value;
    safeNotify();
  }

  static final _letterOrDigit = RegExp(r'[A-Za-z0-9؀-ۿÀ-ɏ]');
  static final _phoneChars = RegExp(r'^\+?[0-9\s\-().]{8,20}$');
  static final _email = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');

  SupplierFieldError? get nameError {
    final text = name.value.trim();
    if (text.isEmpty) return SupplierFieldError.required;
    if (!_letterOrDigit.hasMatch(text)) return SupplierFieldError.noLetters;
    final key = text.toLowerCase();
    if (key != editing?.name.trim().toLowerCase() && _knownNames.contains(key)) {
      return SupplierFieldError.nameTaken;
    }
    return null;
  }

  SupplierFieldError? get emailError {
    final text = email.value.trim();
    if (text.isEmpty) return null;
    return _email.hasMatch(text) ? null : SupplierFieldError.invalidEmail;
  }

  SupplierFieldError? get phoneError {
    final text = phone.value.trim();
    if (text.isEmpty) return null;
    final digits = RegExp('[0-9]').allMatches(text).length;
    return _phoneChars.hasMatch(text) && digits >= 8 && digits <= 15
        ? null
        : SupplierFieldError.invalidPhone;
  }

  bool _attempted = false;

  SupplierFieldError? visible(FormFieldModel field, SupplierFieldError? error) {
    if (error == null) return null;
    return (_attempted || field.hasFocus) ? error : null;
  }

  AppException? _submitError;
  AppException? get submitError => _submitError;

  Future<Supplier?> save() async {
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
    return run<Supplier>(
      () => current == null
          ? _suppliers.create(
              name: name.value,
              email: email.value,
              phone: Phone.digits(phone.value),
              address: address.value,
              notes: notes.value,
            )
          : _suppliers.update(
              current.id,
              name: name.value,
              email: email.value,
              phone: Phone.digits(phone.value),
              address: address.value,
              notes: notes.value,
              isActive: _isActive,
            ),
      onError: (error) => _submitError = error,
      tag: current == null ? 'createSupplier' : 'updateSupplier',
    );
  }
}
