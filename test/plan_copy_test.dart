import 'package:djaber_mobile/core/utils/money.dart';
import 'package:djaber_mobile/data/models/plan.dart';
import 'package:djaber_mobile/l10n/gen/app_localizations.dart';
import 'package:djaber_mobile/presentation/screens/settings/plan_copy.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

/// The plans arrive in the admin's French whatever the app's language; the
/// settings screen must show them in Arabic and English too.
///
/// The fixtures are the live `GET /api/plans` texts (2026-09-15).
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const pro = Plan(
    id: 'e93c207b',
    slug: 'pro',
    name: 'Pro',
    description: 'Pour les vendeurs actifs: vision, notes vocales et plus de volume.',
    priceMonthly: 2900,
    priceYearly: 29000,
    features: [
      '3 pages Facebook / Instagram',
      'Agent IA 24/7 (texte + images + vocal)',
      '5 000 crédits IA / mois',
      '500 produits',
      "Reconnaissance d'images (vision)",
      'Notes vocales (transcription)',
      'Livraison 58 wilayas (Yalidine, ZR Express, Maystro)',
      'Cross-sell / Up-sell IA',
    ],
    isFeatured: true,
  );

  const individual = Plan(
    id: '64830ecf',
    slug: 'individual',
    name: 'Individual',
    description: "Pour démarrer: connectez votre page et laissez l'IA répondre à vos clients.",
    features: [
      '1 page Facebook ou Instagram',
      'Agent IA 24/7 (texte)',
      '500 crédits IA / mois',
      '50 produits',
      'Gestion de stock & commandes',
      'Confirmation par appel',
    ],
  );

  const teams = Plan(
    id: '76a23b79',
    slug: 'teams',
    name: 'Teams',
    description: 'Pour les boutiques établies: volume maximal et priorité support.',
    features: [
      '10 pages Facebook / Instagram',
      'Agent IA 24/7 (texte + images + vocal)',
      '20 000 crédits IA / mois',
      'Produits illimités',
      'Conversations illimitées',
      'Toutes les fonctionnalités Pro',
      'Support prioritaire',
    ],
  );

  final latin = RegExp('[A-Za-zÀ-ÿ]{4,}');
  // Brand names that stay as they are in Arabic.
  const brands = ['Facebook', 'Instagram', 'Yalidine', 'ZR Express', 'Maystro'];
  String withoutBrands(String text) => brands.fold(text, (t, b) => t.replaceAll(b, ''));

  test('in Arabic, every live plan text is translated — no French left', () async {
    final ar = await L10n.delegate.load(const Locale('ar'));
    final copy = PlanCopy(ar, 'ar');

    for (final plan in [individual, pro, teams]) {
      final texts = [copy.name(plan), copy.description(plan)!, ...copy.features(plan)];
      for (final text in texts) {
        expect(withoutBrands(text), isNot(contains(latin)), reason: '"$text" (${plan.slug}) is still Latin');
      }
    }
    expect(copy.name(pro), ar.planNamePro);
    expect(copy.description(teams), ar.planDescTeams);
  });

  test('the server numbers are kept, grouped for the locale', () async {
    final ar = await L10n.delegate.load(const Locale('ar'));
    final copy = PlanCopy(ar, 'ar');

    expect(copy.feature('20 000 crédits IA / mois'), ar.planFeatureCredits(Money.grouped(20000, 'ar')));
    expect(copy.feature('3 pages Facebook / Instagram'), ar.planFeaturePages(3));
    expect(copy.feature('Livraison 58 wilayas (Yalidine, ZR Express, Maystro)'),
        ar.planFeatureDelivery(58, 'Yalidine, ZR Express, Maystro'));

    final en = await L10n.delegate.load(const Locale('en'));
    expect(PlanCopy(en, 'en').feature('5 000 crédits IA / mois'), '5,000 AI credits / month');
  });

  test('text the admin changed is shown as sent, never mistranslated', () async {
    final ar = await L10n.delegate.load(const Locale('ar'));
    final copy = PlanCopy(ar, 'ar');

    const edited = Plan(
      id: 'x',
      slug: 'pro',
      name: 'Pro+',
      description: 'Nouvelle offre de rentrée.',
      features: ['Formation personnalisée'],
    );
    expect(copy.name(edited), 'Pro+');
    expect(copy.description(edited), 'Nouvelle offre de rentrée.');
    expect(copy.features(edited), ['Formation personnalisée']);
  });

  test('in French, the recognised texts read as the backend wrote them', () async {
    final fr = await L10n.delegate.load(const Locale('fr'));
    final copy = PlanCopy(fr, 'fr');

    expect(copy.feature('Agent IA 24/7 (texte)'), 'Agent IA 24/7 (texte)');
    expect(copy.feature('50 produits'), '50 produits');
    expect(copy.name(individual), 'Individual');
  });
}
