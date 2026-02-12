class User {
  final int id;
  final String username;
  final String? email;

  const User({required this.id, required this.username, this.email});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is User && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
