import 'package:flutter/foundation.dart';

@immutable
sealed class ResultState<T> {
  const ResultState();
}

@immutable
class Idle<T> extends ResultState<T> {
  const Idle();
}

@immutable
class Loading<T> extends ResultState<T> {
  const Loading();
}

@immutable
class Success<T> extends ResultState<T> {
  final T data;
  const Success(this.data);
}

@immutable
class Error<T> extends ResultState<T> {
  final String message;
  const Error(this.message);
}
