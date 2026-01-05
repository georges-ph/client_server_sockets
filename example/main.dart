import 'dart:io';

import 'package:client_server_sockets/client_server_sockets.dart';

void main(List<String> args) {
  if (args.isEmpty) {
    print("No args passed");
    print("\nUsage:");
    print("Server: dart example/main.dart s");
    print("Client: dart example/main.dart c");
    print("Client with prompt: dart example/main.dart cp");
    print("\nStart the server in a terminal, and in a second terminal start the client. Then start in a third terminal another client with prompt to send messages to the first client.");
    return;
  }
  if (args.first == "s") _server();
  if (args.first == "c") _client();
  if (args.first == "cp") _client(true);
}

void _server() async {
  Server.instance.onServerError.listen((error) {
    print("Server error: $error");
  });

  Server.instance.onNewClient.listen((client) {
    print("New client: ${client.remotePort}");
  });

  Server.instance.onClientData.listen((event) {
    Payload payload = Payload.fromJson(event.data);
    print("Message from client ${event.client.remotePort}: $payload");
    Server.instance.sendTo(payload.port, payload.data);
  });

  Server.instance.onClientError.listen((event) {
    print("Error from client ${event.client.remotePort}: ${event.error}");
  });

  Server.instance.onClientLeft.listen((client) {
    print("Client ${client.port} left");
  });

  try {
    await Server.instance.start(8080);
    print("Server running on ${Server.instance.port}");
  } catch (e) {
    print("Couldn't start server: $e");
    return;
  }

  Future.delayed(const Duration(seconds: 10), () {
    String? message;
    do {
      print("Enter message to broadcast:");
      message = stdin.readLineSync();
    } while (message == null || message.isEmpty);

    Server.instance.broadcast(message);
  });
}

void _client([bool prompt = false]) async {
  Client.instance.onClientError.listen((error) {
    print("Client error: $error");
  });

  Client.instance.onServerData.listen((data) {
    print("Message from server: $data");
  });

  Client.instance.onServerError.listen((error) {
    print("Error from server: $error");
  });

  Client.instance.onServerStopped.listen((_) {
    print("Server stopped");
  });

  try {
    await Client.instance.connect("192.168.1.12", 8080);
    print("Connected to server!");
    if (prompt) _prompts();
  } catch (e) {
    print("Couldn't connect to server: $e");
    return;
  }
}

void _prompts() {
  Future.delayed(const Duration(seconds: 10), () {
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
