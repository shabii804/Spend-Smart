/// Budget model — only monthlyLimit is required per spec.
class Budget {
  final double monthlyLimit;

  const Budget({required this.monthlyLimit});

  Budget copyWith({double? monthlyLimit}) =>
      Budget(monthlyLimit: monthlyLimit ?? this.monthlyLimit);
}
