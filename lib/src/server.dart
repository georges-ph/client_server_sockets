import 'dart:async';
import 'dart:io';

class Server {
  late ServerSocket _serverSocket;
  final List<Socket> _socketsList = [];
  late final StreamController<dynamic> _streamController;

  /// Callback function that returns the port number of the closed socket.
  Function(int port)? onSocketDone;

  /// The IP address of the server.
  String get address => _serverSocket.address.address;

  /// The port used by the server.
  int get port => _serverSocket.port;

  /// The stream used to listen to the server events.
  Stream<dynamic> get stream => _streamController.stream;

  /// Starts the server on the given address.
  ///
  /// If [port] is not specified, the port `8080` will be chosen.
  Future<bool> startServer(String address, {int? port, bool? shared}) async {
    _streamController = StreamController<dynamic>.broadcast();

    try {
      _serverSocket = await ServerSocket.bind(
        address,
        port ?? 8080,
        shared: shared ?? false,
      );
    } catch (e) {
      _streamController.sink.addError(e);
      return false;
    }

    print(
        "Server running on ${_serverSocket.address.address}:${_serverSocket.port}");
    _serverSocket.listen(_listenForSockets);

    return true;
  }

  /// Stops the server.
  Future<bool> stopServer() async {
    for (var socket in _socketsList) {
      await socket.close();
    }
    _socketsList.clear();
    await _serverSocket.close();
    await _streamController.close();
    return true;
  }

  void _listenForSockets(Socket socket) {
    print(
        "Connection from ${socket.remoteAddress.address}:${socket.remotePort}");
    socket.listen(
      (data) {
        final response = String.fromCharCodes(data);
        _streamController.sink.add(response);

        if (!_socketsList.contains(socket)) {
          _socketsList.add(socket);
        }
      },
      onError: (error) {
        print(
            "Client ${socket.remoteAddress.address}:${socket.remotePort} got an error");
        _streamController.sink.addError(error);
        socket.close();
        _socketsList.remove(socket);
      },
      onDone: () {
        print(
            "Client ${socket.remoteAddress.address}:${socket.remotePort} is done");
        onSocketDone!(socket.remotePort);
        socket.close();
        _socketsList.remove(socket);
      },
    );
  }

  /// Broadcast a message to all connected sockets
  void broadcast(String message) {
    for (var socket in _socketsList) {
      socket.write(message);
    }
  }

  /// Send a message to a socket using its port number
  void sendTo(int port, String message) {
    Socket socket = _socketsList.firstWhere(
      (element) => element.remotePort == port,
    );
    socket.write(message);
  }
}
