/// Thrown when a [SocketClient] or [SocketServer] is used in an invalid state,
/// such as connecting while already connected, or sending while disconnected.
class SocketStateException implements Exception {
  final String message;

  const SocketStateException(this.message);

  @override
  String toString() => 'SocketStateException: $message';
}
