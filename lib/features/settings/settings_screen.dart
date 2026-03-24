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
                  await ref.read(appSettingsProvider.notifier).saveCurrency(
                        currency,
                      );
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
            child: ListTile(
              title: const Text('Document numbering'),
              subtitle: Text(
                'Invoice: ${appSettings.invoicePrefix}${appSettings.nextInvoiceNumber.toString().padLeft(4, '0')} • '
                'Quote: ${appSettings.quotePrefix}${appSettings.nextQuoteNumber.toString().padLeft(4, '0')}',
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                showModalBottomSheet<void>(
                  context: context,
                  isScrollControlled: true,
                  builder: (_) => _NumberingSettingsSheet(
                    invoicePrefix: appSettings.invoicePrefix,
                    quotePrefix: appSettings.quotePrefix,
                    nextInvoiceNumber: appSettings.nextInvoiceNumber,
                    nextQuoteNumber: appSettings.nextQuoteNumber,
                  ),
                );
              },
            ),
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

class _NumberingSettingsSheet extends ConsumerStatefulWidget {
  const _NumberingSettingsSheet({
    required this.invoicePrefix,
    required this.quotePrefix,
    required this.nextInvoiceNumber,
    required this.nextQuoteNumber,
  });

  final String invoicePrefix;
  final String quotePrefix;
  final int nextInvoiceNumber;
  final int nextQuoteNumber;

  @override
  ConsumerState<_NumberingSettingsSheet> createState() =>
      _NumberingSettingsSheetState();
}

class _NumberingSettingsSheetState
    extends ConsumerState<_NumberingSettingsSheet> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _invoicePrefixController;
  late final TextEditingController _quotePrefixController;
  late final TextEditingController _nextInvoiceNumberController;
  late final TextEditingController _nextQuoteNumberController;

  @override
  void initState() {
    super.initState();
    _invoicePrefixController =
        TextEditingController(text: widget.invoicePrefix);
    _quotePrefixController = TextEditingController(text: widget.quotePrefix);
    _nextInvoiceNumberController =
        TextEditingController(text: widget.nextInvoiceNumber.toString());
    _nextQuoteNumberController =
        TextEditingController(text: widget.nextQuoteNumber.toString());
  }

  @override
  void dispose() {
    _invoicePrefixController.dispose();
    _quotePrefixController.dispose();
    _nextInvoiceNumberController.dispose();
    _nextQuoteNumberController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final invoicePrefix = _invoicePrefixController.text.trim();
    final quotePrefix = _quotePrefixController.text.trim();
    final nextInvoiceNumber =
        int.tryParse(_nextInvoiceNumberController.text.trim()) ?? 1;
    final nextQuoteNumber =
        int.tryParse(_nextQuoteNumberController.text.trim()) ?? 1;

    await ref.read(appSettingsProvider.notifier).saveNumberingSettings(
          invoicePrefix: invoicePrefix,
          quotePrefix: quotePrefix,
          nextInvoiceNumber: nextInvoiceNumber,
          nextQuoteNumber: nextQuoteNumber,
        );

    if (!mounted) return;

    Navigator.of(context).pop();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Document numbering settings saved'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + bottomInset),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Document numbering',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _invoicePrefixController,
                decoration: const InputDecoration(
                  labelText: 'Invoice prefix',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nextInvoiceNumberController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Next invoice number',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  final parsed = int.tryParse((value ?? '').trim());
                  if (parsed == null || parsed < 1) {
                    return 'Enter a valid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _quotePrefixController,
                decoration: const InputDecoration(
                  labelText: 'Quote prefix',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nextQuoteNumberController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Next quote number',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  final parsed = int.tryParse((value ?? '').trim());
                  if (parsed == null || parsed < 1) {
                    return 'Enter a valid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _save,
                  child: const Text('Save numbering settings'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}