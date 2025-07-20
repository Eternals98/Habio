class UserProfileModel {
  final String uid;
  final String email;
  final String displayName;
  final String? avatarUrl;
  final bool onboardingCompleted;

  const UserProfileModel({
    required this.uid,
    required this.email,
    required this.displayName,
    this.avatarUrl,
    this.onboardingCompleted = false,
  });

  factory UserProfileModel.fromMap(Map<String, dynamic> map, String uid) {
    return UserProfileModel(
      uid: uid,
      email: map['email'] ?? '',
      displayName: map['displayName'] ?? '',
      avatarUrl: map['avatarUrl'],
      onboardingCompleted: map['onboardingCompleted'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'displayName': displayName,
      'avatarUrl': avatarUrl,
      'onboardingCompleted': onboardingCompleted,
    };
  }
}
