import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/business_profile_model.dart';
import 'settings_service_provider.dart';

final businessProfileProvider =
    StateNotifierProvider<BusinessProfileNotifier, BusinessProfileModel>((ref) {
  final service = ref.watch(settingsServiceProvider);
  return BusinessProfileNotifier(service)..load();
});

class BusinessProfileNotifier extends StateNotifier<BusinessProfileModel> {
  BusinessProfileNotifier(this._service)
      : super(
          const BusinessProfileModel(
            name: 'InvoiceFlow Studio',
            email: 'hello@invoiceflow.app',
            phone: '+1 000 000 0000',
            address: 'Your business address here',
          ),
        );

  final dynamic _service;

  void load() {
    state = _service.getBusinessProfile();
  }

  Future<void> save(BusinessProfileModel profile) async {
    await _service.saveBusinessProfile(profile);
    state = profile;
  }
}