class AppUser {
  final String name, email;
  final bool google; // true bila akun hanya punya login Google (tanpa sandi)
  const AppUser(this.name, this.email, {this.google = false});
}

class AuthException implements Exception {
  final String message;
  AuthException(this.message);
  @override
  String toString() => message;
}
