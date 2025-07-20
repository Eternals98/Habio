class UserProfile {
  final String id;
  final String email;
  final String displayName;
  final String bio;
  final String photoUrl;
  final bool onboardingCompleted;

  const UserProfile({
    required this.id,
    required this.email,
    required this.displayName,
    required this.bio,
    required this.photoUrl,
    this.onboardingCompleted = false,
  });
}
