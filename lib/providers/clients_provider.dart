import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/client_model.dart';
import 'client_service_provider.dart';

final clientsProvider = StateNotifierProvider<ClientsNotifier, List<ClientModel>>(
  (ref) {
    final service = ref.watch(clientServiceProvider);
    return ClientsNotifier(service)..loadClients();
  },
);

class ClientsNotifier extends StateNotifier<List<ClientModel>> {
  ClientsNotifier(this._clientService) : super([]);

  final dynamic _clientService;

  void loadClients() {
    state = _clientService.getClients();
  }

  Future<void> addClient(ClientModel client) async {
    await _clientService.saveClient(client);
    loadClients();
  }

  Future<void> updateClient(ClientModel client) async {
    await _clientService.updateClient(client);
    loadClients();
  }

  Future<void> deleteClient(String id) async {
    await _clientService.deleteClient(id);
    loadClients();
  }
}