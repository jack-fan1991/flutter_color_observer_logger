sealed class Result<T> {}

class Loading<T> extends Result<T> {
  Loading();
}

class Success<T> extends Result<T> {
  Success(this.data);
  final T data;
}

class Error<T> extends Result<T> {
  Error(this.error);
  final T error;
}
