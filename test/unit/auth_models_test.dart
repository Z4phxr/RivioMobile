import 'package:flutter_test/flutter_test.dart';
import 'package:habit_tracker/features/auth/data/models/login_request_dto.dart';
import 'package:habit_tracker/features/auth/data/models/register_request_dto.dart';

void main() {
  group('Auth DTOs', () {
    test('LoginRequestDto serializes correctly', () {
      const dto = LoginRequestDto(
        username: 'testuser',
        password: 'password123',
      );

      final json = dto.toJson();

      expect(json['username'], 'testuser');
      expect(json['password'], 'password123');
      expect(json.length, 2);
    });

    test('RegisterRequestDto serializes with all fields', () {
      const dto = RegisterRequestDto(
        username: 'newuser',
        password: 'secure123',
        email: 'test@example.com',
      );

      final json = dto.toJson();

      expect(json['username'], 'newuser');
      expect(json['password'], 'secure123');
      expect(json['email'], 'test@example.com');
    });

    test('RegisterRequestDto serializes without email', () {
      const dto = RegisterRequestDto(
        username: 'newuser',
        password: 'secure123',
      );

      final json = dto.toJson();

      expect(json['username'], 'newuser');
      expect(json['password'], 'secure123');
      expect(json.containsKey('email'), false);
    });
  });
}
