/// Local user profile (no auth).
class UserProfile {
  final String fullName;
  final String email;

  const UserProfile({required this.fullName, required this.email});

  UserProfile copyWith({String? fullName, String? email}) => UserProfile(
        fullName: fullName ?? this.fullName,
        email: email ?? this.email,
      );
}
