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

  String _lastText;

  String get value => controller.text;
  bool get hasFocus => focusNode.hasFocus;

  /// Reports whether the *text* changed, so the form only repaints when it
  /// actually needs to.
  ///
  /// A [TextEditingController] also notifies on selection changes — and
  /// focusing a `TextField` moves the caret, which counts. Repainting on
  /// every caret move is waste on the hardware this app targets.
  bool consumeTextChange() {
    if (controller.text == _lastText) return false;
    _lastText = controller.text;
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
  /// - the field has focus — from the moment it is tapped, so an empty
  ///   required field says so immediately, and the message clears as soon as
  ///   the value becomes valid; or
  /// - the button has been pressed, which reveals everything at once,
  ///   including fields never touched.
  ///
  /// Leaving a field hides its message again until submit.
  FieldError? visibleError(FormFieldModel field) {
    final error = field.error;
    if (error == null) return null;
    return (field.hasFocus || _submitAttempted) ? error : null;
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
