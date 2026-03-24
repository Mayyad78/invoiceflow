import 'package:hive/hive.dart';

import '../models/client_model.dart';
import 'local_storage_service.dart';

class ClientService {
  final Box _box = LocalStorageService.getClientsBox();

  List<ClientModel> getClients() {
    return _box.values
        .map((e) => ClientModel.fromMap(Map.from(e)))
        .toList();
  }

  Future<void> saveClient(ClientModel client) async {
    await _box.put(client.id, client.toMap());
  }

  Future<void> updateClient(ClientModel client) async {
    await _box.put(client.id, client.toMap());
  }

  Future<void> deleteClient(String id) async {
    await _box.delete(id);
  }
}