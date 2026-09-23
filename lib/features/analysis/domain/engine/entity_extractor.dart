class MessageEntities {
  const MessageEntities({
    required this.hosts,
    required this.ibans,
    required this.phones,
    required this.amounts,
  });
  final Set<String> hosts;
  final List<String> ibans;
  final List<String> phones;
  final List<String> amounts;
}

class EntityExtractor {
  const EntityExtractor();

  MessageEntities extract(String text) {
    // Keep URLs separate from linguistic normalization: folding a domain can
    // turn an impersonating address into the legitimate brand's address.
    final hosts = <String>{};
    final candidates = RegExp(
      r'''https?://[^\s<>"']+|(?:[a-zA-Z0-9\u0080-\uFFFF][a-zA-Z0-9\u0080-\uFFFF-]*\.)+[a-zA-Z\u0080-\uFFFF]{2,63}(?:[/:][^\s<>"']*)?''',
      caseSensitive: false,
    );
    for (final match in candidates.allMatches(text)) {
      var value = match.group(0)!.replaceAll(RegExp(r'[.,;!?)\]}]+$'), '');
      // Do not interpret an email address as a navigable URL.
      if (match.start > 0 && text[match.start - 1] == '@') continue;
      if (!value.toLowerCase().startsWith('http')) value = 'https://$value';
      final uri = Uri.tryParse(value);
      if (uri == null || uri.host.isEmpty) continue;
      final host = uri.host.toLowerCase().replaceAll(RegExp(r'\.$'), '');
      hosts.add(host);
    }
    return MessageEntities(
      hosts: hosts,
      ibans: _matches(
        RegExp(r'\bTR\s*\d{2}(?:\s*\d){22}\b', caseSensitive: false),
        text,
      ),
      phones: _matches(
        RegExp(r'(?<!\d)(?:\+90|0)\s*\(?\d{3}\)?(?:[ -]*\d){7}(?!\d)'),
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
