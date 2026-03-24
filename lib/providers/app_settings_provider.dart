import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/app_settings_model.dart';
import '../services/settings_service.dart';
import 'settings_service_provider.dart';

final appSettingsProvider =
    StateNotifierProvider<AppSettingsNotifier, AppSettingsModel>((ref) {
  final service = ref.watch(settingsServiceProvider) as SettingsService;
  return AppSettingsNotifier(service)..load();
});

class AppSettingsNotifier extends StateNotifier<AppSettingsModel> {
  AppSettingsNotifier(this._service)
      : super(
          const AppSettingsModel(
            currency: 'USD',
            invoicePrefix: 'INV-',
            quotePrefix: 'QUO-',
            nextInvoiceNumber: 1,
            nextQuoteNumber: 1,
          ),
        );

  final SettingsService _service;

  void load() {
    state = _service.getAppSettings();
  }

  Future<void> saveCurrency(String currency) async {
    final updated = state.copyWith(currency: currency);
    await _service.saveAppSettings(updated);
    state = updated;
  }

  Future<void> saveNumberingSettings({
    required String invoicePrefix,
    required String quotePrefix,
    required int nextInvoiceNumber,
    required int nextQuoteNumber,
  }) async {
    final updated = state.copyWith(
      invoicePrefix: invoicePrefix,
      quotePrefix: quotePrefix,
      nextInvoiceNumber: nextInvoiceNumber,
      nextQuoteNumber: nextQuoteNumber,
    );

    await _service.saveAppSettings(updated);
    state = updated;
  }

  String previewDocumentNumber(String type) {
    final isQuote = type == 'quote';
    final prefix = isQuote ? state.quotePrefix : state.invoicePrefix;
    final nextNumber =
        isQuote ? state.nextQuoteNumber : state.nextInvoiceNumber;
    return '$prefix${nextNumber.toString().padLeft(4, '0')}';
  }

  Future<String> consumeNextDocumentNumber(String type) async {
    final isQuote = type == 'quote';

    final generated = previewDocumentNumber(type);

    final updated = state.copyWith(
      nextInvoiceNumber:
          isQuote ? state.nextInvoiceNumber : state.nextInvoiceNumber + 1,
      nextQuoteNumber:
          isQuote ? state.nextQuoteNumber + 1 : state.nextQuoteNumber,
    );

    await _service.saveAppSettings(updated);
    state = updated;

    return generated;
  }
}