class UserModel {
  final int id;
  final String username;
  final String email;
  final String? firstName;
  final String? lastName;
  final String? phoneNumber;
  final String? avatar;
  final String? bio;
  final String? location;
  final String preferredLanguage;
  final bool isPremium;
  final DateTime? premiumSince;
  final int followersCount;
  final int followingCount;
  final int recipesCount;
  final DateTime createdAt;

  UserModel({
    required this.id,
    required this.username,
    required this.email,
    this.firstName,
    this.lastName,
    this.phoneNumber,
    this.avatar,
    this.bio,
    this.location,
    required this.preferredLanguage,
    required this.isPremium,
    this.premiumSince,
    required this.followersCount,
    required this.followingCount,
    required this.recipesCount,
    required this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      username: json['username'],
      email: json['email'],
      firstName: json['first_name'],
      lastName: json['last_name'],
      phoneNumber: json['phone_number'],
      avatar: json['avatar'],
      bio: json['bio'],
      location: json['location'],
      preferredLanguage: json['preferred_language'] ?? 'ar',
      isPremium: json['is_premium'] ?? false,
      premiumSince: json['premium_since'] != null
          ? DateTime.parse(json['premium_since'])
          : null,
      followersCount: json['followers_count'] ?? 0,
      followingCount: json['following_count'] ?? 0,
      recipesCount: json['recipes_count'] ?? 0,
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'first_name': firstName,
      'last_name': lastName,
      'phone_number': phoneNumber,
      'avatar': avatar,
      'bio': bio,
      'location': location,
      'preferred_language': preferredLanguage,
      'is_premium': isPremium,
      'premium_since': premiumSince?.toIso8601String(),
      'followers_count': followersCount,
      'following_count': followingCount,
      'recipes_count': recipesCount,
      'created_at': createdAt.toIso8601String(),
    };
  }

  String get fullName {
    if (firstName != null && lastName != null) {
      return '$firstName $lastName';
    } else if (firstName != null) {
      return firstName!;
    }
    return username;
  }
}
