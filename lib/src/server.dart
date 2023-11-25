import 'dart:io';

import 'package:client_server_sockets/src/configs.dart';

class Server {
  /// Server singleton; single instance.
  // Use named constructor to create the singleton
  static final Server instance = Server._internal();
  Server._internal();

  ServerSocket? _server;

  /// Get the [port] on which the server socket is listening on.
  int? get port => _server?.port;

  // List of sockets to keep track of them
  final List<Socket> _clients = [];

  /// Starts the server socket on the local address.
  ///
  /// If [port] is not specified, `kPort` is used instead.
  ///
  /// Errors thrown by the server are passed in [onServerError].
  ///
  /// When a new client connects to the server, use [onNewClient] to get the client socket.
  ///
  /// Data received by a client is passed to [onClientData].
  ///
  /// Errors by a client are passed to [onClientError].
  ///
  /// Use [onClientLeft] to know when a client closed the connection.
  ///
  /// Returns `true` if the server starts successfully and `false` otherwise.
  Future<bool> start({
    int? port,
    void Function(String error)? onServerError,
    void Function(Socket client)? onNewClient,
    void Function(Socket client, String data)? onClientData,
    void Function(Socket client, String error)? onClientError,
    void Function(Socket client)? onClientLeft,
  }) async {
    // Try to start the server socket
    try {
      _server = await ServerSocket.bind("0.0.0.0", port ?? kPport);
    } catch (e) {
      // Server could not be started, return false
      // and pass the error message to the callback
      if (onServerError != null) onServerError(e.toString());
      return false;
    }

    // Listen for incoming connections from clients
    _server?.listen(
      (client) {
        // Save current socket to use it in [onDone]
        Socket doneClient = client;

        // Add the current socket to the list of sockets
        _clients.add(client);

        // New incoming connection from a client
        // Pass the client socket to the callback
        if (onNewClient != null) onNewClient(client);

        // Listen for each client's socket
        client.listen(
          (data) {
            // The client sent data
            // Data received by client
            final response = String.fromCharCodes(data);
            // Pass the response to the callback along with client socket
            if (onClientData != null) onClientData(client, response);
          },
          onError: (error) {
            // The client had errors
            // Pass the error to the callback along with client socket
            if (onClientError != null) onClientError(client, error.toString());
            // Close the client connection
            client.close();
          },
          onDone: () {
            // The client has closed the connection
            // Pass the saved client to the callback
            if (onClientLeft != null) onClientLeft(doneClient);
            // Make sure the client closed the connection
            client.close();
          },
        );
      },
      onError: (error) {
        if (onServerError != null) onServerError(error.toString());
      },
      onDone: () {},
    );

    return true;
  }

  /// Stops the server after destroying all sockets.
  void stop() {
    for (var client in _clients) {
      client.destroy();
    }

    // Clear the list of clients
    _clients.clear();

    // Close the socket
    _server?.close();
  }

  /// Broadcast a message to all clients.
  void broadcast(String message) {
    for (var client in _clients) {
      client.write(message);
    }
  }

  /// Send a message to a specific client using its port.
  void sendTo(int port, String message) {
    Socket client =
        _clients.singleWhere((element) => element.remotePort == port);
    client.write(message);
  }
}
