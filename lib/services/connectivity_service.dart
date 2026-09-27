import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

typedef ConnectionCheck = Future<bool?> Function();
typedef ConnectionStatusStream = Stream<bool> Function();

class ConnectivityService {
  const ConnectivityService();

  /// `false` means the device could not reach the public internet. `null`
  /// means the check itself failed, so callers must not claim it is offline.
  Future<bool?> hasNetwork() async {
    try {
      return await InternetConnection().hasInternetAccess.timeout(
        const Duration(seconds: 2),
      );
    } catch (_) {
      return null;
    }
  }

  Stream<bool> statusChanges() => InternetConnection().onStatusChange
      .map((status) => status == InternetStatus.connected)
      .distinct();
}
