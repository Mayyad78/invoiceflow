import 'dart:convert';
import 'dart:typed_data';

import 'package:file_selector/file_selector.dart';

import 'local_storage_service.dart';
import 'settings_service.dart';

class BackupRestoreResult {
  final bool success;
  final bool cancelled;
  final String message;
  final String? path;
  final int clientsCount;
  final int invoicesCount;

  const BackupRestoreResult({
    required this.success,
    required this.cancelled,
    required this.message,
    this.path,
    this.clientsCount = 0,
    this.invoicesCount = 0,
  });

  factory BackupRestoreResult.success({
    required String message,
    String? path,
    int clientsCount = 0,
    int invoicesCount = 0,
  }) {
    return BackupRestoreResult(
      success: true,
      cancelled: false,
      message: message,
      path: path,
      clientsCount: clientsCount,
      invoicesCount: invoicesCount,
    );
  }

  factory BackupRestoreResult.cancelled([String message = 'Action cancelled']) {
    return BackupRestoreResult(
      success: false,
      cancelled: true,
      message: message,
    );
  }

  factory BackupRestoreResult.failure(String message) {
    return BackupRestoreResult(
      success: false,
      cancelled: false,
      message: message,
    );
  }
}

class BackupRestoreService {
  static const int backupVersion = 1;

  static const XTypeGroup _jsonTypeGroup = XTypeGroup(
    label: 'JSON',
    extensions: ['json'],
  );

  Future<BackupRestoreResult> exportBackup() async {
    try {
      final clientsBox = LocalStorageService.getClientsBox();
      final invoicesBox = LocalStorageService.getInvoicesBox();
      final settingsBox = LocalStorageService.getSettingsBox();

      final clients = clientsBox.values
          .map((e) => Map<String, dynamic>.from(Map.from(e)))
          .toList();

      final invoices = invoicesBox.values
          .map((e) => Map<String, dynamic>.from(Map.from(e)))
          .toList();

      final businessProfileRaw =
          settingsBox.get(SettingsService.businessProfileKey);
      final appSettingsRaw = settingsBox.get(SettingsService.appSettingsKey);

      final businessProfile = businessProfileRaw == null
          ? null
          : Map<String, dynamic>.from(Map.from(businessProfileRaw));

      final appSettings = appSettingsRaw == null
          ? null
          : Map<String, dynamic>.from(Map.from(appSettingsRaw));

      final exportedAt = DateTime.now().toIso8601String();
      final fileSafeTimestamp =
          exportedAt.replaceAll(':', '-').replaceAll('.', '-');

      final payload = <String, dynamic>{
        'app': 'InvoiceFlow',
        'backupVersion': backupVersion,
        'exportedAt': exportedAt,
        'data': {
          'clients': clients,
          'invoices': invoices,
          'settings': {
            'businessProfile': businessProfile,
            'appSettings': appSettings,
          },
        },
        'meta': {
          'clientsCount': clients.length,
          'invoicesCount': invoices.length,
        },
      };

      final jsonString = const JsonEncoder.withIndent('  ').convert(payload);

      final saveLocation = await getSaveLocation(
        acceptedTypeGroups: const [_jsonTypeGroup],
        suggestedName: 'invoiceflow-backup-$fileSafeTimestamp.json',
        confirmButtonText: 'Export backup',
      );

      if (saveLocation == null || saveLocation.path.trim().isEmpty) {
        return BackupRestoreResult.cancelled();
      }

      final file = XFile.fromData(
        Uint8List.fromList(utf8.encode(jsonString)),
        mimeType: 'application/json',
        name: saveLocation.path.split('/').last,
      );

      await file.saveTo(saveLocation.path);

      return BackupRestoreResult.success(
        message: 'Backup exported successfully',
        path: saveLocation.path,
        clientsCount: clients.length,
        invoicesCount: invoices.length,
      );
    } catch (e) {
      return BackupRestoreResult.failure('Export failed: $e');
    }
  }

  Future<BackupRestoreResult> restoreBackup() async {
    try {
      final file = await openFile(
        acceptedTypeGroups: const [_jsonTypeGroup],
        confirmButtonText: 'Restore backup',
      );

      if (file == null) {
        return BackupRestoreResult.cancelled();
      }

      final raw = await file.readAsString();
      final decoded = jsonDecode(raw);

      if (decoded is! Map) {
        return BackupRestoreResult.failure('Invalid backup file format');
      }

      final payload = Map<String, dynamic>.from(decoded);

      if (payload['app'] != 'InvoiceFlow') {
        return BackupRestoreResult.failure(
          'This file is not an InvoiceFlow backup',
        );
      }

      final dataRaw = payload['data'];
      if (dataRaw is! Map) {
        return BackupRestoreResult.failure('Backup data is missing');
      }

      final data = Map<String, dynamic>.from(dataRaw);

      final clientsRaw = data['clients'];
      final invoicesRaw = data['invoices'];
      final settingsRaw = data['settings'];

      if (clientsRaw is! List || invoicesRaw is! List || settingsRaw is! Map) {
        return BackupRestoreResult.failure('Backup file structure is invalid');
      }

      final settings = Map<String, dynamic>.from(settingsRaw);

      final businessProfileRaw = settings['businessProfile'];
      final appSettingsRaw = settings['appSettings'];

      if (businessProfileRaw != null && businessProfileRaw is! Map) {
        return BackupRestoreResult.failure('Business profile data is invalid');
      }

      if (appSettingsRaw != null && appSettingsRaw is! Map) {
        return BackupRestoreResult.failure('App settings data is invalid');
      }

      final clientEntries = <String, Map<String, dynamic>>{};
      for (final item in clientsRaw) {
        if (item is! Map) continue;
        final map = Map<String, dynamic>.from(item);
        final id = map['id']?.toString().trim() ?? '';
        if (id.isEmpty) continue;
        clientEntries[id] = map;
      }

      final invoiceEntries = <String, Map<String, dynamic>>{};
      for (final item in invoicesRaw) {
        if (item is! Map) continue;
        final map = Map<String, dynamic>.from(item);
        final id = map['id']?.toString().trim() ?? '';
        if (id.isEmpty) continue;
        invoiceEntries[id] = map;
      }

      final clientsBox = LocalStorageService.getClientsBox();
      final invoicesBox = LocalStorageService.getInvoicesBox();
      final settingsBox = LocalStorageService.getSettingsBox();

      await clientsBox.clear();
      await invoicesBox.clear();
      await settingsBox.clear();

      if (clientEntries.isNotEmpty) {
        await clientsBox.putAll(clientEntries);
      }

      if (invoiceEntries.isNotEmpty) {
        await invoicesBox.putAll(invoiceEntries);
      }

      if (businessProfileRaw != null) {
        await settingsBox.put(
          SettingsService.businessProfileKey,
          Map<String, dynamic>.from(Map.from(businessProfileRaw)),
        );
      }

      if (appSettingsRaw != null) {
        await settingsBox.put(
          SettingsService.appSettingsKey,
          Map<String, dynamic>.from(Map.from(appSettingsRaw)),
        );
      }

      return BackupRestoreResult.success(
        message: 'Backup restored successfully',
        path: file.path,
        clientsCount: clientEntries.length,
        invoicesCount: invoiceEntries.length,
      );
    } catch (e) {
      return BackupRestoreResult.failure('Restore failed: $e');
    }
  }
}