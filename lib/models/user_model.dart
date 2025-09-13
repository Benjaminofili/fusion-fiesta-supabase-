// lib/models/user_model.dart
import 'dart:convert';
import 'package:hive/hive.dart';

part 'user_model.g.dart';

@HiveType(typeId: 0)
class UserModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String email;

  @HiveField(3)
  String password;

  @HiveField(4)
  String? phone;

  @HiveField(5)
  String role; // "visitor" | "participant" | "staff"

  @HiveField(6)
  String? enrollmentNumber;

  @HiveField(7)
  String? department;

  @HiveField(8)
  String? collegeIdProofUrl;

  @HiveField(9)
  bool approved;

  @HiveField(10)
  bool isLocalOnly;

  @HiveField(11)
  String? sessionToken;

  @HiveField(12)
  DateTime createdAt;

  @HiveField(13)
  DateTime updatedAt;

  @HiveField(14)
  DateTime lastModified;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.password,
    this.phone,
    required this.role,
    this.enrollmentNumber,
    this.department,
    this.collegeIdProofUrl,
    this.approved = false,
    this.isLocalOnly = false,
    this.sessionToken,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastModified,
  })  : createdAt = createdAt ?? DateTime.now().toUtc(),
        updatedAt = updatedAt ?? DateTime.now().toUtc(),
        lastModified = lastModified ?? DateTime.now().toUtc();

  /// Convert Map → UserModel
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] as String,
      name: map['name'] as String,
      email: map['email'] as String,
      password: map['password'] ?? '',
      phone: map['phone'],
      role: map['role'] as String,
      enrollmentNumber: map['enrollment_number'],
      department: map['department'],
      collegeIdProofUrl: map['college_id_proof_url'],
      approved: map['approved'] ?? false,
      isLocalOnly: map['is_local_only'] ?? false,
      sessionToken: map['session_token'],
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'])
          : DateTime.now().toUtc(),
      updatedAt: map['updated_at'] != null
          ? DateTime.parse(map['updated_at'])
          : DateTime.now().toUtc(),
      lastModified: map['last_modified'] != null
          ? DateTime.parse(map['last_modified'])
          : DateTime.now().toUtc(),
    );
  }

  /// Convert UserModel → Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'password': password,
      'phone': phone,
      'role': role,
      'enrollment_number': enrollmentNumber,
      'department': department,
      'college_id_proof_url': collegeIdProofUrl,
      'approved': approved,
      'is_local_only': isLocalOnly,
      'session_token': sessionToken,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'last_modified': lastModified.toIso8601String(),
    };
  }

  /// JSON helpers (String <-> Model)
  String toJsonString() => json.encode(toMap());

  factory UserModel.fromJsonString(String source) =>
      UserModel.fromMap(json.decode(source));

  /// Map helpers (Map <-> Model)
  factory UserModel.fromJson(Map<String, dynamic> json) =>
      UserModel.fromMap(json);
}
