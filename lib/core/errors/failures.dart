import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  const Failure([List properties = const <dynamic>[]]);

  @override
  List<Object> get props => [];
}

// General failures
class ServerFailure extends Failure {
  final String? message;
  const ServerFailure({this.message});

  @override
  List<Object> get props => [message ?? ''];
}

class CacheFailure extends Failure {
  final String? message;
  const CacheFailure({this.message});

  @override
  List<Object> get props => [message ?? ''];
}

class NetworkFailure extends Failure {
  final String? message;
  const NetworkFailure({this.message});

  @override
  List<Object> get props => [message ?? ''];
}

class AuthFailure extends Failure {
  final String? message;
  const AuthFailure({this.message});

  @override
  List<Object> get props => [message ?? ''];
}

class ValidationFailure extends Failure {
  final String message;
  const ValidationFailure({required this.message});

  @override
  List<Object> get props => [message];
}

class UnknownFailure extends Failure {
  final String? message;
  const UnknownFailure({this.message});

  @override
  List<Object> get props => [message ?? ''];
}
