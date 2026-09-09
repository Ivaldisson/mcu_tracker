import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Sectiekop voor een jaar in de chronologische (story-order) weergave.
class YearHeader extends StatelessWidget {
  final int year;
  const YearHeader({super.key, required this.year});

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.onSurfaceVariant;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 4),
      child: Row(
        children: [
          Text(
            year.toString(),
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
              color: color,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Divider(color: color.withValues(alpha: 0.4), thickness: 1),
          ),
        ],
      ),
    );
  }
}

/// Subsectiekop voor een maand binnen een jaar-sectie.
class MonthHeader extends StatelessWidget {
  final DateTime date;
  const MonthHeader({super.key, required this.date});

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.onSurfaceVariant;
    final locale = Localizations.localeOf(context).toString();
    final monthName = DateFormat.MMMM(locale).format(date);

    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 8, 16, 4),
      child: Text(
        monthName.toUpperCase(),
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.2,
          color: color.withValues(alpha: 0.7),
        ),
      ),
    );
  }
}
