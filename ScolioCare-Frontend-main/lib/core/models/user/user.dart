class User {
  final String userId;
  final String email;
  final String? firstName;
  final String? lastName;
  final String? phone;
  final bool isActive;
  final bool emailVerified;
  final bool phoneVerified;
  final DateTime createdAt;
  final DateTime? lastLogin;

  User({
    required this.userId,
    required this.email,
    this.firstName,
    this.lastName,
    this.phone,
    required this.isActive,
    required this.emailVerified,
    required this.phoneVerified,
    required this.createdAt,
    this.lastLogin,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      userId: json['userId'] as String,
      email: json['email'] as String,
      firstName: json['firstName'] as String?,
      lastName: json['lastName'] as String?,
      phone: json['phone'] as String?,
      isActive: json['isActive'] as bool? ?? true,
      emailVerified: json['emailVerified'] as bool? ?? false,
      phoneVerified: json['phoneVerified'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
      lastLogin: json['lastLogin'] != null
          ? DateTime.parse(json['lastLogin'] as String)
          : null,
    );
  }

  String get fullName {
    final parts = [firstName, lastName]
        .whereType<String>()
        .map((part) => part.trim())
        .where((part) => part.isNotEmpty)
        .toList();
    final name = parts.join(' ');
    return name.isNotEmpty ? name : '';
  }

  User copyWith({
    String? email,
    String? firstName,
    String? lastName,
    String? phone,
    bool? isActive,
    bool? emailVerified,
    bool? phoneVerified,
    DateTime? createdAt,
    DateTime? lastLogin,
  }) {
    return User(
      userId: userId,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      phone: phone ?? this.phone,
      isActive: isActive ?? this.isActive,
      emailVerified: emailVerified ?? this.emailVerified,
      phoneVerified: phoneVerified ?? this.phoneVerified,
      createdAt: createdAt ?? this.createdAt,
      lastLogin: lastLogin ?? this.lastLogin,
    );
  }

  Map<String, dynamic> toJson() => {
        'userId': userId,
        'email': email,
        'firstName': firstName,
        'lastName': lastName,
        'phone': phone,
        'isActive': isActive,
        'emailVerified': emailVerified,
        'phoneVerified': phoneVerified,
        'createdAt': createdAt.toIso8601String(),
        'lastLogin': lastLogin?.toIso8601String(),
      };
}
