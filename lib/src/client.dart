import 'dart:async';
import 'dart:io';

class Client {
  late Socket _socket;
  late final StreamController<dynamic> _streamController;

  /// Callback function that returns the port number of the closed socket.
  Function()? onSocketDone;

  /// The port used by the server.
  int get port => _socket.port;

  /// The stream used to listen to the server events.
  Stream<dynamic> get stream => _streamController.stream;

  /// Connect to the server on the given address and port.
  ///
  /// If [port] is not specified, `8080` will be used.
  ///
  /// [sourceAddress] and [sourcePort] can be used to specify a local address and port.
  /// If [sourcePort] is not specified, a port will be chosen.
  Future<bool> connect(String address,
      {int? port, dynamic sourceAddress, int? sourcePort}) async {
    _streamController = StreamController<dynamic>.broadcast();

    try {
      _socket = await Socket.connect(
        address,
        port ?? 8080,
        sourceAddress: sourceAddress,
        sourcePort: sourcePort ?? 0,
      );
    } catch (e) {
      _streamController.sink.addError(e);
      return false;
    }

    print(
        "Connected to ${_socket.remoteAddress.address}:${_socket.remotePort} from ${_socket.address.address}:${_socket.port}");

    _socket.listen(
      (data) {
        final response = String.fromCharCodes(data);
        _streamController.sink.add(response);
      },
      onError: (error) {
        print(
            "Server ${_socket.remoteAddress.address}:${_socket.remotePort} got an error");
        _streamController.sink.addError(error);
        _socket.destroy();
      },
      onDone: () {
        print(
            // "Server ${_socket.remoteAddress.address}:${_socket.remotePort} is done";
            "Server is done");
        onSocketDone!();
        _socket.destroy();
      },
    );

    return true;
  }

  /// Disconnects from the server.
  Future<void> disconnect() async {
    _socket.destroy();
    await _streamController.close();
  }

  /// Sends a message to the server.
  void send(String message) {
    _socket.write(message);
  }
}
