import 'package:flutter/widgets.dart';

import '../../../core/utils/money.dart';
import '../../../data/models/plan.dart';
import '../../../l10n/gen/app_localizations.dart';

/// The plans' names, descriptions and features, in the app's language.
///
/// `GET /api/plans` returns whatever the admin typed — French on the live
/// backend — and ignores `Accept-Language`. The web shows it as sent, so an
/// Arabic merchant reads French offers. The app translates them instead
/// (decided 2026-09-15).
///
/// **Recognised, never guessed.** Each piece of server text is matched against
/// the French the backend is known to send: an exact sentence, or a pattern
/// that carries a number (`5 000 crédits IA / mois`, `3 pages Facebook /
/// Instagram`). A match is rendered from the ARB files with the server's own
/// numbers, so a changed quota still reads correctly. Anything that does not
/// match — the admin edited a description or added a feature — is shown as
/// sent: an untranslated line is better than a translation of the wrong text.
class PlanCopy {
  PlanCopy(this.l10n, this.localeTag);

  factory PlanCopy.of(BuildContext context) =>
      PlanCopy(L10n.of(context), Localizations.localeOf(context).toLanguageTag());

  final L10n l10n;
  final String localeTag;

  /// Known names per slug. A renamed plan keeps its new name as sent.
  static const _names = {'individual': 'Individual', 'pro': 'Pro', 'teams': 'Teams'};

  static const _descriptions = {
    'individual': "Pour démarrer: connectez votre page et laissez l'IA répondre à vos clients.",
    'pro': 'Pour les vendeurs actifs: vision, notes vocales et plus de volume.',
    'teams': 'Pour les boutiques établies: volume maximal et priorité support.',
  };

  /// A group of digits as the backend writes them: `500`, `5 000`, `20 000`.
  static const _number = r'(\d{1,3}(?:[   ]\d{3})+|\d+)';

  static final _pages = RegExp(r'^(\d+) pages? facebook (?:ou|/) instagram$', caseSensitive: false);
  static final _credits = RegExp('^$_number crédits ia / mois\$', caseSensitive: false);
  static final _products = RegExp('^$_number produits\$', caseSensitive: false);
  static final _delivery = RegExp(r'^livraison (\d+) wilayas \((.+)\)$', caseSensitive: false);

  String name(Plan plan) =>
      _names[plan.slug] == _normalize(plan.name) ? _nameFor(plan.slug) ?? plan.name : plan.name;

  /// For `User.plan` when the plans have not loaded: the known name, or the
  /// slug capitalised as before.
  String nameForSlug(String slug) =>
      _nameFor(slug) ?? (slug.isEmpty ? slug : '${slug[0].toUpperCase()}${slug.substring(1)}');

  String? _nameFor(String slug) => switch (slug) {
        'individual' => l10n.planNameIndividual,
        'pro' => l10n.planNamePro,
        'teams' => l10n.planNameTeams,
        _ => null,
      };

  String? description(Plan plan) {
    final sent = plan.description;
    if (sent == null) return null;
    if (_descriptions[plan.slug] != _normalize(sent)) return sent;
    return switch (plan.slug) {
      'individual' => l10n.planDescIndividual,
      'pro' => l10n.planDescPro,
      'teams' => l10n.planDescTeams,
      _ => sent,
    };
  }

  List<String> features(Plan plan) => [for (final feature in plan.features) this.feature(feature)];

  String feature(String sent) {
    final text = _normalize(sent);

    final fixed = switch (text.toLowerCase()) {
      'agent ia 24/7 (texte)' => l10n.planFeatureAgentText,
      'agent ia 24/7 (texte + images + vocal)' => l10n.planFeatureAgentFull,
      'gestion de stock & commandes' => l10n.planFeatureStock,
      'confirmation par appel' => l10n.planFeatureCallConfirmation,
      "reconnaissance d'images (vision)" => l10n.planFeatureVision,
      'notes vocales (transcription)' => l10n.planFeatureVoiceNotes,
      'cross-sell / up-sell ia' => l10n.planFeatureCrossSell,
      'produits illimités' => l10n.planFeatureUnlimitedProducts,
      'conversations illimitées' => l10n.planFeatureUnlimitedConversations,
      'toutes les fonctionnalités pro' => l10n.planFeatureEverythingPro,
      'support prioritaire' => l10n.planFeaturePrioritySupport,
      _ => null,
    };
    if (fixed != null) return fixed;

    final pages = _pages.firstMatch(text);
    if (pages != null) return l10n.planFeaturePages(int.parse(pages.group(1)!));

    final credits = _credits.firstMatch(text);
    if (credits != null) return l10n.planFeatureCredits(_grouped(credits.group(1)!));

    final products = _products.firstMatch(text);
    if (products != null) return l10n.planFeatureProducts(_grouped(products.group(1)!));

    final delivery = _delivery.firstMatch(text);
    if (delivery != null) {
      return l10n.planFeatureDelivery(int.parse(delivery.group(1)!), delivery.group(2)!);
    }

    return sent;
  }

  /// `5 000` → `5000` → grouped for the app's locale.
  String _grouped(String digits) =>
      Money.grouped(int.parse(digits.replaceAll(RegExp(r'[   ]'), '')), localeTag);

  /// Typographic apostrophes and stray spaces must not defeat a match.
  static String _normalize(String text) =>
      text.replaceAll('’', "'").replaceAll(RegExp(r'\s+'), ' ').trim();
}
