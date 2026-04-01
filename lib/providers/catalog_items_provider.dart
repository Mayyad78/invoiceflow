import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/catalog_item_model.dart';
import '../services/catalog_item_service.dart';
import 'catalog_item_service_provider.dart';

final catalogItemsProvider =
    StateNotifierProvider<CatalogItemsNotifier, List<CatalogItemModel>>(
  (ref) {
    final service = ref.watch(catalogItemServiceProvider);
    return CatalogItemsNotifier(service)..loadItems();
  },
);

class CatalogItemsNotifier extends StateNotifier<List<CatalogItemModel>> {
  CatalogItemsNotifier(this._catalogItemService) : super([]);

  final CatalogItemService _catalogItemService;

  void loadItems() {
    state = _catalogItemService.getItems();
  }

  CatalogItemModel? findItemByDescription({
    required String description,
    String? excludeId,
  }) {
    return _catalogItemService.findItemByDescription(
      description: description,
      excludeId: excludeId,
    );
  }

  Future<void> addItem(CatalogItemModel item) async {
    await _catalogItemService.saveItem(item);
    loadItems();
  }

  Future<void> updateItem(CatalogItemModel item) async {
    await _catalogItemService.updateItem(item);
    loadItems();
  }

  Future<void> deleteItem(String id) async {
    await _catalogItemService.deleteItem(id);
    loadItems();
  }
}