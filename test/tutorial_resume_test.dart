import 'package:djaber_mobile/app/routes.dart';
import 'package:djaber_mobile/core/error/app_exception.dart';
import 'package:djaber_mobile/core/error/result.dart';
import 'package:djaber_mobile/data/models/agent.dart';
import 'package:djaber_mobile/data/models/product.dart';
import 'package:djaber_mobile/data/repositories/agent_repository.dart';
import 'package:djaber_mobile/data/repositories/product_repository.dart';
import 'package:djaber_mobile/presentation/viewmodels/session_view_model.dart';
import 'package:djaber_mobile/presentation/viewmodels/tutorial_agent_view_model.dart';
import 'package:djaber_mobile/presentation/viewmodels/tutorial_product_view_model.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/auth_host.dart';

/// Resuming the tutorial, and the lockout it used to cause.
///
/// The bug, in full: `tutorialPending` was persisted but the **step** was not,
/// so the router sent every returning merchant back to the intro. That looks
/// harmless and is not, because the walk forward is not repeatable — `T4`
/// creates an agent, one agent per user is enforced, and the step only
/// advanced on a successful create. A merchant who force-quit after `T4` came
/// back to a 403 they could never pass, with no `Passer` on the steps, no
/// sign-out inside the tutorial, and `T5`'s *Connecter plus tard* unreachable
/// behind it. Clearing app data or signing up again were the only ways out —
/// which is how an app manufactures duplicate accounts.
///
/// Two halves, and both are needed. The step makes the *next* merchant resume
/// correctly; the idempotent steps rescue anyone already stuck, anyone whose
/// prefs were cleared, and anyone who set their agent up on the web.
void main() {
  late SessionViewModel session;

  setUp(() async {
    session = await sessionForTest();
  });
  tearDown(() => session.dispose());

  group('the persisted step', () {
    test('a merchant who has not started resumes at the intro', () {
      expect(session.tutorialResumeRoute, Routes.tutorial);
      expect(session.tutorialStepIndex, 0);
    });

    test('each step is remembered, and resuming lands there', () async {
      await session.rememberTutorialStep(Routes.tutorialProduct);
      expect(session.tutorialResumeRoute, Routes.tutorialProduct);

      await session.rememberTutorialStep(Routes.tutorialAgent);
      expect(session.tutorialResumeRoute, Routes.tutorialAgent);
    });

    test('progress never moves backwards', () async {
      await session.rememberTutorialStep(Routes.tutorialConnect);
      // Re-walking an earlier step must not undo work already done — which is
      // exactly what would re-open the wall.
      await session.rememberTutorialStep(Routes.tutorialMode);
      expect(session.tutorialResumeRoute, Routes.tutorialConnect);
    });

    test('it survives a restart, because it is on the device', () async {
      // A cold start with the value already on disk — which is the whole
      // point of persisting it. `sessionForTest` seeds the mock store, so the
      // step has to be handed in rather than written by the previous session:
      // calling it again would reset the very store under test.
      final restarted = await sessionForTest(
        prefsValues: {'tutorial_step': Routes.tutorialAgent},
      );
      addTearDown(restarted.dispose);

      expect(restarted.tutorialResumeRoute, Routes.tutorialAgent);
      expect(restarted.tutorialStepIndex,
          Routes.tutorialFlow.indexOf(Routes.tutorialAgent));
    });

    test('a route this build does not know falls back to the intro rather '
        'than being handed to the router', () async {
      final fresh = await sessionForTest(
        prefsValues: {'tutorial_step': '/tutorial/some-old-step'},
      );
      addTearDown(fresh.dispose);

      expect(fresh.tutorialResumeRoute, Routes.tutorial);
    });

    test('finishing the tutorial clears it', () async {
      await session.rememberTutorialStep(Routes.tutorialReady);
      await session.completeTutorial();

      expect(session.tutorialPending, isFalse);
      // Left behind, it would drop a merchant who signs up again on this
      // handset into the middle of a tutorial they have never seen.
      expect(session.tutorialResumeRoute, Routes.tutorial);
    });
  });

  group('T3 treats a taken SKU as the step being done', () {
    test('advances instead of blocking, and shows no error', () async {
      final model = TutorialProductViewModel(
        products: _AlreadyExistsProducts(),
      );
      addTearDown(model.dispose);

      model.name.controller.text = 'Robe satin';
      model.sku.controller.text = 'PRD-001';
      model.costPrice.controller.text = '1000';
      model.sellingPrice.controller.text = '2000';
      model.quantity.controller.text = '5';

      final product = await model.submitAndCreate();

      expect(product, isNull, reason: 'nothing new was created');
      expect(model.alreadyExists, isTrue);
      // Not shown as a failure: the screen advances on this, so an error line
      // above the button would contradict the navigation that follows.
      expect(model.submitError, isNull);
    });

    test('a real failure still blocks', () async {
      final model = TutorialProductViewModel(products: _FailingProducts());
      addTearDown(model.dispose);

      model.name.controller.text = 'Robe satin';
      model.sku.controller.text = 'PRD-001';
      model.costPrice.controller.text = '1000';
      model.sellingPrice.controller.text = '2000';
      model.quantity.controller.text = '5';

      expect(await model.submitAndCreate(), isNull);
      expect(model.alreadyExists, isFalse);
      expect(model.submitError, isNotNull);
    });
  });

  group('T4 treats the plan limit as the step being done', () {
    test('PLAN_LIMIT_REACHED advances — this is the wall coming down',
        () async {
      final model = TutorialAgentViewModel(agents: _AtLimitAgents());
      addTearDown(model.dispose);
      model.name.controller.text = 'Assistant';

      final agent = await model.submitAndCreate();

      expect(agent, isNull);
      expect(model.alreadyExists, isTrue);
      expect(model.submitError, isNull);
    });

    test('a real failure still blocks', () async {
      final model = TutorialAgentViewModel(agents: _FailingAgents());
      addTearDown(model.dispose);
      model.name.controller.text = 'Assistant';

      expect(await model.submitAndCreate(), isNull);
      expect(model.alreadyExists, isFalse);
      expect(model.submitError, isNotNull);
    });
  });
}

