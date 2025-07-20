class UserProfile {
  final String uid;
  final String email;
  final String displayName;
  final String? avatarUrl;
  final bool onboardingCompleted;

  const UserProfile({
    required this.uid,
    required this.email,
    required this.displayName,
    this.avatarUrl,
    this.onboardingCompleted = false,
  });

  UserProfile copyWith({
    String? displayName,
    String? avatarUrl,
    bool? onboardingCompleted,
  }) {
    return UserProfile(
      uid: uid,
      email: email,
      displayName: displayName ?? this.displayName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
    );
  }
}
