/// Local user profile with rich financial details and security settings.
class UserProfile {
  final String fullName;
  final String email;
  final String phone;
  final String memberTier;
  final String joinDate;
  final double monthlyIncome;
  final String occupation;
  final int streakDays;
  final int healthScore;
  final bool biometricsEnabled;
  final bool appLockEnabled;

  const UserProfile({
    required this.fullName,
    required this.email,
    this.phone = '+92 300 1234567',
    this.memberTier = 'Smart Saver',
    this.joinDate = 'October 2024',
    this.monthlyIncome = 85000,
    this.occupation = 'Software Engineer',
    this.streakDays = 42,
    this.healthScore = 88,
    this.biometricsEnabled = true,
    this.appLockEnabled = false,
  });

  UserProfile copyWith({
    String? fullName,
    String? email,
    String? phone,
    String? memberTier,
    String? joinDate,
    double? monthlyIncome,
    String? occupation,
    int? streakDays,
    int? healthScore,
    bool? biometricsEnabled,
    bool? appLockEnabled,
  }) =>
      UserProfile(
        fullName: fullName ?? this.fullName,
        email: email ?? this.email,
        phone: phone ?? this.phone,
        memberTier: memberTier ?? this.memberTier,
        joinDate: joinDate ?? this.joinDate,
        monthlyIncome: monthlyIncome ?? this.monthlyIncome,
        occupation: occupation ?? this.occupation,
        streakDays: streakDays ?? this.streakDays,
        healthScore: healthScore ?? this.healthScore,
        biometricsEnabled: biometricsEnabled ?? this.biometricsEnabled,
        appLockEnabled: appLockEnabled ?? this.appLockEnabled,
      );
}
