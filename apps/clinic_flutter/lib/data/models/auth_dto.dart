import 'package:clinic_flutter/core/utils/json_utils.dart';
import 'package:clinic_flutter/domain/models/clinic.dart';
import 'package:clinic_flutter/domain/models/user.dart';

class TokenDto {
  const TokenDto({
    required this.accessToken,
    required this.refreshToken,
    required this.tokenType,
  });

  final String accessToken;
  final String refreshToken;
  final String tokenType;

  factory TokenDto.fromJson(Map<String, dynamic> json) {
    return TokenDto(
      accessToken: asString(json['access_token']) ?? '',
      refreshToken: asString(json['refresh_token']) ?? '',
      tokenType: asString(json['token_type']) ?? 'bearer',
    );
  }
}

class UserDto {
  const UserDto({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    this.professionalId,
    required this.isActive,
  });

  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final String? professionalId;
  final bool isActive;

  factory UserDto.fromJson(Map<String, dynamic> json) {
    return UserDto(
      id: asString(json['id']) ?? '',
      email: asString(json['email']) ?? '',
      firstName: asString(json['first_name']) ?? '',
      lastName: asString(json['last_name']) ?? '',
      professionalId: asString(json['professional_id']),
      isActive: asBool(json['is_active'], fallback: true),
    );
  }

  User toDomain() {
    return User(
      id: id,
      email: email,
      firstName: firstName,
      lastName: lastName,
      professionalId: professionalId,
      isActive: isActive,
    );
  }
}

class ClinicMembershipDto {
  const ClinicMembershipDto({
    required this.id,
    required this.name,
    required this.role,
    required this.subscriptionActive,
    this.subscriptionEndDate,
  });

  final String id;
  final String name;
  final String role;
  final bool subscriptionActive;
  final String? subscriptionEndDate;

  factory ClinicMembershipDto.fromJson(Map<String, dynamic> json) {
    return ClinicMembershipDto(
      id: asString(json['id']) ?? '',
      name: asString(json['name']) ?? '',
      role: asString(json['role']) ?? '',
      subscriptionActive: asBool(json['subscription_active'], fallback: true),
      subscriptionEndDate: asString(json['subscription_end_date']),
    );
  }

  ClinicMembership toDomain() {
    return ClinicMembership(
      id: id,
      name: name,
      role: role,
      subscriptionActive: subscriptionActive,
      subscriptionEndDate: subscriptionEndDate,
    );
  }
}

class MeDto {
  const MeDto({
    required this.user,
    required this.clinics,
    required this.permissions,
  });

  final UserDto user;
  final List<ClinicMembershipDto> clinics;
  final List<String> permissions;

  factory MeDto.fromJson(Map<String, dynamic> json) {
    return MeDto(
      user: UserDto.fromJson(asMap(json['user']) ?? const {}),
      clinics: asList(json['clinics'])
          .map((item) => ClinicMembershipDto.fromJson(asMap(item) ?? const {}))
          .toList(),
      permissions: asList(json['permissions'])
          .map((item) => asString(item))
          .whereType<String>()
          .toList(),
    );
  }

  /// `/me` is wrapped in `{ data: ... }`; some callers may pass the inner map.
  factory MeDto.fromResponse(dynamic json) {
    final map = asMap(json);
    if (map == null) {
      throw FormatException('Expected JSON object for /me response');
    }
    final data = asMap(map['data']);
    if (data != null) {
      return MeDto.fromJson(data);
    }
    return MeDto.fromJson(map);
  }
}
