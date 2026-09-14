import '../../core/utils/json.dart';

/// Which network a Page lives on.
enum PagePlatform {
  facebook('facebook'),
  instagram('instagram');

  const PagePlatform(this.wireName);

  final String wireName;

  static PagePlatform fromName(String? value) =>
      value == 'instagram' ? PagePlatform.instagram : PagePlatform.facebook;
}

/// A connected Facebook Page or Instagram professional account.
///
/// From `model Page` in `schema.prisma`. Named `ConnectedPage` here because
/// `Page` is Flutter's own routing class and the collision would be constant.
///
/// The access token is deliberately **not** modelled: the backend keeps it
/// encrypted and its own `getUserPages` `select` does not return it. Nothing
/// on the phone should ever hold it.
class ConnectedPage {
  const ConnectedPage({
    required this.id,
    required this.platform,
    required this.pageId,
    required this.pageName,
    this.pageAvatar,
    this.isActive = true,
    this.createdAt,
  });

  /// Our row id — this is what `pageIds` on an agent refers to, **not**
  /// [pageId], which is Meta's own identifier. Getting these two the wrong way
  /// round silently links nothing.
  final String id;

  final PagePlatform platform;

  /// Meta's page identifier.
  final String pageId;

  final String pageName;
  final String? pageAvatar;
  final bool isActive;
  final DateTime? createdAt;

  bool get isInstagram => platform == PagePlatform.instagram;

  factory ConnectedPage.fromJson(Map<String, dynamic> json) => ConnectedPage(
        id: Json.str(json['id']),
        platform: PagePlatform.fromName(Json.strOrNull(json['platform'])),
        pageId: Json.str(json['pageId']),
        pageName: Json.str(json['pageName']),
        pageAvatar: Json.strOrNull(json['pageAvatar']),
        isActive: Json.boolOf(json['isActive'], true),
        createdAt: Json.dateOrNull(json['createdAt']),
      );
}
