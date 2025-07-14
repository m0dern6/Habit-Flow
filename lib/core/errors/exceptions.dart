class ServerException implements Exception {
  final String message;
  const ServerException({required this.message});
}

class CacheException implements Exception {
  final String message;
  const CacheException({required this.message});
}

class NetworkException implements Exception {
  final String message;
  const NetworkException({required this.message});
}

class AuthException implements Exception {
  final String message;
  const AuthException({required this.message});
}

class ValidationException implements Exception {
  final String message;
  const ValidationException({required this.message});
}
