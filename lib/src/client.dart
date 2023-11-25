import 'dart:async';
import 'dart:io';

import 'package:client_server_sockets/src/configs.dart';

class Client {
  /// Client singleton; single instance.
  // Use named constructor to create the singleton
  static final Client instance = Client._internal();
  Client._internal();

  Socket? _client;

  /// Get the [port] on which the client is connected from
  int? get port => _client?.port;

  /// Get the [remotePort] on which the client socket is connected to.
  int? get remotePort => _client?.remotePort;

  /// Connects to the server on the specified address and port.
  /// If [port] is not specified, `kPort` is used instead.
  ///
  /// Errors thrown by the client are passed in [onClientError].
  ///
  /// Data received by the server is passed to [onServerData].
  ///
  /// Errors by the server are passed to [onServerError].
  ///
  /// Use [onServerStopped] to know when the server stopped.
  ///
  /// Returns `true` if the connection is successful and `false` otherwise.
  Future<bool> connect(
    String address, {
    int? port,
    void Function(String error)? onClientError,
    void Function(String data)? onServerData,
    void Function(String error)? onServerError,
    void Function()? onServerStopped,
  }) async {
    // Try to connect to the server
    try {
      _client = await Socket.connect(address, port ?? kPport);
    } catch (e) {
      // Client couldn't connect to server, return false
      // and pass the error message to the callback
      if (onClientError != null) onClientError(e.toString());
      return false;
    }

    // Listen for the data received from the server
    _client?.listen(
      (data) {
        // The server sent data
        // Data received by server
        final response = String.fromCharCodes(data);
        // Pass the response to the callback
        if (onServerData != null) onServerData(response);
      },
      onError: (error) {
        // The sever had errors
        // Pass the error to the callback
        if (onServerError != null) onServerError(error.toString());
        // Make sure the connection is closed
        _client?.destroy();
      },
      onDone: () {
        if (onServerStopped != null) onServerStopped();
        // Make sure the connection is closed
        _client?.destroy();
      },
    );

    return true;
  }

  /// Disconnects from the server
  void disconnect() {
    _client?.destroy();
  }

  /// Sends a message to the server.
  void send(String message) {
    _client?.write(message);
  }
}
