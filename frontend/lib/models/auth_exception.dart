class AuthException implements Exception {
  const AuthException({required this.code, required this.message});

  final String code;
  final String message;

  @override
  String toString() {
    return 'AuthException(code: $code, message: $message)';
  }
}
