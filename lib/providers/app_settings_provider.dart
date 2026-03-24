
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/app_settings_model.dart';
import 'settings_service_provider.dart';

final appSettingsProvider =
    StateNotifierProvider<AppSettingsNotifier, AppSettingsModel>((ref) {
  final service = ref.watch(settingsServiceProvider);
  return AppSettingsNotifier(service)..load();
});

class AppSettingsNotifier extends StateNotifier<AppSettingsModel> {
  AppSettingsNotifier(this._service)
      : super(const AppSettingsModel(currency: 'USD'));

  final dynamic _service;

  void load() {
    state = _service.getAppSettings();
  }

  Future<void> saveCurrency(String currency) async {
    final updated = state.copyWith(currency: currency);
    await _service.saveAppSettings(updated);
    state = updated;
  }
}
