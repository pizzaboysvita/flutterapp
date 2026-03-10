import 'dart:convert';

class UserModel {
  final String userId;
  final String roleId;
  final String firstName;
  final String lastName;
  final String email;
  final String profile;
  final String phoneNumber;
  final String refreshToken;
  final Map<String, dynamic> permissions;

  UserModel({
    required this.userId,
    required this.roleId,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.profile,
    required this.phoneNumber,
    required this.refreshToken,
    required this.permissions,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      userId: json["user_id"] ?? 0,
      roleId: json["role_id"] ?? 0,
      firstName: json["first_name"] ?? "",
      lastName: json["last_name"] ?? "",
      email: json["email"] ?? "",
      profile: json["profiles"] ?? "",
      phoneNumber: json["phone_number"] ?? "",
      refreshToken: json["refresh_token"] ?? "",
      permissions: json["permissions"] is String
          ? jsonDecode(json["permissions"])
          : json["permissions"] ?? {},
    );
  }

  UserModel copyWith({
    String? firstName,
    String? lastName,
    String? email,
    String? profile,
    String? phoneNumber,
  }) {
    return UserModel(
      userId: userId,
      roleId: roleId,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      profile: profile ?? this.profile,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      refreshToken: refreshToken,
      permissions: permissions,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "user_id": userId,
      "role_id": roleId,
      "first_name": firstName,
      "last_name": lastName,
      "email": email,
      "profiles": profile,
      "phone_number": phoneNumber,
      "refresh_token": refreshToken,
      "permissions": permissions,
    };
  }

  static UserModel empty() => UserModel(
        userId: '0',
        roleId: '0',
        firstName: "",
        lastName: "",
        email: "",
        profile: "",
        phoneNumber: "",
        refreshToken: "",
        permissions: {},
      );
}
