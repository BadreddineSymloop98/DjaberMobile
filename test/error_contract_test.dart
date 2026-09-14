import 'package:dio/dio.dart';
import 'package:djaber_mobile/core/error/app_exception.dart';
import 'package:djaber_mobile/core/network/interceptors/error_interceptor.dart';
import 'package:djaber_mobile/l10n/gen/app_localizations_ar.dart';
import 'package:djaber_mobile/l10n/gen/app_localizations_fr.dart';
import 'package:djaber_mobile/presentation/widgets/api_error_message.dart';
import 'package:flutter_test/flutter_test.dart';

/// The backend's error contract, as it actually answers.
///
/// **Every body below is a real response**, captured from
/// `https://djaber.72-60-190-211.sslip.io` on 2026-09-10 by calling the
/// endpoints the app calls. Nothing here is invented, because the previous
/// version of this suite was built on a corpus of English literals the server
/// no longer sends — it passed while describing a backend that had been
/// replaced. Real bodies are the only defence against that.
AppException parse(int status, Object? body) =>
    ErrorInterceptor.toAppException(DioException(
      requestOptions: RequestOptions(path: '/api/x'),
      type: DioExceptionType.badResponse,
      response: Response<dynamic>(
        requestOptions: RequestOptions(path: '/api/x'),
        statusCode: status,
        data: body,
      ),
    ));

