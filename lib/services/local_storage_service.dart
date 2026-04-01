import 'package:hive_flutter/hive_flutter.dart';

class LocalStorageService {
  static const String clientsBox = 'clients_box';
  static const String invoicesBox = 'invoices_box';
  static const String settingsBox = 'settings_box';
  static const String catalogItemsBox = 'catalog_items_box';

  static Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox(clientsBox);
    await Hive.openBox(invoicesBox);
    await Hive.openBox(settingsBox);
    await Hive.openBox(catalogItemsBox);
  }

  static Box getClientsBox() => Hive.box(clientsBox);

  static Box getInvoicesBox() => Hive.box(invoicesBox);

  static Box getSettingsBox() => Hive.box(settingsBox);

  static Box getCatalogItemsBox() => Hive.box(catalogItemsBox);
}