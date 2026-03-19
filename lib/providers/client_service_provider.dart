import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/client_service.dart';

final clientServiceProvider = Provider<ClientService>((ref) {
  return ClientService();
});