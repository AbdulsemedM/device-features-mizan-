import 'dart:io';

import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  static Future<bool> requestStoragePermission() async {
    if (Platform.isAndroid) {
      return true;
    }
    try {
      var permissionstatus = await Permission.storage.status;

      if (permissionstatus.isDenied) {
        permissionstatus = await Permission.storage.request();
      }

      if (permissionstatus.isPermanentlyDenied) {
        return false;
      }

      if (permissionstatus.isGranted || permissionstatus.isLimited) {
        return true;
      }
      return true;
    } catch (e) {
      return true;
    }
  }

  static Future<void> openAppSettings() async {
    await openAppSettings();
  }
}
