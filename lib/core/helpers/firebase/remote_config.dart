import 'package:firebase_remote_config/firebase_remote_config.dart';

class RemoteConfigService {
  final FirebaseRemoteConfig _remoteConfig = FirebaseRemoteConfig.instance;

  Future<bool> init() async {
    try {
      await _remoteConfig.setConfigSettings(RemoteConfigSettings(
        fetchTimeout: const Duration(seconds: 10),
        minimumFetchInterval: Duration.zero, // Always check for changes
      ));

      await _remoteConfig.fetchAndActivate();
      return true;
    } catch (e) {
      print("❌ RemoteConfig fetch failed: $e");
      return false;
    }
  }

  bool get isAppUnderMaintenance =>
      _remoteConfig.getBool('isAppUnderMaintenance');

  String get maintenanceMessage =>
      _remoteConfig.getString('maintenanceMessage');
}
