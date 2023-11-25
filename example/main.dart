import 'dart:io';

import 'package:client_server_sockets/client_server_sockets.dart';

void main(List<String> args) {
  if (args.isEmpty) {
    print("No args passed");
    print("Usage:");
    print("Server: dart example/main.dart s");
    print("Client: dart example/main.dart c");
    print("Client with prompt: dart example/main.dart cp");
    return;
  }
  if (args.first == "s") _server();
  if (args.first == "c") _client();
  if (args.first == "cp") _client(true);
}

void _server() async {
  final started = await Server.instance.start(
    onServerError: (error) {
      print("Server error: $error");
    },
    onNewClient: (client) {
      print("New client: ${client.remotePort}");
    },
    onClientData: (client, data) {
      Payload payload = Payload.fromJson(data);
      print("Message from client ${client.remotePort}: $payload");
      Server.instance.sendTo(payload.port, payload.data);
    },
    onClientError: (client, error) {
      print("Error from client ${client.remotePort}: $error");
    },
    onClientLeft: (client) {
      print("Client ${client.remotePort} left");
    },
  );

  if (!started) {
    print("Couldn't start server");
    return;
  }

  print("server running on ${Server.instance.port}");

  Future.delayed(Duration(seconds: 30), () {
    String? message;
    do {
      print("Enter message to broadcast:");
      message = stdin.readLineSync();
    } while (message == null || message.isEmpty);

    Server.instance.broadcast(message);
  });
}

void _client([bool prompt = false]) async {
  final connected = await Client.instance.connect(
    "192.168.1.10",
    onClientError: (error) {
      print("Client error: $error");
    },
    onServerData: (data) {
      print("Message from sever: $data");
    },
    onServerError: (error) {
      print("Error from server: $error");
    },
    onServerStopped: () {
      print("Server stopped");
    },
  );

  if (!connected) {
    print("Couldn't connect to server");
    return;
  }

  print("Connected to ${Client.instance.remotePort} from ${Client.instance.port}");

  if (prompt) _prompts();
}

void _prompts() {
  Future.delayed(Duration(seconds: 10), () {
    String? port;
    do {
      print("Enter client port you wish to send a message to:");
      port = stdin.readLineSync();
    } while (port == null || port.isEmpty);

    String? message;
    do {
      print("Enter message to send to client 2:");
      message = stdin.readLineSync();
    } while (message == null || message.isEmpty);

    Payload payload = Payload(port: int.parse(port), data: message);

    Client.instance.send(payload.toJson());
  });
}
