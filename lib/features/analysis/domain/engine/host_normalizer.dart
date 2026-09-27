import 'package:punycoder/punycoder.dart';

/// URL hosts never pass through linguistic Turkish ASCII folding.
/// Punycode support covers URL signals; full IDNA nameprep parity with the
/// future live feed must be reviewed before enabling that feed.
String normalizeHost(String raw) {
  var host = (raw.contains('%') ? Uri.decodeComponent(raw) : raw).toLowerCase();
  if (host.startsWith('[') && host.endsWith(']')) {
    host = host.substring(1, host.length - 1);
  }
  host = host.replaceAll(RegExp('[\u3002\uff0e\uff61]'), '.');
  if (host.endsWith('.')) host = host.substring(0, host.length - 1);
  if (host.contains(':')) return _ipv6(host);
  try {
    return Uri.parseIPv4Address(host).join('.');
  } on FormatException {
    // Four numeric labels are an IPv4 literal, not a DNS name. Reject an
    // out-of-range address instead of quietly treating it as a valid host.
    if (RegExp(r'^(?:\d{1,3}\.){3}\d{1,3}$').hasMatch(host)) rethrow;
  }
  host = domainToAscii(host, validate: false);
  final labelPattern = RegExp(r'^[a-z0-9](?:[a-z0-9-]{0,61}[a-z0-9])?$');
  final labels = host.split('.');
  if (host.length > 253 ||
      labels.length < 2 ||
      labels.any((label) => !labelPattern.hasMatch(label))) {
    throw const FormatException('Invalid host');
  }
  return host;
}

bool isIpHost(String host) {
  try {
    if (host.contains(':')) {
      Uri.parseIPv6Address(host);
    } else {
      Uri.parseIPv4Address(host);
    }
    return true;
  } on FormatException {
    return false;
  }
}

String _ipv6(String host) {
  final bytes = Uri.parseIPv6Address(host);
  final words = [
    for (var i = 0; i < 16; i += 2) (bytes[i] << 8) | bytes[i + 1],
  ];
  var bestStart = -1;
  var bestLength = 1;
  for (var start = 0; start < words.length;) {
    if (words[start] != 0) {
      start++;
      continue;
    }
    var end = start;
    while (end < words.length && words[end] == 0) {
      end++;
    }
    if (end - start > bestLength) {
      bestStart = start;
      bestLength = end - start;
    }
    start = end;
  }
  final hex = words.map((w) => w.toRadixString(16)).toList();
  if (bestStart < 0) return hex.join(':');
  return '${hex.take(bestStart).join(':')}::${hex.skip(bestStart + bestLength).join(':')}';
}
