/// Form validation helpers.
class Validators {
  Validators._();

  static String? required(String? v) {
    if (v == null || v.trim().isEmpty) return 'This field is required';
    return null;
  }

  static String? email(String? v) {
    if (v == null || v.trim().isEmpty) return 'This field is required';
    final re = RegExp(r'^[\w.+-]+@[\w-]+\.[\w.-]+$');
    if (!re.hasMatch(v.trim())) return 'Enter a valid email address';
    return null;
  }

  static String? password(String? v) {
    if (v == null || v.trim().isEmpty) return 'This field is required';
    if (v.length < 6) return 'Password must be at least 6 characters';
    return null;
  }

  static String? confirmPassword(String? v, String original) {
    if (v == null || v.trim().isEmpty) return 'This field is required';
    if (v != original) return 'Passwords do not match';
    return null;
  }

  static String? amount(String? v) {
    if (v == null || v.trim().isEmpty) return 'Enter a valid amount';
    final n = double.tryParse(v.trim().replaceAll(RegExp(r'[^0-9.]'), ''));
    if (n == null || n <= 0) return 'Enter a valid amount';
    return null;
  }

  static String? Function(String?) match(String other) =>
      (v) => confirmPassword(v, other);
}
