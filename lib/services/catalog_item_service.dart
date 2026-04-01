import 'package:hive/hive.dart';

import '../models/catalog_item_model.dart';
import 'local_storage_service.dart';

class CatalogItemService {
  final Box _box = LocalStorageService.getCatalogItemsBox();

  List<CatalogItemModel> getItems() {
    return _box.values
        .map(
          (value) => CatalogItemModel.fromMap(
            Map<dynamic, dynamic>.from(value as Map),
          ),
        )
        .toList()
      ..sort(
        (a, b) => a.description.toLowerCase().compareTo(
              b.description.toLowerCase(),
            ),
      );
  }

  CatalogItemModel? findItemByDescription({
    required String description,
    String? excludeId,
  }) {
    final normalizedDescription = description.trim().toLowerCase();

    for (final item in getItems()) {
      if (excludeId != null && item.id == excludeId) {
        continue;
      }

      if (item.normalizedDescription == normalizedDescription) {
        return item;
      }
    }

    return null;
  }

  Future<void> saveItem(CatalogItemModel item) async {
    await _box.put(item.id, item.toMap());
  }

  Future<void> updateItem(CatalogItemModel item) async {
    await _box.put(item.id, item.toMap());
  }

  Future<void> deleteItem(String id) async {
    await _box.delete(id);
  }
}