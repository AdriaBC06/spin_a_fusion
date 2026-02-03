import 'package:firebase_remote_config/firebase_remote_config.dart';

class RemoteConfigService {
  final FirebaseRemoteConfig _remoteConfig =
      FirebaseRemoteConfig.instance;

  Future<void> init() async {
    await _remoteConfig.setDefaults({
      'min_build': 0,
      'force_update_message':
          'Hay una nueva versión disponible. Actualiza para continuar.',
      'update_url': '',
    });

    await _remoteConfig.setConfigSettings(
      RemoteConfigSettings(
        fetchTimeout: const Duration(seconds: 5),
        minimumFetchInterval: const Duration(minutes: 30),
      ),
    );

    await _remoteConfig.fetchAndActivate();
  }

  int get minBuild => _remoteConfig.getInt('min_build');

  String get message =>
      _remoteConfig.getString('force_update_message');

  String get updateUrl => _remoteConfig.getString('update_url');
}
