import 'package:flutter/widgets.dart';

import '../../core/error/app_exception.dart';
import '../../core/utils/phone.dart';
import '../../data/models/delivery.dart';
import '../../data/repositories/delivery_repository.dart';
import 'base_view_model.dart';

/// The result of *Tester les identifiants*.
typedef CredentialsTest = ({bool ok, String message});

/// `Add / edit a delivery provider` (Figma `662:15717`, `662:15973`).
///
/// Built on the web's settings form and the live API's rules:
/// - **one account per courier** (a second one is a 409), so *Add* only offers
///   the couriers not configured yet;
/// - the courier **cannot change** on edit;
/// - stored credentials are never returned, so on edit the fields start empty
///   — *(inchangé — saisir pour modifier)* — and are sent only when all of the
///   courier's fields were typed again;
/// - *Tester les identifiants* checks what is typed without saving anything.
class DeliveryProviderFormViewModel extends BaseViewModel {
  DeliveryProviderFormViewModel({required DeliveryRepository delivery, this.editing})
      : _delivery = delivery,
        _courierId = editing?.provider,
        _wilayaId = editing?.senderWilayaId,
        _isDefault = editing?.isDefault ?? false {
    displayName.text = editing?.displayName ?? '';
    senderName.text = editing?.senderName ?? '';
    senderPhone.text = editing?.senderPhone == null ? '' : Phone.format(editing!.senderPhone!);
    senderAddress.text = editing?.senderAddress ?? '';
    for (final c in [displayName, senderName, senderPhone, senderAddress]) {
      c.addListener(_changed);
    }
    _baseline = _signature;
  }

  final DeliveryRepository _delivery;

  /// Null on *Ajouter un transporteur*.
  final DeliveryProvider? editing;
  bool get isEdit => editing != null;

  final displayName = TextEditingController();
  final senderName = TextEditingController();
  final senderPhone = TextEditingController();
  final senderAddress = TextEditingController();

  /// One controller per credential key of the chosen courier.
  final Map<String, TextEditingController> _credentials = {};
  TextEditingController credential(String key) =>
      _credentials.putIfAbsent(key, () => TextEditingController()..addListener(_changed));

  List<CourierSchema> _couriers = const [];
  List<String> _taken = const [];
  List<Wilaya> _wilayas = const [];
  List<Wilaya> get wilayas => _wilayas;

  /// *Add* offers the couriers the merchant has no account with yet.
  List<CourierSchema> get selectableCouriers =>
      isEdit ? _couriers : _couriers.where((c) => !_taken.contains(c.id)).toList(growable: false);

  bool _loaded = false;
  bool get isLoaded => _loaded;

  /// Every supported courier already has an account — nothing left to add.
  bool get allTaken => _loaded && !isEdit && _couriers.isNotEmpty && selectableCouriers.isEmpty;

  String? _courierId;
  String? get courierId => _courierId;
  CourierSchema? get courier => _couriers.where((c) => c.id == _courierId).firstOrNull;

  int? _wilayaId;
  int? get wilayaId => _wilayaId;

  bool _isDefault;
  bool get isDefault => _isDefault;

  CredentialsTest? _test;
  CredentialsTest? get test => _test;
  bool _testing = false;
  bool get isTesting => _testing;

  bool _attempted = false;

  /// The save was refused (409, network…) — kept on screen above the button.
  AppException? _saveError;
  AppException? get saveError => _saveError;

  bool _saved = false;
  bool get isSaved => _saved;

  late String _baseline;

  Future<void> load() async {
    // Started together, awaited one by one so each keeps its type.
    final couriersCall = _delivery.couriers();
    final wilayasCall = _delivery.wilayas();
    final providersCall = isEdit ? null : _delivery.providers();
    final couriers = await couriersCall;
    final wilayas = await wilayasCall;
    final providers = await providersCall;
    if (isDisposed) return;
    _couriers = couriers.valueOrNull ?? const [];
    _wilayas = wilayas.valueOrNull ?? const [];
    _taken = [for (final p in providers?.valueOrNull ?? const <DeliveryProvider>[]) p.provider];
    // Without the courier list there is no form to fill: say why.
    if (couriers.errorOrNull case final error?) _saveError = error;
    _loaded = true;
    safeNotify();
  }

