import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../../core/utils/logger.dart';
import '../../../data/repositories/product_repository.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../viewmodels/session_view_model.dart';

/// Camera or gallery, then the bytes — shared by `18 — Ajouter un produit` and
/// the edit form, which pick photos identically.
///
/// Returns what was read; an empty list when the merchant backed out or every
/// file failed to read. The **limits are not applied here** — the view model
/// owns them, because only it knows how many slots are left on this product.
///
/// Two things this does that a bare `ImagePicker` call does not:
///
/// - **Holds the splash replay.** The camera and the gallery send the app to
///   the background, and a replay on the way back would rebuild the screen and
///   lose both the pick and the form under it.
/// - **Survives an unreadable file.** A document the picker hands back without
///   a readable path is skipped with a log line rather than taking the whole
///   pick down with it.
Future<List<ProductPhoto>> pickProductPhotos(
  BuildContext context, {
  required int limit,
}) async {
  final source = await _chooseSource(context);
  if (source == null || !context.mounted) return const [];

  final session = context.read<SessionViewModel?>();
  session?.holdSplashReplay();
  var files = const <XFile>[];
  try {
    final picker = ImagePicker();
    // Re-encoded at a sensible size: a phone camera's own photo can pass the
    // backend's 5 MB limit by itself.
    if (source == ImageSource.camera) {
      final shot = await picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 2000,
        maxHeight: 2000,
        imageQuality: 85,
      );
      files = [?shot];
    } else {
      files = await picker.pickMultiImage(
        maxWidth: 2000,
        maxHeight: 2000,
        imageQuality: 85,
        limit: limit < 1 ? 1 : limit,
      );
    }
  } on Exception catch (error) {
    Log.w('photo picker failed: $error', tag: 'products');
  } finally {
    session?.releaseSplashReplay();
  }

  final picked = <ProductPhoto>[];
  for (final file in files) {
    try {
      picked.add(ProductPhoto(name: file.name, bytes: await file.readAsBytes()));
    } on Exception catch (error) {
      Log.w('could not read ${file.name}: $error', tag: 'products');
    }
  }
  return picked;
}

Future<ImageSource?> _chooseSource(BuildContext context) {
  final l10n = L10n.of(context);
  return showModalBottomSheet<ImageSource>(
    context: context,
    backgroundColor: AppColors.surface,
    barrierColor: AppColors.scrim,
    builder: (sheet) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final (source, label) in [
            (ImageSource.camera, l10n.productPhotoCamera),
            (ImageSource.gallery, l10n.productPhotoGallery),
          ])
            ListTile(
              title: Text(
                label,
                style: AppText.bodyS.copyWith(color: AppColors.textPrimary),
              ),
              onTap: () => Navigator.of(sheet).pop(source),
            ),
        ],
      ),
    ),
  );
}
