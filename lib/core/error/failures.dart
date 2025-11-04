abstract class Failure {
  final String message;
  final dynamic details;

  const Failure({
    required this.message,
    this.details,
  });

  @override
  String toString() => 'Failure: $message${details != null ? ' ($details)' : ''}';
}

class ServerFailure extends Failure {
  const ServerFailure({required super.message, super.details});
}

class CacheFailure extends Failure {
  const CacheFailure({required super.message, super.details});
}

class NetworkFailure extends Failure {
  const NetworkFailure({required super.message, super.details});
}

class ValidationFailure extends Failure {
  const ValidationFailure({required super.message, super.details});
}

class AuthenticationFailure extends Failure {
  const AuthenticationFailure({required super.message, super.details});
}
