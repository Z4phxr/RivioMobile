import '../../domain/entities/user.dart';
import '../../domain/entities/tokens.dart';

class AuthResponseDto {
  final UserDto user;
  final String access;
  final String refresh;

  const AuthResponseDto({
    required this.user,
    required this.access,
    required this.refresh,
  });

  factory AuthResponseDto.fromJson(Map<String, dynamic> json) {
    // Handle Django response format: {username, user_id, access, refresh}
    if (json.containsKey('user_id') && json.containsKey('username')) {
      return AuthResponseDto(
        user: UserDto(
          id: int.parse(json['user_id'].toString()),
          username: json['username'] as String,
          email: json['email'] as String?,
        ),
        access: json['access'] as String,
        refresh: json['refresh'] as String,
      );
    }

    // Handle standard format: {user: {id, username, email}, access, refresh}
    return AuthResponseDto(
      user: UserDto.fromJson(json['user'] as Map<String, dynamic>),
      access: json['access'] as String,
      refresh: json['refresh'] as String,
    );
  }

  User toUserEntity() => user.toEntity();

  Tokens toTokensEntity() => Tokens(access: access, refresh: refresh);
}

class UserDto {
  final int id;
  final String username;
  final String? email;

  const UserDto({required this.id, required this.username, this.email});

  factory UserDto.fromJson(Map<String, dynamic> json) {
    // Handle Django format with user_id
    if (json.containsKey('user_id')) {
      return UserDto(
        id: int.parse(json['user_id'].toString()),
        username: json['username'] as String,
        email: json['email'] as String?,
      );
    }

    // Handle standard format with id
    return UserDto(
      id: json['id'] as int,
      username: json['username'] as String,
      email: json['email'] as String?,
    );
  }

  User toEntity() => User(id: id, username: username, email: email);
}
