import 'package:hive/hive.dart';

import '../models/app_settings_model.dart';
import '../models/business_profile_model.dart';
import 'local_storage_service.dart';

class SettingsService {
  final Box _box = LocalStorageService.getSettingsBox();

  static const String businessProfileKey = 'business_profile';
  static const String appSettingsKey = 'app_settings';

  BusinessProfileModel getBusinessProfile() {
    final data = _box.get(businessProfileKey);
    if (data == null) {
      return const BusinessProfileModel(
        name: 'InvoiceFlow Studio',
        email: 'hello@invoiceflow.app',
        phone: '+1 000 000 0000',
        address: 'Your business address here',
      );
    }
    return BusinessProfileModel.fromMap(Map.from(data));
  }

  Future<void> saveBusinessProfile(BusinessProfileModel profile) async {
    await _box.put(businessProfileKey, profile.toMap());
  }

  AppSettingsModel getAppSettings() {
    final data = _box.get(appSettingsKey);
    if (data == null) {
      return const AppSettingsModel(
        currency: 'USD',
        invoicePrefix: 'INV-',
        quotePrefix: 'QUO-',
        nextInvoiceNumber: 1,
        nextQuoteNumber: 1,
      );
    }
    return AppSettingsModel.fromMap(Map.from(data));
  }

  Future<void> saveAppSettings(AppSettingsModel settings) async {
    await _box.put(appSettingsKey, settings.toMap());
  }
}