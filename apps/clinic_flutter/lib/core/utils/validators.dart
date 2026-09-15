bool isNonEmpty(String? v) => v != null && v.trim().isNotEmpty;

bool isValidEmail(String? v) {
  if (!isNonEmpty(v)) return false;
  return RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(v!.trim());
}

String? requiredError(String? v) => isNonEmpty(v) ? null : 'required';

String? emailError(String? v) {
  if (!isNonEmpty(v)) return 'required';
  if (!isValidEmail(v)) return 'invalidEmail';
  return null;
}

String? passwordError(String? v) {
  if (!isNonEmpty(v)) return 'required';
  if (v!.length < 8) return 'tooShort';
  return null;
}
