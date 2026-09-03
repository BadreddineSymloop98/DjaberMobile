import 'package:flutter/widgets.dart';

import '../../core/utils/validators.dart';
import 'base_view_model.dart';

/// One text field's state: its controller, its focus, and whether its error
/// should currently be on screen.
///
/// Owned by a [FormViewModel], never by a widget — the screen only reads it.
class FormFieldModel {
  FormFieldModel({required this.validator, String initialValue = ''})
      : controller = TextEditingController(text: initialValue),
        _lastText = initialValue;

  final TextEditingController controller;
  final FocusNode focusNode = FocusNode();
  final FieldValidator validator;

  /// True once the merchant has typed into this field.
  ///
  /// This is what stops a required-field error from firing the instant a field
  /// is tapped. An empty field the merchant is *about to* fill is not a
  /// mistake yet, and telling them it is reads as the form arguing with them.
  bool isDirty = false;

  String _lastText;

  String get value => controller.text;
  bool get hasFocus => focusNode.hasFocus;

  /// Marks the field dirty only when the *text* changed, and reports whether
  /// anything worth a repaint happened.
  ///
  /// A [TextEditingController] also notifies on selection changes — and
  /// focusing a `TextField` moves the caret, which counts. Without this
  /// check, tapping into an empty required field marked it dirty and fired a
  /// "required" error before a single key was pressed.
  bool consumeTextChange() {
    if (controller.text == _lastText) return false;
    _lastText = controller.text;
    isDirty = true;
    return true;
  }

  /// The current problem, or null. Independent of whether it is displayed.
  FieldError? get error => validator(value);
  bool get isValid => error == null;

  void dispose() {
    controller.dispose();
    focusNode.dispose();
  }
}

/// Base for a screen's form.
///
/// Holds the fields, wires their listeners, and owns the one rule that decides
/// when an error is visible.
abstract class FormViewModel extends BaseViewModel {
  /// Every field on the form, in tab order.
  List<FormFieldModel> get fields;

  bool _submitAttempted = false;

  /// True once the primary button has been pressed on an invalid form. From
  /// then on every invalid field shows its error, including ones never touched.
  bool get submitAttempted => _submitAttempted;

  bool get isValid => fields.every((f) => f.isValid);

  /// Call from the concrete view model's constructor, after [fields] can be
  /// read.
  @protected
  void attachFields() {
    for (final field in fields) {
      field.controller.addListener(() => _onChanged(field));
      field.focusNode.addListener(safeNotify);
    }
  }

  void _onChanged(FormFieldModel field) {
    if (field.consumeTextChange()) safeNotify();
  }

  /// **The visibility rule.**
  ///
  /// An error is on screen when the field is invalid *and* either
  ///
  /// - the merchant is in the field and has typed something — live feedback
  ///   while they correct it, which disappears the moment the value is valid;
  ///   or
  /// - the button has been pressed, which reveals everything at once,
  ///   including fields they skipped entirely.
  ///
  /// Leaving a field does hide the message again until submit. That is the
  /// specified behaviour; persisting it after blur is a one-line change here
  /// if the flicker between fields turns out to bother anyone.
  FieldError? visibleError(FormFieldModel field) {
    final error = field.error;
    if (error == null) return null;
    if (_submitAttempted) return error;
    if (field.hasFocus && field.isDirty) return error;
    return null;
  }

  /// Validates, reveals everything if anything is wrong, and moves focus to
  /// the first offending field so the merchant is not left hunting.
  ///
  /// Returns true when the form is good to send.
  bool submit() {
    if (isValid) {
      _submitAttempted = false;
      safeNotify();
      return true;
    }

    _submitAttempted = true;
    final firstBad = fields.firstWhere((f) => !f.isValid);
    firstBad.focusNode.requestFocus();
    safeNotify();
    return false;
  }

  @override
  void dispose() {
    for (final field in fields) {
      field.dispose();
    }
    super.dispose();
  }
}
