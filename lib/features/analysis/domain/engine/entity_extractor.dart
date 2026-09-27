import 'host_normalizer.dart';

class ExtractedUrl {
  const ExtractedUrl(this.uri, this.host, this.explicitHttp);
  final Uri uri;
  final String host;
  final bool explicitHttp;
}

class MessageEntities {
  const MessageEntities({
    required this.hosts,
    required this.ibans,
    required this.phones,
    required this.amounts,
    this.urls = const [],
    this.prose = '',
  });
  final Set<String> hosts;
  final List<String> ibans;
  final List<String> phones;
  final List<String> amounts;
  final List<ExtractedUrl> urls;
  final String prose;
}

class EntityExtractor {
  const EntityExtractor();

  MessageEntities extract(String text) {
    // Keep URLs separate from linguistic normalization: folding a domain can
    // turn an impersonating address into the legitimate brand's address.
    final hosts = <String>{};
    final urls = <ExtractedUrl>[];
    final prose = StringBuffer();
    var previousEnd = 0;
    final candidates = RegExp(
      r'''https?://[^\s<>"']+|(?:[a-zA-Z0-9\u0080-\uFFFF][a-zA-Z0-9\u0080-\uFFFF-]*\.)+[a-zA-Z\u0080-\uFFFF]{2,63}(?:[/:][^\s<>"']*)?|(?<![\w.])(?:\d{1,3}\.){3}\d{1,3}(?![\w.])''',
      caseSensitive: false,
    );
    for (final match in candidates.allMatches(text)) {
      var value = match.group(0)!.replaceAll(RegExp(r'[.,;!?)\]}]+$'), '');
      // Do not interpret an email address as a navigable URL.
      if (match.start > 0 && text[match.start - 1] == '@') continue;
      final explicitHttp = value.toLowerCase().startsWith('http://');
      if (!RegExp(r'^https?://', caseSensitive: false).hasMatch(value)) {
        value = 'https://$value';
      }
      try {
        final uri = Uri.tryParse(value);
        if (uri == null || uri.host.isEmpty) continue;
        final host = normalizeHost(uri.host);
        hosts.add(host);
        urls.add(ExtractedUrl(uri, host, explicitHttp));
        prose.write(text.substring(previousEnd, match.start));
        prose.write(' ');
        previousEnd = match.end;
      } on FormatException {
        continue;
      }
    }
    return MessageEntities(
      hosts: hosts,
      urls: List.unmodifiable(urls),
      prose: (prose..write(text.substring(previousEnd))).toString(),
      ibans: _matches(
        RegExp(r'\bTR\s*\d{2}(?:\s*\d){22}\b', caseSensitive: false),
        text,
      ),
      phones: _matches(
        RegExp(r'(?<!\d)(?:\+90|0)\s*\(?\d{3}\)?(?:[ .-]*\d){7}(?!\d)'),
        text,
      ),
      amounts: _matches(
        RegExp(r'\d[\d.,]*\s*(?:TL|TRY|₺|USD|EUR)\b', caseSensitive: false),
        text,
      ),
    );
  }

  List<String> _matches(RegExp pattern, String text) =>
      pattern.allMatches(text).map((m) => m.group(0)!).toList();
}
