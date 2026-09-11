import 'dart:async';

const _unsupportedMessage =
    'SocketServer is not supported on the web platform: a browser page '
    'cannot accept incoming connections. Use SocketServer on a native (VM) '
    'platform instead; SocketClient works on web.';

/// Stub used on platforms without `dart:io` (i.e. web).
///
/// A browser page can never accept incoming connections, so [SocketServer]
/// isn't usable there. This stub mirrors the real API surface so that code
/// referencing [SocketServer] still type-checks on web; every operation
/// throws an [UnsupportedError] at runtime instead.
class SocketServer {
  /// Always `null` on web.
  int? get port => null;

  /// Always empty on web.
  List<int> get clientIds => const [];

  final _onServerError = StreamController<String>.broadcast();
  final _onNewClient = StreamController<int>.broadcast();
  final _onClientData =
      StreamController<({int clientId, String data})>.broadcast();
  final _onClientError =
      StreamController<({int clientId, String error})>.broadcast();
  final _onClientLeft = StreamController<int>.broadcast();

  Stream<String> get onServerError => _onServerError.stream;
  Stream<int> get onNewClient => _onNewClient.stream;
  Stream<({int clientId, String data})> get onClientData =>
      _onClientData.stream;
  Stream<({int clientId, String error})> get onClientError =>
      _onClientError.stream;
  Stream<int> get onClientLeft => _onClientLeft.stream;

  Future<void> start([int? port]) async {
    throw UnsupportedError(_unsupportedMessage);
  }

  Future<void> stop() async {
    throw UnsupportedError(_unsupportedMessage);
  }

  void broadcast(String data) {
    throw UnsupportedError(_unsupportedMessage);
  }

  void sendTo(int clientId, String data) {
    throw UnsupportedError(_unsupportedMessage);
  }
}
