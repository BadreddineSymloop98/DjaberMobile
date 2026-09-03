import 'package:flutter/material.dart';

/// The palette, taken verbatim from `src/app/globals.css` in the web app.
///
/// The rule the web states and mobile follows: *"accent is just white —
/// confidence through contrast."* One surface value, hairline borders, and
/// emphasis carried by weight, size and opacity. No coloured tags.
///
/// The CSS custom property each value maps to is named on every line, so a
/// change on either platform is traceable to the other.
class AppColors {
  const AppColors._();

  // ---- Ground and surfaces ----

  /// `--ink` — page background, true black.
  static const ink = Color(0xFF000000);

  /// `--ink-2` — cards and surfaces.
  static const surface = Color(0xFF0A0A0A);

  /// `--ink-3` — a slightly lighter surface, for a raised element on a surface.
  static const surfaceHigh = Color(0xFF141414);

  /// Mobile-only, no web equivalent yet. Reserved for the depth language that
  /// was built and then dropped (brief §15) — kept so restoring it is a token
  /// edit. If it ever lands on the web, call it `--ink-4`.
  static const surfaceRaised = Color(0xFF1C1C1C);

  // ---- Text ----

  /// `--paper` — primary text.
  static const textPrimary = Color(0xFFFFFFFF);

  /// `--paper-dim` — secondary text.
  static const textSecondary = Color(0xFFA3A3A3);

  /// `--mute` — tertiary text and labels.
  static const textMuted = Color(0xFF666666);

  // ---- Lines ----

  /// `--rule` — hairline borders, white at 8%.
  static const rule = Color(0x14FFFFFF);

  /// `--rule-strong` — white at 18%. The web's own mechanism for urgency:
  /// a waiting escalation takes this border, a handled one takes [rule].
  static const ruleStrong = Color(0x2EFFFFFF);

  // ---- Semantics ----

  /// `--live` — the single semantic colour. Means live/active, which is the
  /// opposite of "needs a human". Never reuse it for an alert.
  static const live = Color(0xFF34D399);

  /// `--live-dim` — the halo behind the pulsing live dot.
  static const liveDim = Color(0x2E34D399);

  // ---- Category accents ----
  //
  // From the six places colour appears in the web's icon set
  // (`src/components/ui/icons.tsx`). Colour marks a category, never decoration.

  /// `text-emerald-400` — money and success. Same value as [live].
  static const accentMoney = Color(0xFF34D399);

  /// `text-red-400` — alerts and negative movement.
  static const accentAlert = Color(0xFFF87171);

  /// `text-blue-400` — incoming, positive movement.
  static const accentInbound = Color(0xFF60A5FA);

  /// `text-amber-400` — starred.
  static const accentStarred = Color(0xFFFBBF24);

  /// `text-orange-400` — orders and carts.
  static const accentOrders = Color(0xFFFB923C);

  /// `text-violet-400` — people.
  static const accentClients = Color(0xFFA78BFA);

  // ---- Derived ----

  /// Fill for an input. The web uses white at 6% over the ink ground.
  static const inputFill = Color(0x0FFFFFFF);

  /// A pressed or hovered surface.
  static const overlay = Color(0x0AFFFFFF);

  /// Scrim behind a sheet or dialog.
  static const scrim = Color(0xCC000000);
}
