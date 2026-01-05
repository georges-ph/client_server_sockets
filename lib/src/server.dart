import 'dart:async';
import 'dart:io';

class Server {
  /// Server singleton; single instance.
  static final Server instance = Server._internal();
  Server._internal();

  // The server socket
  ServerSocket? _server;

  /// Get the [port] on which the server socket is listening on.
  int? get port => _server?.port;

  // List of sockets to keep track of them
  final List<Socket> _clients = [];

  /// Get the list of connected clients' sockets.
  List<Socket> get clients => List.unmodifiable(_clients);

  // Stream controllers for events
  final _onServerError = StreamController<String>.broadcast();
  final _onNewClient = StreamController<Socket>.broadcast();
  final _onClientData = StreamController<({Socket client, String data})>.broadcast();
  final _onClientError = StreamController<({Socket client, String error})>.broadcast();
  final _onClientLeft = StreamController<Socket>.broadcast();

  /// Errors thrown by the server will use this stream.
  Stream<String> get onServerError => _onServerError.stream;

  /// When a new client connects to the server, its socket will be passed to this stream.
  Stream<Socket> get onNewClient => _onNewClient.stream;

  /// Data received by a client is passed to this stream.
  Stream<({Socket client, String data})> get onClientData => _onClientData.stream;

  /// Errors by a client are passed to this stream.
  Stream<({Socket client, String error})> get onClientError => _onClientError.stream;

  /// To know when a client closed the connection, use this stream.
  Stream<Socket> get onClientLeft => _onClientLeft.stream;

  /// Starts the server socket on the local address.
  ///
  /// If [port] is not specified, a random port will be chosen.
  ///
  /// Throws a [SocketException] if the server is already running.
  Future<void> start([int? port]) async {
    // Check if the server is already running
    if (_server != null) {
      throw SocketException("Server is already running", port: _server!.port);
    }

    // Try to start the server socket
    try {
      _server = await ServerSocket.bind(InternetAddress.anyIPv4, port ?? 0);
      // Listen for incoming connections from clients and handle errors
      _server!.listen(
        _handleClient,
        onError: (error) => _onServerError.add(error.toString()),
      );
    } catch (e) {
      // Server could not be started. Rethrow the exception
      rethrow;
    }
  }

  void _handleClient(Socket client) {
    // New client connected. Save the socket to be used in [onDone]
    Socket doneClient = client;

    // Add the current socket to the list of clients sockets and pass it to the stream
    _clients.add(client);
    _onNewClient.add(client);

    // Listen for each client's socket
    client.listen(
      (data) {
        // Add the data received by the client to the stream along with the socket itself
        _onClientData.add((client: client, data: String.fromCharCodes(data)));
      },
      onError: (error) {
        // Add the client and the error to the stream
        _onClientError.add((client: client, error: error.toString()));
        // Destroy the client connection and remove it from the list
        client.destroy();
        _clients.remove(client);
      },
      onDone: () {
        // The client has closed the connection. Notify the stream
        _onClientLeft.add(doneClient);
        // Make sure the client closed the connection and remove from the list
        client.destroy();
        _clients.remove(client);
      },
    );
  }

  /// Stops the server after destroying all sockets.
  ///
  /// Throws a [SocketException] if the server is already stopped.
  Future<void> stop() async {
    // Check if the server is already running
    if (_server == null) throw const SocketException("Server is already stopped");

    // Destroy all client sockets
    _clients.forEach((client) => client.destroy());

    // Clear the list of clients
    _clients.clear();

    // Close the socket
    await _server!.close();
    _server = null;
  }

  /// Broadcast data to all clients.
  ///
  /// Throws a [SocketException] if the server is not running.
  void broadcast(String data) {
    // Check if the server is stopped
    if (_server == null) throw const SocketException("Server is not running");

    // Send the data to all clients
    _clients.forEach((client) => client.write(data));
  }

  /// Send data to a specific client using its port.
  ///
  /// Throws a [SocketException] if the server is not running or if the port is not found.
  void sendTo(int port, String data) {
    // Check if the server is stopped
    if (_server == null) throw const SocketException("Server is not running");

    // Send the data to the specific client
    // Shouldn't throw as port is in list but just in case
    try {
      Socket client = _clients.singleWhere((element) => element.remotePort == port);
      client.write(data);
    } catch (e) {
      throw SocketException("Client with port $port not found");
    }
  }
}
