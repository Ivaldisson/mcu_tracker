import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../l10n/app_localizations.dart';
import '../services/content_provider.dart';

class SkipDrawer extends ConsumerWidget {
  const SkipDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context)!;
    final notifier = ref.read(contentProvider.notifier);
    final sortMode = ref.watch(sortModeProvider);

    return Drawer(
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              t.sortSectionTitle,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 4),
            Text(
              t.sortSectionDescription,
              style: const TextStyle(fontSize: 13, color: Colors.grey),
            ),
            const SizedBox(height: 12),
            RadioGroup<SortMode>(
              groupValue: sortMode,
              onChanged: (value) => _setSortMode(ref, value!),
              child: Column(
                children: [
                  RadioListTile<SortMode>(
                    contentPadding: EdgeInsets.zero,
                    title: Text(t.sortStoryOrder),
                    value: SortMode.story,
                  ),
                  RadioListTile<SortMode>(
                    contentPadding: EdgeInsets.zero,
                    title: Text(t.sortReleaseOrder),
                    value: SortMode.release,
                  ),
                ],
              ),
            ),
            const Divider(height: 32),
            Text(
              t.bulkSkipTitle,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 4),
            Text(
              t.bulkSkipDescription,
              style: const TextStyle(fontSize: 13, color: Colors.grey),
            ),
            const SizedBox(height: 20),
            _skipRow(context, t, notifier, t.skipOptionalLow, ['low']),
            _skipRow(
                context, t, notifier, t.skipMediumOptional, ['medium', 'low']),
            _skipRow(
              context,
              t,
              notifier,
              t.skipEverythingExceptCritical,
              ['high', 'medium', 'low'],
            ),
            const Divider(height: 32),
            TextButton.icon(
              icon: const Icon(Icons.restart_alt),
              label: Text(t.reenableEverything),
              onPressed: () {
                notifier.bulkSetSkipped(
                  ['critical', 'high', 'medium', 'low'],
                  false,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _setSortMode(WidgetRef ref, SortMode mode) async {
    ref.read(sortModeProvider.notifier).state = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('sort_mode', mode == SortMode.release ? 'release' : 'story');
  }

  Widget _skipRow(
    BuildContext context,
    AppLocalizations t,
    ContentNotifier notifier,
    String label,
    List<String> levels,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        onPressed: () {
          notifier.bulkSetSkipped(levels, true);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(t.skippedSnackbar(label))),
          );
        },
        child: Text(t.skipButtonLabel(label)),
      ),
    );
  }
}
