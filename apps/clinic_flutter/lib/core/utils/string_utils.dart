String fullName(String first, String last) {
  final f = first.trim();
  final l = last.trim();
  if (f.isEmpty) return l;
  if (l.isEmpty) return f;
  return '$f $l';
}

String initials(String first, String last) {
  final f = first.trim();
  final l = last.trim();
  final firstInitial = f.isNotEmpty ? f[0] : '';
  final lastInitial = l.isNotEmpty ? l[0] : '';
  return (firstInitial + lastInitial).toUpperCase();
}

String normalizeSearch(String q) => q.trim().toLowerCase();

String? emptyToNull(String? v) {
  if (v == null) return null;
  final trimmed = v.trim();
  return trimmed.isEmpty ? null : trimmed;
}
