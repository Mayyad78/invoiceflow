import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/catalog_item_service.dart';

final catalogItemServiceProvider = Provider<CatalogItemService>((ref) {
  return CatalogItemService();
});