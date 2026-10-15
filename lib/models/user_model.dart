enum UserRole {
  citizen,
  officer,
  admin;

  static UserRole fromString(String? role) {
    switch (role?.toLowerCase()) {
      case 'officer':
        return UserRole.officer;
      case 'admin':
        return UserRole.admin;
      case 'citizen':
      default:
        return UserRole.citizen;
    }
  }

  String toValue() {
    switch (this) {
      case UserRole.citizen:
        return 'citizen';
      case UserRole.officer:
        return 'officer';
      case UserRole.admin:
        return 'admin';
    }
  }
}

class UserModel {
  final String uid;
  final String name;
  final String email;
  final String phone;
  final UserRole role;
  final String? departmentId;
  final String? departmentName;
  final String? badgeNumber;
  final String? avatarUrl;
  final String availability; // 'available', 'busy', 'offline'
  final String? ward;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    this.phone = '',
    required this.role,
    this.departmentId,
    this.departmentName,
    this.badgeNumber,
    this.avatarUrl,
    this.availability = 'available',
    this.ward,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  UserModel copyWith({
    String? uid,
    String? name,
    String? email,
    String? phone,
    UserRole? role,
    String? departmentId,
    String? departmentName,
    String? badgeNumber,
    String? avatarUrl,
    String? availability,
    String? ward,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      departmentId: departmentId ?? this.departmentId,
      departmentName: departmentName ?? this.departmentName,
      badgeNumber: badgeNumber ?? this.badgeNumber,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      availability: availability ?? this.availability,
      ward: ward ?? this.ward,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'phone': phone,
      'role': role.toValue(),
      'departmentId': departmentId,
      'departmentName': departmentName,
      'badgeNumber': badgeNumber,
      'avatarUrl': avatarUrl,
      'availability': availability,
      'ward': ward,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map, {String? id}) {
    return UserModel(
      uid: id ?? map['uid'] as String? ?? '',
      name: map['name'] as String? ?? 'User',
      email: map['email'] as String? ?? '',
      phone: map['phone'] as String? ?? '',
      role: UserRole.fromString(map['role'] as String?),
      departmentId: map['departmentId'] as String?,
      departmentName: map['departmentName'] as String?,
      badgeNumber: map['badgeNumber'] as String?,
      avatarUrl: map['avatarUrl'] as String?,
      availability: map['availability'] as String? ?? 'available',
      ward: map['ward'] as String?,
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      updatedAt: map['updatedAt'] != null
          ? DateTime.tryParse(map['updatedAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}
