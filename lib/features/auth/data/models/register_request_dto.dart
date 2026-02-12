class RegisterRequestDto {
  final String username;
  final String password;
  final String? email;

  const RegisterRequestDto({
    required this.username,
    required this.password,
    this.email,
  });

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{'username': username, 'password': password};
    if (email != null && email!.isNotEmpty) {
      json['email'] = email;
    }
    return json;
  }
}
