import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/settings_service.dart';

final settingsServiceProvider = Provider<SettingsService>((ref) {
  return SettingsService();
});