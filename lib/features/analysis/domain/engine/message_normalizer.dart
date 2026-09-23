String normalizeMessage(String text) {
  var normalized = text.replaceAll('İ', 'i').replaceAll('I', 'ı').toLowerCase();
  const fold = {'ı': 'i', 'ş': 's', 'ğ': 'g', 'ü': 'u', 'ö': 'o', 'ç': 'c'};
  for (final entry in fold.entries) {
    normalized = normalized.replaceAll(entry.key, entry.value);
  }
  return normalized
      .replaceAll(RegExp('[\u200B-\u200D\uFEFF]'), '')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
}
