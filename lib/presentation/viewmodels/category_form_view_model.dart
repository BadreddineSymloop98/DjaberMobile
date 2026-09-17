import '../../core/error/app_exception.dart';
import '../../core/utils/validators.dart';
import '../../data/models/catalogue.dart';
import '../../data/repositories/catalogue_repository.dart';
import 'categories_view_model.dart';
import 'form_field_model.dart';

/// Why a category name is refused before it is sent.
enum CategoryNameError { required, tooShort, duplicate }

/// `Add / edit a category` — the web's modal as a sheet.
///
/// Name (required, at least two characters, as the web's `validateName`),
/// description, and a colour from the ten presets or a custom hex.
///
/// **A name already in use is caught here**, against [knownNames]. The backend
/// answers a duplicate with a 400 on create but a bare **500** on update, so
/// without this check the edit sheet could only say "server error".
class CategoryFormViewModel extends FormViewModel {
  CategoryFormViewModel({
    required CatalogueRepository catalogue,
    required Set<String> knownNames,
    this.editing,
  })  : _catalogue = catalogue,
        _knownNames = knownNames,
        _color = normalizeCategoryColor(editing?.color ?? '') ?? kCategoryDefaultColor {
    name.controller.text = editing?.name ?? '';
    description.controller.text = editing?.description ?? '';
    attachFields();
  }

  final CatalogueRepository _catalogue;
  final Set<String> _knownNames;

  /// The category being edited, or null when adding.
  final ProductCategory? editing;

  bool get isEditing => editing != null;

  final name = FormFieldModel(validator: Validators.name);
  final description = FormFieldModel(validator: Validators.optional);

  @override
  List<FormFieldModel> get fields => [name, description];

  String _color;

  /// Always `#RRGGBB` in capitals.
  String get color => _color;

  /// True when the colour is not one of the presets — the **+** tile then
  /// shows it as selected.
  bool get isCustomColor => !kCategoryPresetColors.contains(_color);

  void setColor(String value) {
    final normalized = normalizeCategoryColor(value);
    if (normalized == null || normalized == _color) return;
    _color = normalized;
    safeNotify();
  }

  /// The name's problem, or null. Duplicates ignore the category's own current
  /// name, so saving an edit without renaming is not a clash with itself.
  CategoryNameError? get nameError {
    final text = name.value.trim();
    if (text.isEmpty) return CategoryNameError.required;
    if (text.length < 2) return CategoryNameError.tooShort;
    final key = text.toLowerCase();
    final own = editing?.name.trim().toLowerCase();
    if (key != own && _knownNames.contains(key)) return CategoryNameError.duplicate;
    return null;
  }

  bool _attempted = false;

  /// Shown on focus or after a submit, like every other form's errors.
  CategoryNameError? get visibleNameError {
    final error = nameError;
    if (error == null) return null;
    return (_attempted || name.hasFocus) ? error : null;
  }

  AppException? _submitError;
  AppException? get submitError => _submitError;

  /// Creates or updates. Returns the saved category, or null.
  Future<ProductCategory?> save() async {
    _attempted = true;
    _submitError = null;
    if (nameError != null) {
      name.focusNode.requestFocus();
      safeNotify();
      return null;
    }

    final current = editing;
    return run<ProductCategory>(
      () => current == null
          ? _catalogue.createCategory(
              name: name.value,
              description: description.value,
              color: _color,
            )
          : _catalogue.updateCategory(
              current.id,
              name: name.value,
              description: description.value,
              color: _color,
            ),
      onError: (error) => _submitError = error,
      tag: current == null ? 'createCategory' : 'updateCategory',
    );
  }
}
