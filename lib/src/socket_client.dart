import 'dart:async';

import 'package:web_socket_channel/web_socket_channel.dart';

import 'exceptions.dart';

/// A WebSocket-based client that connects to a [SocketServer].
///
/// Works on every platform Dart/Flutter supports, including web, since it's
/// built on top of `package:web_socket_channel` rather than raw TCP sockets.
class SocketClient {
  WebSocketChannel? _channel;
  StreamSubscription? _subscription;

  final _onData = StreamController<String>.broadcast();
  final _onError = StreamController<String>.broadcast();
  final _onDone = StreamController<void>.broadcast();

  /// Whether the client is currently connected to a server.
  bool get isConnected => _channel != null;

  /// Data received from the server is passed to this stream.
  Stream<String> get onData => _onData.stream;

  /// Errors on the connection are passed to this stream.
  Stream<String> get onError => _onError.stream;

  /// Fires once when the server closes the connection.
  Stream<void> get onDone => _onDone.stream;

  /// Connects to a [SocketServer] at the given [host] and [port].
  ///
  /// Set [secure] to `true` to connect over `wss://` instead of `ws://`
  /// (required when connecting from a web page served over `https://`).
  ///
  /// Throws a [SocketStateException] if already connected.
  Future<void> connect(
    String host,
    int port, {
    bool secure = false,
    String path = '',
  }) async {
    if (_channel != null) {
      throw const SocketStateException('Client is already connected');
    }

    final uri = Uri(
      scheme: secure ? 'wss' : 'ws',
      host: host,
      port: port,
      path: path,
    );

    final channel = WebSocketChannel.connect(uri);
    try {
      await channel.ready;
    } catch (e) {
      await channel.sink.close();
      rethrow;
    }

    _channel = channel;
    _subscription = channel.stream.listen(
      (data) => _onData.add(data as String),
      onError: (error) {
        _onError.add(error.toString());
        _cleanup();
      },
      onDone: () {
        _onDone.add(null);
        _cleanup();
      },
    );
  }

  /// Disconnects from the server.
  ///
  /// Throws a [SocketStateException] if not connected.
  Future<void> disconnect() async {
    if (_channel == null) {
      throw const SocketStateException('Client is not connected');
    }
    final channel = _channel!;
    _cleanup();
    await channel.sink.close();
  }

  /// Sends [data] to the server.
  ///
  /// Throws a [SocketStateException] if not connected.
  void send(String data) {
    if (_channel == null) {
      throw const SocketStateException('Client is not connected');
    }
    _channel!.sink.add(data);
  }

  void _cleanup() {
    _subscription?.cancel();
    _subscription = null;
    _channel = null;
  }
}
