import 'package:flutter/material.dart';
import 'package:intl/intl.dart' show DateFormat;

import '../../core/extensions/responsive_extension.dart';
import '../../l10n/gen/app_localizations.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import 'app_icon.dart';

/// The calendar sheet (Figma `Clients list · date de début / de fin`,
/// `642:10225` / `642:10575`) — the web's `components/stock/DatePicker.tsx`.
///
/// A month grid, Monday first, ‹ and › to change month, the selected day in
/// white, today raised, and *Aujourd'hui* under a rule. Tapping a day picks it
/// and closes, as the web does; there is no range highlighting, because the web
/// has none.
///
/// Material's `showDatePicker` is not used: its header, colours and OK/Cancel
/// row are not the frame, and the frame is what the merchant sees.
///
/// Returns the picked day (at midnight, local), or null when dismissed.
Future<DateTime?> showDatePickerSheet(
  BuildContext context, {
  required String title,
  DateTime? initial,
}) {
  return showModalBottomSheet<DateTime>(
    context: context,
    backgroundColor: AppColors.surface,
    barrierColor: AppColors.scrim,
    isScrollControlled: true,
    builder: (_) => _DatePickerSheet(title: title, initial: initial),
  );
}

/// A day as the chips print it — `1 sept. 2026`.
String formatPickedDay(DateTime day, String localeTag) =>
    DateFormat.yMMMd(localeTag).format(day);

class _DatePickerSheet extends StatefulWidget {
  const _DatePickerSheet({required this.title, required this.initial});

  final String title;
  final DateTime? initial;

  @override
  State<_DatePickerSheet> createState() => _DatePickerSheetState();
}

class _DatePickerSheetState extends State<_DatePickerSheet> {
  late DateTime _month = DateTime((widget.initial ?? DateTime.now()).year, (widget.initial ?? DateTime.now()).month);

  static DateTime _dayOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  void _shift(int months) => setState(() => _month = DateTime(_month.year, _month.month + months));

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);
    final tag = Localizations.localeOf(context).toLanguageTag();
    final today = _dayOnly(DateTime.now());
    final selected = widget.initial == null ? null : _dayOnly(widget.initial!);

    final daysInMonth = DateTime(_month.year, _month.month + 1, 0).day;
    // Monday = 1 … Sunday = 7, so the leading blanks are weekday - 1.
    final leading = DateTime(_month.year, _month.month).weekday - 1;
    // Day-name headers from a known Monday, in the app's language.
    final monday = DateTime(2024, 1, 1);
    final dayNames = [
      for (var i = 0; i < 7; i++)
        DateFormat.E(tag).format(monday.add(Duration(days: i))).replaceAll('.', '').toUpperCase(),
    ];
    final monthTitle = DateFormat.yMMMM(tag).format(_month);
    final cell = ((MediaQuery.sizeOf(context).width - 2 * AppSpacing.gutterTight) / 7).floorToDouble();

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(AppSpacing.gutterTight, AppSpacing.sm, AppSpacing.gutterTight, AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(widget.title, style: AppText.title),
            SizedBox(height: AppSpacing.xl),
            Row(
              children: [
                _NavButton(
                  icon: AppIcons.chevronRight,
                  flip: true,
                  label: MaterialLocalizations.of(context).previousMonthTooltip,
                  onTap: () => _shift(-1),
                ),
                Expanded(
                  child: Text(
                    monthTitle[0].toUpperCase() + monthTitle.substring(1),
                    textAlign: TextAlign.center,
                    style: AppText.bodyS.copyWith(color: AppColors.textPrimary),
                  ),
                ),
                _NavButton(
                  icon: AppIcons.chevronRight,
                  flip: false,
                  label: MaterialLocalizations.of(context).nextMonthTooltip,
                  onTap: () => _shift(1),
                ),
              ],
            ),
            SizedBox(height: AppSpacing.md),
            Row(
              children: [
                for (final name in dayNames)
                  SizedBox(
                    width: cell,
                    child: Text(name, textAlign: TextAlign.center, style: AppText.labelMeta),
                  ),
              ],
            ),
            SizedBox(height: AppSpacing.sm),
            Wrap(
              children: [
                for (var i = 0; i < leading; i++) SizedBox(width: cell, height: cell),
                for (var d = 1; d <= daysInMonth; d++)
                  _DayCell(
                    size: cell,
                    day: d,
                    selected: selected == DateTime(_month.year, _month.month, d),
                    today: today == DateTime(_month.year, _month.month, d),
                    onTap: () => Navigator.of(context).pop(DateTime(_month.year, _month.month, d)),
                  ),
              ],
            ),
            SizedBox(height: AppSpacing.sm),
            const Divider(height: 1, thickness: AppStroke.hairline, color: AppColors.rule),
            TextButton(
              onPressed: () => Navigator.of(context).pop(today),
              child: Text(l10n.datePickerToday),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  const _NavButton({required this.icon, required this.flip, required this.label, required this.onTap});

  final List<String> icon;
  final bool flip;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    // ‹ points back in reading order, so it follows the layout direction.
    final rtl = Directionality.of(context) == TextDirection.rtl;
    return Semantics(
      button: true,
      label: label,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.sm),
          child: Transform.flip(
            flipX: flip != rtl,
            child: AppIcon(icon, size: 4.1.w, color: AppColors.textSecondary),
          ),
        ),
      ),
    );
  }
}

class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.size,
    required this.day,
    required this.selected,
    required this.today,
    required this.onTap,
  });

  final double size;
  final int day;
  final bool selected;
  final bool today;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox.square(
        dimension: size,
        child: Padding(
          padding: EdgeInsets.all(size * 0.08),
          child: Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
              // Selected is the white chip; today is raised one step.
              color: selected
                  ? AppColors.textPrimary
                  : today
                      ? const Color(0xFF141414)
                      : Colors.transparent,
              borderRadius: BorderRadius.circular(AppRadius.card),
            ),
            child: Text(
              '$day',
              style: AppText.bodyS.copyWith(
                color: selected ? AppColors.ink : AppColors.textPrimary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