  void setCourier(String? id) {
    if (id == null || id == _courierId || isEdit) return;
    final previous = courier;
    _courierId = id;
    // The display name follows the courier until the merchant types their own.
    if (displayName.text.trim().isEmpty || displayName.text == previous?.name) {
      displayName.text = courier?.name ?? '';
    }
    _test = null;
    _changed();
  }

  void setWilaya(int? id) {
    _wilayaId = id;
    _changed();
  }

  void setDefault(bool value) {
    _isDefault = value;
    _changed();
  }

  void _changed() {
    _saveError = null;
    safeNotify();
  }

  // ---- Credentials ----

  Map<String, String> get _typed => {
        for (final f in courier?.credentials ?? const <CourierCredentialField>[])
          f.key: credential(f.key).text.trim(),
      };

  /// Every field of the courier holds something.
  bool get credentialsComplete {
    final fields = courier?.credentials ?? const <CourierCredentialField>[];
    return fields.isNotEmpty && fields.every((f) => !f.isRequired || credential(f.key).text.trim().isNotEmpty);
  }

  /// On edit, nothing typed means "keep the stored ones".
  bool get credentialsUntouched => _typed.values.every((v) => v.isEmpty);

  bool get canTest => credentialsComplete && !_testing;

  Future<void> runTest() async {
    final c = courier;
    if (c == null || !canTest) return;
    _testing = true;
    _test = null;
    safeNotify();
    final result = await _delivery.testCredentials(courier: c.id, credentials: _typed);
    if (isDisposed) return;
    _testing = false;
    _test = result.valueOrNull ?? (ok: false, message: result.errorOrNull?.message ?? '');
    safeNotify();
  }

  // ---- Validation ----

  bool get courierMissing => _attempted && courier == null;
  bool get displayNameMissing => _attempted && displayName.text.trim().isEmpty;

  /// Add: every field is required. Edit: all or nothing.
  bool credentialMissing(CourierCredentialField field) {
    if (!_attempted || !field.isRequired) return false;
    if (isEdit && credentialsUntouched) return false;
    return credential(field.key).text.trim().isEmpty;
  }

  bool get isValid {
    if (courier == null || displayName.text.trim().isEmpty) return false;
    if (isEdit && credentialsUntouched) return true;
    return credentialsComplete;
  }

  // ---- Leaving and saving ----

  String get _signature => [
        _courierId,
        displayName.text.trim(),
        senderName.text.trim(),
        Phone.digits(senderPhone.text),
        senderAddress.text.trim(),
        _wilayaId,
        _isDefault,
        ..._credentials.values.map((c) => c.text.trim()),
      ].join('|');

  bool get hasChanges => !_saved && _signature != _baseline;

  static String? _orNull(String s) => s.trim().isEmpty ? null : s.trim();

  Future<DeliveryProvider?> save() async {
    _attempted = true;
    _saveError = null;
    if (!isValid) {
      safeNotify();
      return null;
    }
    final phone = Phone.digitsOrNull(senderPhone.text);
    final saved = await run(
      () => isEdit
          ? _delivery.updateProvider(
              editing!.id,
              displayName: displayName.text.trim(),
              credentials: credentialsUntouched ? null : _typed,
              isDefault: _isDefault,
              senderName: _orNull(senderName.text),
              senderPhone: phone,
              senderAddress: _orNull(senderAddress.text),
              senderWilayaId: _wilayaId,
            )
          : _delivery.addProvider(
              courier: courier!.id,
              displayName: displayName.text.trim(),
              credentials: _typed,
              isDefault: _isDefault,
              senderName: _orNull(senderName.text),
              senderPhone: phone,
              senderAddress: _orNull(senderAddress.text),
              senderWilayaId: _wilayaId,
            ),
      onError: (error) => _saveError = error,
      tag: 'saveDeliveryProvider',
    );
    if (saved != null) _saved = true;
    safeNotify();
    return saved;
  }

  @override
  void dispose() {
    for (final c in [displayName, senderName, senderPhone, senderAddress, ..._credentials.values]) {
      c.dispose();
    }
    super.dispose();
  }
}
