class Validators {
  Validators._();

  /// Validates email format
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) return 'Email is required';
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) return 'Enter a valid email';
    return null;
  }

  /// Validates password (minimum 8 chars)
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Password is required';
    if (value.length < 8) return 'Password must be at least 8 characters';
    return null;
  }

  /// Validates name (non-empty, at least 2 chars)
  static String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) return 'Name is required';
    if (value.trim().length < 2) return 'Name must be at least 2 characters';
    return null;
  }

  /// Validates age (18-100)
  static String? validateAge(String? value) {
    if (value == null || value.isEmpty) return 'Age is required';
    final age = int.tryParse(value);
    if (age == null) return 'Enter a valid age';
    if (age < 18 || age > 100) return 'Age must be between 18 and 100';
    return null;
  }

  /// Validates salary (positive number)
  static String? validateSalary(String? value) {
    if (value == null || value.isEmpty) return 'Salary is required';
    final salary = double.tryParse(value.replaceAll(',', ''));
    if (salary == null) return 'Enter a valid amount';
    if (salary <= 0) return 'Salary must be greater than zero';
    return null;
  }

  /// Validates percentage (0-100)
  static String? validatePercentage(String? value) {
    if (value == null || value.isEmpty) return 'Required';
    final pct = double.tryParse(value);
    if (pct == null) return 'Enter a valid number';
    if (pct < 0 || pct > 100) return 'Must be between 0 and 100';
    return null;
  }

  /// Validates PAN number
  static String? validatePAN(String? value) {
    if (value == null || value.isEmpty) return 'PAN is required';
    final panRegex = RegExp(r'^[A-Z]{5}[0-9]{4}[A-Z]{1}$');
    if (!panRegex.hasMatch(value.toUpperCase())) return 'Enter a valid PAN';
    return null;
  }

  /// Validates PRAN number (12 digits)
  static String? validatePRAN(String? value) {
    if (value == null || value.isEmpty) return 'PRAN is required';
    final pranRegex = RegExp(r'^\d{12}$');
    if (!pranRegex.hasMatch(value)) return 'PRAN must be 12 digits';
    return null;
  }
}
