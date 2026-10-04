import '../../core/utils/json.dart';

/// `GET /api/pages/{id}/insights` — Facebook Page Insights, raw from Graph.
///
/// The latest daily value of each of the four metrics the backend asks for.
/// In practice Graph refuses the whole request (one metric is deprecated, and
/// an Instagram page has no such edge) and the API answers 503 — the overview
/// then shows the frame's *Statistiques indisponibles* box instead of figures.
class PageInsights {
  const PageInsights({this.followers, this.impressions, this.engagedUsers, this.postEngagements});

  final int? followers;
  final int? impressions;
  final int? engagedUsers;
  final int? postEngagements;

  bool get isEmpty =>
      followers == null && impressions == null && engagedUsers == null && postEngagements == null;

  factory PageInsights.fromJson(Map<String, dynamic> json) {
    int? latest(String name) {
      final rows = json['data'];
      if (rows is! List) return null;
      for (final row in rows.whereType<Map<String, dynamic>>()) {
        if (row['name'] != name) continue;
        final values = row['values'];
        if (values is! List || values.isEmpty) return null;
        final last = values.last;
        // A breakdown metric carries an object; only plain numbers are shown.
        final value = last is Map ? last['value'] : null;
        return value is num ? value.round() : null;
      }
      return null;
    }

    return PageInsights(
      followers: latest('page_followers_count'),
      impressions: latest('page_impressions'),
      engagedUsers: latest('page_engaged_users'),
      postEngagements: latest('page_post_engagements'),
    );
  }
}

/// *Entrants* (customer → page) or *Sortants* (page or AI → customer).
enum MessageDirection {
  incoming('incoming'),
  outgoing('outgoing');

  const MessageDirection(this.wire);
  final String wire;
}

/// One row of `GET /api/pages/{id}/messages` — the page-wide log.
///
/// [senderName] is the **customer** of the conversation, whoever wrote the
/// message (live docs); an outgoing row is shown under the page's own name.
class PageHistoryMessage {
  const PageHistoryMessage({
    required this.id,
    this.text,
    required this.timestamp,
    required this.isFromPage,
    required this.conversationId,
    this.senderName,
  });

  final String id;
  final String? text;
  final DateTime timestamp;
  final bool isFromPage;
  final String conversationId;
  final String? senderName;

  factory PageHistoryMessage.fromJson(Map<String, dynamic> json) {
    final text = Json.strOrNull(json['text']);
    final name = Json.strOrNull(json['senderName']);
    return PageHistoryMessage(
      id: Json.str(json['id']),
      text: text == null || text.trim().isEmpty ? null : text,
      timestamp: Json.date(json['timestamp']),
      isFromPage: Json.boolOf(json['isFromPage']),
      conversationId: Json.str(json['conversationId']),
      senderName: name == null || name.trim().isEmpty ? null : name.trim(),
    );
  }
}

typedef PageHistoryPage = ({List<PageHistoryMessage> messages, int total});

/// One product the vision model found in a post — a candidate, stored
/// nowhere until it is imported.
class ExtractedProduct {
  const ExtractedProduct({
    required this.postId,
    required this.name,
    this.description = '',
    this.priceDA = 0,
    this.imageUrl,
    this.category,
  });

  final String postId;
  final String name;
  final String description;

  /// 0 when no price could be read from the post.
  final int priceDA;
  final String? imageUrl;

  /// `clothing, beauty, electronics, food, accessories, home, kids, other` —
  /// the model's guess, not enforced.
  final String? category;

  factory ExtractedProduct.fromJson(Map<String, dynamic> json) => ExtractedProduct(
    postId: Json.str(json['postId']),
    name: Json.str(json['name']),
    description: Json.str(json['description']),
    priceDA: Json.intOf(json['priceDA']),
    imageUrl: Json.strOrNull(json['imageUrl']),
    category: Json.strOrNull(json['category']),
  );
}

/// `POST /api/pages/{id}/analyze`.
class PageAnalysis {
  const PageAnalysis({required this.scanned, required this.extracted, this.pageName, this.warning});

  final int scanned;
  final List<ExtractedProduct> extracted;
  final String? pageName;

  /// Set when the vision service is unavailable — then nothing was extracted.
  final String? warning;

  factory PageAnalysis.fromJson(Map<String, dynamic> json) => PageAnalysis(
    scanned: Json.intOf(json['scanned']),
    extracted: Json.list(json['extracted'], ExtractedProduct.fromJson),
    pageName: Json.strOrNull(json['pageName']),
    warning: Json.strOrNull(json['warning']),
  );
}

/// One confirmed candidate on its way to `import-products`.
class ImportProductItem {
  const ImportProductItem({
    required this.name,
    required this.priceDA,
    required this.quantity,
    this.description,
    this.imageUrl,
    this.sourcePostId,
  });

  final String name;
  final double priceDA;
  final int quantity;
  final String? description;
  final String? imageUrl;
  final String? sourcePostId;

  Map<String, dynamic> toJson() => {
    'name': name.trim(),
    'priceDA': priceDA,
    'quantity': quantity,
    if (description != null && description!.trim().isNotEmpty) 'description': description!.trim(),
    'imageUrl': ?imageUrl,
    'sourcePostId': ?sourcePostId,
  };
}

typedef ImportResult = ({int created, int skipped});
