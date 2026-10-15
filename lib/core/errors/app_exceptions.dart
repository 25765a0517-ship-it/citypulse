class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic details;

  AppException(this.message, {this.code, this.details});

  @override
  String toString() => message;
}

class AuthException extends AppException {
  AuthException(super.message, {super.code, super.details});
}

class NetworkException extends AppException {
  NetworkException([super.message = 'Network connection failed. Please check your internet.']);
}

class PermissionException extends AppException {
  PermissionException(super.message);
}

class NotFoundException extends AppException {
  NotFoundException(super.message);
}
