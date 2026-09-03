import 'package:djaber_mobile/core/utils/validators.dart';
import 'package:djaber_mobile/presentation/viewmodels/form_field_model.dart';
import 'package:djaber_mobile/presentation/viewmodels/login_view_model.dart';
import 'package:djaber_mobile/presentation/viewmodels/signup_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Validators — the rules the backend actually enforces', () {
    test('email must be present and plausible', () {
      expect(Validators.email(''), FieldError.required);
      expect(Validators.email('   '), FieldError.required);
      expect(Validators.email('amina'), FieldError.invalidEmail);
      // The mistake merchants actually make: no dot in the domain.
      expect(Validators.email('amina@shop'), FieldError.invalidEmail);
      expect(Validators.email('amina@@shop.dz'), FieldError.invalidEmail);
      expect(Validators.email('amina@shop.dz'), isNull);
      expect(Validators.email("o'neil+tag@sub.shop.co.uk"), isNull);
    });

    test('login only requires a non-empty password', () {
      // Deliberate: an account created before the 8-character rule must still
      // be able to sign in, and the server agrees.
      expect(Validators.password(''), FieldError.required);
      expect(Validators.password('abc'), isNull);
    });

    test('sign-up enforces the 8-character minimum', () {
      expect(Validators.newPassword(''), FieldError.required);
      expect(Validators.newPassword('1234567'), FieldError.tooShort);
      expect(Validators.newPassword('12345678'), isNull);
    });

    test('a password keeps its spaces', () {
      // Trimming would create the account with a different secret than the one
      // the merchant typed.
      expect(Validators.newPassword('  pass  '), isNull);
      expect(Validators.newPassword('       '), FieldError.tooShort);
    });

    test('a name of only spaces is not a name', () {
      expect(Validators.name(''), FieldError.required);
      expect(Validators.name('   '), FieldError.required);
      expect(Validators.name('Amina'), isNull);
    });
  });

  group('submit — no focus needed', () {
    late LoginViewModel model;

    setUp(() => model = LoginViewModel());
    tearDown(() => model.dispose());

    test('an untouched form says nothing', () {
      expect(model.visibleError(model.email), isNull);
      expect(model.visibleError(model.password), isNull);
    });

    test('submitting an empty form reveals every error at once', () {
      expect(model.submit(), isFalse);
      expect(model.submitAttempted, isTrue);
      expect(model.visibleError(model.email), FieldError.required);
      // Including the field that was never touched.
      expect(model.visibleError(model.password), FieldError.required);
    });

    test('errors clear one by one as the form is fixed', () {
      model.submit();
      model.email.controller.text = 'amina@shop.dz';

      expect(model.visibleError(model.email), isNull);
      expect(model.visibleError(model.password), FieldError.required,
          reason: 'the other field is still wrong');
    });

    test('a valid form submits and clears the revealed state', () {
      model.email.controller.text = 'amina@shop.dz';
      model.password.controller.text = 'secret';

      expect(model.isValid, isTrue);
      expect(model.submit(), isTrue);
      expect(model.submitAttempted, isFalse);
    });
  });

  group('live validation — needs a real focus tree', () {
    /// The visibility rule reads `FocusNode.hasFocus`, which only reports
    /// truthfully once the node is attached to a widget tree. Testing it
    /// without one passes for the wrong reason.
    Future<void> mount(WidgetTester tester, FormViewModel model) {
      return tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                for (final field in model.fields)
                  TextField(
                    controller: field.controller,
                    focusNode: field.focusNode,
                  ),
              ],
            ),
          ),
        ),
      );
    }

    testWidgets('focusing a field is not yet a mistake', (tester) async {
      final model = LoginViewModel();
      addTearDown(model.dispose);
      await mount(tester, model);

      model.email.focusNode.requestFocus();
      await tester.pump();

      expect(model.email.hasFocus, isTrue);
      // Nothing typed — the merchant is about to fill it in, and the form
      // should not argue with them before they start.
      expect(model.visibleError(model.email), isNull);
    });

    testWidgets('typing an invalid value while focused shows the error live',
        (tester) async {
      final model = LoginViewModel();
      addTearDown(model.dispose);
      await mount(tester, model);

      await tester.enterText(find.byType(TextField).first, 'amina@');
      await tester.pump();

      expect(model.visibleError(model.email), FieldError.invalidEmail);
    });

    testWidgets('the error disappears the moment the value becomes valid',
        (tester) async {
      final model = LoginViewModel();
      addTearDown(model.dispose);
      await mount(tester, model);

      final emailField = find.byType(TextField).first;
      await tester.enterText(emailField, 'amina@');
      await tester.pump();
      expect(model.visibleError(model.email), isNotNull);

      await tester.enterText(emailField, 'amina@shop.dz');
      await tester.pump();
      expect(model.visibleError(model.email), isNull);
    });

    testWidgets('leaving a field hides the message again until submit',
        (tester) async {
      final model = LoginViewModel();
      addTearDown(model.dispose);
      await mount(tester, model);

      await tester.enterText(find.byType(TextField).first, 'amina@');
      await tester.pump();
      expect(model.visibleError(model.email), isNotNull);

      // Move to the password field.
      model.password.focusNode.requestFocus();
      await tester.pump();

      // This is the specified behaviour, pinned so a change to it is a
      // deliberate one rather than a regression.
      expect(model.visibleError(model.email), isNull);

      expect(model.submit(), isFalse);
      expect(model.visibleError(model.email), FieldError.invalidEmail);
    });

    testWidgets('a failed submit moves focus to the first bad field',
        (tester) async {
      final model = LoginViewModel();
      addTearDown(model.dispose);
      await mount(tester, model);

      model.email.controller.text = 'amina@shop.dz';
      model.submit();
      await tester.pump();

      expect(model.password.hasFocus, isTrue);
    });
  });

  group('sign-up form', () {
    late SignupViewModel model;

    setUp(() => model = SignupViewModel());
    tearDown(() => model.dispose());

    test('collects exactly the four fields the register endpoint wants', () {
      expect(model.fields.length, 4);
    });

    test('a short password blocks submission', () {
      model.firstName.controller.text = 'Amina';
      model.lastName.controller.text = 'Benali';
      model.email.controller.text = 'amina@shop.dz';
      model.password.controller.text = 'court';

      expect(model.submit(), isFalse);
      expect(model.visibleError(model.password), FieldError.tooShort);
    });

    test('a complete form is valid', () {
      model.firstName.controller.text = 'Amina';
      model.lastName.controller.text = 'Benali';
      model.email.controller.text = 'amina@shop.dz';
      model.password.controller.text = 'motdepasse';

      expect(model.submit(), isTrue);
    });
  });
}
