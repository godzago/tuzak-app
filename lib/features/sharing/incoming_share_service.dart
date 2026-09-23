import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class IncomingShareService {
  const IncomingShareService();
  static const _channel = MethodChannel('com.example.tuzak/sharing');

  bool get supported => !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS;

  Future<String?> takePendingText() async {
    if (!supported) return null;
    return _channel.invokeMethod<String>('takePendingText');
  }
}