/// The live 409 for a duplicate SKU, captured 2026-09-10.
class _AlreadyExistsProducts extends ProductRepository {
  _AlreadyExistsProducts() : super(api: apiForTest());

  @override
  Future<Result<Product>> create({
    required String sku,
    required String name,
    String? description,
    required double costPrice,
    required double sellingPrice,
    required int quantity,
    int minQuantity = 0,
    String? categoryId,
    String? unitId,
    bool hasVariants = false,
  }) async =>
      const Result.failure(ConflictException(
        'Un produit avec la référence « PRD-001 » existe déjà.',
        code: 'PRODUCT_SKU_ALREADY_EXISTS',
      ));
}

class _FailingProducts extends ProductRepository {
  _FailingProducts() : super(api: apiForTest());

  @override
  Future<Result<Product>> create({
    required String sku,
    required String name,
    String? description,
    required double costPrice,
    required double sellingPrice,
    required int quantity,
    int minQuantity = 0,
    String? categoryId,
    String? unitId,
    bool hasVariants = false,
  }) async =>
      const Result.failure(ServerException('boom', statusCode: 500));
}

/// The live 403 for the agent limit, captured 2026-09-10.
class _AtLimitAgents extends AgentRepository {
  _AtLimitAgents() : super(api: apiForTest());

  @override
  Future<Result<Agent>> create({
    required String name,
    required AgentPersonality personality,
    String? customInstructions,
    List<String> pageIds = const [],
  }) async =>
      const Result.failure(ForbiddenException(
        'La limite de votre plan est atteinte (1 agent).',
        code: 'PLAN_LIMIT_REACHED',
        params: {'limit': 1, 'item': 'agent'},
      ));
}

class _FailingAgents extends AgentRepository {
  _FailingAgents() : super(api: apiForTest());

  @override
  Future<Result<Agent>> create({
    required String name,
    required AgentPersonality personality,
    String? customInstructions,
    List<String> pageIds = const [],
  }) async =>
      const Result.failure(ServerException('boom', statusCode: 500));
}
