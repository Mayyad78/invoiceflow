import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/backup_restore_service.dart';

final backupRestoreServiceProvider = Provider<BackupRestoreService>((ref) {
  return BackupRestoreService();
});