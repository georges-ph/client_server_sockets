import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

class Client {
  /// Client singleton; single instance.
  static final Client instance = Client._internal();
  Client._internal();

  // The client socket
  Socket? _client;

  /// Get the [port] on which the client is connected from
  int? get port => _client?.port;

  // Stream controllers for events
  final _onClientError = StreamController<String>.broadcast();
  final _onServerData = StreamController<Uint8List>.broadcast();
  final _onServerError = StreamController<String>.broadcast();
  final _onServerStopped = StreamController<void>.broadcast();

  /// Errors thrown by the client will use this stream.
  Stream<String> get onClientError => _onClientError.stream;

  /// Data received by the server will use this stream.
  Stream<Uint8List> get onServerData => _onServerData.stream;

  /// Errors by the server are passed to this stream.
  Stream<String> get onServerError => _onServerError.stream;

  /// Use this stream to know when the server stops.
  Stream<void> get onServerStopped => _onServerStopped.stream;

  /// Connects to the server on the specified address and port.
  ///
  /// Throws a [SocketException] if the client is already connected.
  Future<void> connect(String address, int port) async {
    // Check if the client is already connected
    if (_client != null) {
      throw SocketException("Client is already connected", port: _client!.port);
    }

    // Try to connect to the server
    try {
      _client = await Socket.connect(address, port);
      // Listen for the data received from the server and handle errors
      _client!.listen(
        (data) {
          // Data received from the server. Add it to the stream
          _onServerData.add(data);
        },
        onError: (error) {
          // The sever had errors. Add the error to the stream
          _onServerError.add(error.toString());
          // Destroy the client socket
          _client!.destroy();
          _client = null;
        },
        onDone: () {
          // Server has stopped. Notify the stream
          _onServerStopped.add(null);
          // Destroy the client socket
          _client!.destroy();
          _client = null;
        },
      );
    } catch (e) {
      // Client couldn't connect to server. Add the error to the stream
      _onClientError.add(e.toString());
    }
  }

  /// Disconnects from the server
  ///
  /// Throws a [SocketException] if the client is not connected.
  void disconnect() {
    // Check if the client is connected
    if (_client == null) throw const SocketException("Client is not connected");
    // Destroy the client socket
    _client!.destroy();
    _client = null;
  }

  /// Sends data to the server.
  ///
  /// Throws a [SocketException] if the client is not connected.
  void send(Uint8List data) {
    // Check if the client is connected
    if (_client == null) throw const SocketException("Client is not connected");
    // Send the data to the server
    _client!.write(data);
  }
}
