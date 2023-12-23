class NoPermissionException implements Exception {
  final dynamic message;

  NoPermissionException([this.message]);

  @override
  String toString() {
    Object? message = this.message;
    if (message == null) return 'NoPermissionException';
    return 'NoPermissionException: $message';
  }
}
