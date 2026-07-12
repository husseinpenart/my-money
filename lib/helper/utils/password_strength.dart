enum PasswordStrength { weak, medium, strong }

/// Result of evaluating a password against the app's strength rules.
class PasswordStrengthResult {
  final bool hasLength;
  final bool hasNumber;
  final bool hasUppercase;
  final int score;

  const PasswordStrengthResult({
    required this.hasLength,
    required this.hasNumber,
    required this.hasUppercase,
    required this.score,
  });

  factory PasswordStrengthResult.fromPassword(String password) {
    final hasLength = password.length >= 6;
    final hasNumber = RegExp(r'[0-9]').hasMatch(password);
    final hasUppercase = RegExp(r'[A-Z]').hasMatch(password);
    final score = [hasLength, hasNumber, hasUppercase].where((met) => met).length;

    return PasswordStrengthResult(
      hasLength: hasLength,
      hasNumber: hasNumber,
      hasUppercase: hasUppercase,
      score: score,
    );
  }

  PasswordStrength get strength {
    if (score <= 1) return PasswordStrength.weak;
    if (score == 2) return PasswordStrength.medium;
    return PasswordStrength.strong;
  }
}