void main() {
  final fr = L10nFr();
  final ar = L10nAr();

  group('the shape', () {
    test('401 on a wrong password', () {
      final e = parse(401, {
        'error': 'Unauthorized',
        'code': 'AUTH_INVALID_CREDENTIALS',
        'message': 'E-mail ou mot de passe incorrect.',
      });

      expect(e, isA<UnauthorizedException>());
      expect(e.code, 'AUTH_INVALID_CREDENTIALS');
      expect(e.isUnauthorized, isTrue);
      expect(e.isRetryable, isFalse);
      // Shown verbatim — it is already French.
      expect(apiErrorMessage(e, fr), 'E-mail ou mot de passe incorrect.');
    });

    test('409 on a duplicate SKU, with the value in params', () {
      final e = parse(409, {
        'error': 'Conflict',
        'code': 'PRODUCT_SKU_ALREADY_EXISTS',
        'message': 'Un produit avec la référence « PRD-131304 » existe déjà.',
        'params': {'sku': 'PRD-131304'},
      });

      expect(e, isA<ConflictException>());
      expect(e.code, 'PRODUCT_SKU_ALREADY_EXISTS');
      expect(e.params['sku'], 'PRD-131304');
      // A duplicate is not a validation failure: nothing is malformed, the
      // value is taken.
      expect(e.isValidation, isFalse);
      expect(e.isRetryable, isFalse);
    });

    test('403 on the agent limit, with the limit in params', () {
      final e = parse(403, {
        'error': 'Forbidden',
        'code': 'PLAN_LIMIT_REACHED',
        'message': 'La limite de votre plan est atteinte (1 agent). '
            'Passez à un plan supérieur pour en ajouter.',
        'params': {'limit': 1, 'item': 'agent'},
      });

      expect(e, isA<ForbiddenException>());
      expect(e.code, 'PLAN_LIMIT_REACHED');
      // The number on its own, for an upsell that needs it outside the
      // sentence.
      expect(e.params['limit'], 1);
      expect(e.isRetryable, isFalse);
    });

    test('400 names the faulted input', () {
      final e = parse(400, {
        'error': 'Bad Request',
        'code': 'VALIDATION_FAILED',
        'message': 'Certains champs sont invalides. '
            'Veuillez vérifier le formulaire.',
        'fields': [
          {
            'field': 'quantity',
            'code': 'FIELD_MUST_BE_POSITIVE',
            'message': 'Le champ « quantity » doit être supérieur à zéro.',
            'params': {'field': 'quantity'},
          },
        ],
      });

      expect(e.isValidation, isTrue);
      expect(e.fields, hasLength(1));
      expect(e.fields.single.code, 'FIELD_MUST_BE_POSITIVE');
      expect(
        e.fieldMessage('quantity'),
        'Le champ « quantity » doit être supérieur à zéro.',
      );
      expect(e.fieldMessage('sku'), isNull);
      expect(e.fieldMessages.keys, ['quantity']);
    });

    test('two faulted inputs on a login, from the artifact own example', () {
      final e = parse(400, {
        'code': 'VALIDATION_FAILED',
        'message': 'Certains champs sont invalides. '
            'Veuillez vérifier le formulaire.',
        'fields': [
          {
            'field': 'email',
            'code': 'FIELD_INVALID_EMAIL',
            'message': 'Veuillez saisir une adresse e-mail valide.',
          },
          {
            'field': 'password',
            'code': 'AUTH_PASSWORD_REQUIRED',
            'message': 'Le mot de passe est obligatoire.',
          },
        ],
      });

      expect(e.fieldMessages, {
        'email': 'Veuillez saisir une adresse e-mail valide.',
        'password': 'Le mot de passe est obligatoire.',
      });
    });

    test('404 on a product', () {
      final e = parse(404, {
        'code': 'PRODUCT_NOT_FOUND',
        'message': 'Produit introuvable.',
      });

      expect(e, isA<NotFoundException>());
      expect(apiErrorMessage(e, fr), 'Produit introuvable.');
    });

    test('the route 404 is translated too, and carries the path in params '
        'rather than in the message', () {
      final e = parse(404, {
        'error': 'Not Found',
        'code': 'ROUTE_NOT_FOUND',
        'message': 'لا يمكن تنفيذ GET /api/nope.',
        'params': {'method': 'GET', 'path': '/api/nope'},
      });

      expect(e.code, 'ROUTE_NOT_FOUND');
      expect(e.params['path'], '/api/nope');
    });
  });

  group('the statuses the app had never handled', () {
    test('402 — credits spent, which is when the AI stops replying', () {
      final e = parse(402, {
        'code': 'INSUFFICIENT_CREDITS',
        'message': 'Vos crédits IA sont épuisés.',
      });
      expect(e, isA<PaymentRequiredException>());
      expect(e.isRetryable, isFalse);
    });

    test('422 — a business rule the merchant resolves', () {
      final e = parse(422, {
        'code': 'ORDER_DELETE_DELIVERED',
        'message': 'Une commande livrée ne peut pas être supprimée.',
      });
      expect(e, isA<BusinessRuleException>());
      expect(e.isBusinessRule, isTrue);
      expect(e.isRetryable, isFalse);
      // Shown as-is. Flattening this is the difference between a merchant
      // fixing their own order and phoning support.
      expect(
        apiErrorMessage(e, fr),
        'Une commande livrée ne peut pas être supprimée.',
      );
    });

    test('413 — too large, with the limit in params', () {
      final e = parse(413, {
        'code': 'FILE_TOO_LARGE',
        'message': 'Le fichier dépasse 5 Mo.',
        'params': {'maxMb': 5},
      });
      expect(e, isA<PayloadTooLargeException>());
      expect(e.params['maxMb'], 5);
    });

    test('429 — retryable, unlike every other 4xx', () {
      final e = parse(429, {
        'code': 'TOO_MANY_REQUESTS',
        'message': 'Trop de requêtes. Réessayez dans un instant.',
      });
      expect(e, isA<RateLimitedException>());
      expect(e.isRetryable, isTrue);
    });

    test('502 — Meta, the courier or the AI is down', () {
      final e = parse(502, {
        'code': 'REPLY_SEND_FAILED',
        'message': 'Facebook a refusé l\'envoi.',
      });
      expect(e, isA<ServerException>());
      expect(e.isRetryable, isTrue);
    });
  });

  group('no 4xx is retryable, and every 5xx is', () {
    test('the whole set', () {
      for (final status in const [400, 401, 402, 403, 404, 409, 413, 422]) {
        expect(
          parse(status, {'message': 'x'}).isRetryable,
          isFalse,
          reason: '$status must not be retried — the answer will not change',
        );
      }
      for (final status in const [429, 500, 502, 503, 504]) {
        expect(parse(status, {'message': 'x'}).isRetryable, isTrue,
            reason: '$status is worth another try');
      }
    });
  });

  group('display', () {
    test('a transport failure gets the app copy, because no server said '
        'anything', () {
      const network = NetworkException();
      expect(apiErrorMessage(network, fr), fr.errorNetwork);
      expect(apiErrorMessage(const TimeoutException(), fr), fr.errorTimeout);
      // And never its own English placeholder.
      expect(apiErrorMessage(network, fr), isNot('No connection'));
    });

    test('a body with no message falls back to the generic line', () {
      expect(apiErrorMessage(parse(400, <String, dynamic>{}), fr),
          fr.errorGeneric);
      expect(apiErrorMessage(parse(500, 'not json'), fr), fr.errorServer);
    });

    test('the legacy `error` label is never shown — it is HTTP jargon', () {
      // The contract documents `error` as legacy and says to ignore it.
      final e = parse(409, {'error': 'Conflict'});
      expect(apiErrorMessage(e, fr), isNot('Conflict'));
      expect(apiErrorMessage(e, fr), fr.errorGeneric);
    });

    test('the same failure in Arabic shows the Arabic the server sent',
        () {
      final e = parse(401, {
        'code': 'UNAUTHORIZED',
        'message': 'يجب تسجيل الدخول للقيام بهذا الإجراء.',
      });

      // Not re-translated, and not replaced by our own string.
      expect(apiErrorMessage(e, ar), 'يجب تسجيل الدخول للقيام بهذا الإجراء.');
      expect(apiErrorMessage(e, ar), isNot(ar.errorUnauthorized));
    });
  });

  group('back-compatibility with the pre-contract shape', () {
    test('express-validator errors[] still binds to inputs, since the '
        'backend sends it alongside fields[]', () {
      final e = parse(400, {
        'errors': [
          {
            'msg': 'Veuillez saisir une adresse e-mail valide.',
            'path': 'email',
            'location': 'body',
          },
        ],
      });

      expect(e.fieldMessage('email'),
          'Veuillez saisir une adresse e-mail valide.');
    });

    test('fields[] wins when both are present, because it carries the codes',
        () {
      final e = parse(400, {
        'fields': [
          {'field': 'sku', 'code': 'FIELD_REQUIRED', 'message': 'A'},
        ],
        'errors': [
          {'path': 'sku', 'msg': 'B'},
        ],
      });

      expect(e.fieldMessage('sku'), 'A');
      expect(e.fields.single.code, 'FIELD_REQUIRED');
    });

    test('a nameless or wordless field entry is dropped, not shown empty',
        () {
      final e = parse(400, {
        'fields': [
          {'field': '', 'message': 'orphan'},
          {'field': 'sku', 'message': ''},
          {'field': 'name', 'message': 'Le nom est obligatoire.'},
        ],
      });

      expect(e.fieldMessages, {'name': 'Le nom est obligatoire.'});
    });
  });
}
