import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/app_localizations.dart';
import '../../providers/app_settings_provider.dart';
import '../../providers/business_profile_provider.dart';
import '../../providers/locale_provider.dart';
import 'business_profile_screen.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  static const currencies = ['USD', 'EUR', 'GBP', 'JOD', 'AED'];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context)!;
    final currentLocale = ref.watch(localeProvider);
    final profile = ref.watch(businessProfileProvider);
    final appSettings = ref.watch(appSettingsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(t.settings),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: ListTile(
              title: Text(t.businessProfile),
              subtitle: Text(profile.name),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const BusinessProfileScreen(),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              title: Text(t.currencySettings),
              subtitle: Text(appSettings.currency),
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: currencies.map((currency) {
              final selected = appSettings.currency == currency;

              return ChoiceChip(
                label: Text(currency),
                selected: selected,
                onSelected: (_) async {
                  await ref
                      .read(appSettingsProvider.notifier)
                      .saveCurrency(currency);

                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(t.currencySaved)),
                    );
                  }
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(t.language),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          ref.read(localeProvider.notifier).state =
                              const Locale('en');
                        },
                        child: const Text('English'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          ref.read(localeProvider.notifier).state =
                              const Locale('ar');
                        },
                        child: const Text('العربية'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          ref.read(localeProvider.notifier).state =
                              const Locale('fr');
                        },
                        child: const Text('Français'),
                      ),
                      OutlinedButton(
                        onPressed: () {
                          ref.read(localeProvider.notifier).state = null;
                        },
                        child: const Text('System'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(currentLocale?.languageCode ?? 'system'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}