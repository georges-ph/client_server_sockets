import 'dart:async';
import 'dart:io';

import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import 'exceptions.dart';

/// A WebSocket-based server that [SocketClient]s can connect to.
///
/// Only available on platforms with `dart:io` (native/VM) — a browser tab
/// can never accept incoming connections, so this class isn't usable on web.
class SocketServer {
  HttpServer? _server;
  int _nextClientId = 0;
  final Map<int, WebSocketChannel> _clients = {};

  /// Get the [port] on which the server is listening on.
  int? get port => _server?.port;

  /// The ids of currently connected clients.
  List<int> get clientIds => List.unmodifiable(_clients.keys);

  final _onServerError = StreamController<String>.broadcast();
  final _onNewClient = StreamController<int>.broadcast();
  final _onClientData =
      StreamController<({int clientId, String data})>.broadcast();
  final _onClientError =
      StreamController<({int clientId, String error})>.broadcast();
  final _onClientLeft = StreamController<int>.broadcast();

  /// Errors thrown by the server will use this stream.
  Stream<String> get onServerError => _onServerError.stream;

  /// Fires with the assigned client id when a new client connects.
  Stream<int> get onNewClient => _onNewClient.stream;

  /// Data received from a client is passed to this stream.
  Stream<({int clientId, String data})> get onClientData =>
      _onClientData.stream;

  /// Errors from a client are passed to this stream.
  Stream<({int clientId, String error})> get onClientError =>
      _onClientError.stream;

  /// Fires with the client id when a client disconnects.
  Stream<int> get onClientLeft => _onClientLeft.stream;

  /// Starts the server on the local address.
  ///
  /// If [port] is not specified, a random port will be chosen.
  ///
  /// Throws a [SocketStateException] if the server is already running.
  Future<void> start([int? port]) async {
    if (_server != null) {
      throw const SocketStateException('Server is already running');
    }

    // Bind dual-stack (v6Only: false, the default) so both IPv4 and IPv6
    // clients can connect — notably "localhost", which many systems (incl.
    // Windows) resolve to the IPv6 loopback (::1) rather than 127.0.0.1.
    final server = await HttpServer.bind(InternetAddress.anyIPv6, port ?? 0);
    _server = server;
    server.listen(
      _handleRequest,
      onError: (error) => _onServerError.add(error.toString()),
    );
  }

  Future<void> _handleRequest(HttpRequest request) async {
    if (!WebSocketTransformer.isUpgradeRequest(request)) {
      request.response.statusCode = HttpStatus.forbidden;
      await request.response.close();
      return;
    }

    final webSocket = await WebSocketTransformer.upgrade(request);
    final channel = IOWebSocketChannel(webSocket);
    final clientId = _nextClientId++;

    _clients[clientId] = channel;
    _onNewClient.add(clientId);

    channel.stream.listen(
      (data) => _onClientData.add((clientId: clientId, data: data as String)),
      onError: (error) {
        _onClientError.add((clientId: clientId, error: error.toString()));
        _clients.remove(clientId);
      },
      onDone: () {
        _onClientLeft.add(clientId);
        _clients.remove(clientId);
      },
    );
  }

  /// Stops the server after closing all client connections.
  ///
  /// Throws a [SocketStateException] if the server is already stopped.
  Future<void> stop() async {
    if (_server == null) {
      throw const SocketStateException('Server is already stopped');
    }

    for (final client in _clients.values.toList()) {
      await client.sink.close();
    }
    _clients.clear();

    await _server!.close(force: true);
    _server = null;
  }

  /// Broadcasts [data] to all connected clients.
  ///
  /// Throws a [SocketStateException] if the server is not running.
  void broadcast(String data) {
    if (_server == null) {
      throw const SocketStateException('Server is not running');
    }
    for (final client in _clients.values) {
      client.sink.add(data);
    }
  }

  /// Sends [data] to a specific client by its [clientId].
  ///
  /// Throws a [SocketStateException] if the server is not running or the
  /// client id isn't found.
  void sendTo(int clientId, String data) {
    if (_server == null) {
      throw const SocketStateException('Server is not running');
    }
    final client = _clients[clientId];
    if (client == null) {
      throw SocketStateException('Client with id $clientId not found');
    }
    client.sink.add(data);
  }
}
