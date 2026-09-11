import 'dart:convert';
import 'dart:io';

import 'package:client_server_sockets/client_server_sockets.dart';

const _port = 8080;

void main(List<String> args) {
  if (args.isEmpty) {
    print("No args passed");
    print("\nUsage:");
    print("Server: dart example/main.dart s");
    print("Client: dart example/main.dart c [host]");
    print("Client with prompt: dart example/main.dart cp [host]");
    print(
      "\nStart the server in a terminal, then in a second terminal start a "
      "client. Start a third terminal with 'cp' to send messages to a "
      "specific client by id.\n"
      "[host] defaults to localhost; pass a LAN IP to connect from another "
      "device. See example/web for a browser client.",
    );
    return;
  }
  if (args.first == "s") _server();
  if (args.first == "c") _client(args.length > 1 ? args[1] : "localhost");
  if (args.first == "cp") {
    _client(args.length > 1 ? args[1] : "localhost", true);
  }
}

void _server() async {
  final server = SocketServer();

  server.onServerError.listen((error) {
    print("Server error: $error");
  });

  server.onNewClient.listen((clientId) {
    print("New client: $clientId");
  });

  server.onClientData.listen((event) {
    Payload payload = Payload.fromJson(event.data);
    print("Message from client ${event.clientId}: $payload");
    server.sendTo(payload.clientId, payload.data);
  });

  server.onClientError.listen((event) {
    print("Error from client ${event.clientId}: ${event.error}");
  });

  server.onClientLeft.listen((clientId) {
    print("Client $clientId left");
  });

  try {
    await server.start(_port);
    print("Server running on ${server.port}");
  } catch (e) {
    print("Couldn't start server: $e");
    return;
  }
  print("Enter a message and press enter to broadcast it to all clients.");
  // stdin.readLineSync() would block Dart's single event loop while waiting
  // for input, freezing the server (no new connections, no message delivery)
  // until a line is entered. Read it as a stream instead so the server stays
  // responsive at all times.
  stdin.transform(utf8.decoder).transform(const LineSplitter()).listen((
    message,
  ) {
    if (message.isEmpty) return;
    server.broadcast(message);
  });
}

void _client(String host, [bool prompt = false]) async {
  final client = SocketClient();

  client.onError.listen((error) {
    print("Client error: $error");
  });

  client.onData.listen((data) {
    print("Message from server: $data");
  });

  client.onDone.listen((_) {
    print("Server stopped");
  });

  try {
    await client.connect(host, _port);
    print("Connected to server at $host:$_port!");
  } catch (e) {
    print("Couldn't connect to server: $e");
    return;
  }

  if (prompt) {
    print("Enter '<clientId> <message>' and press enter to send it.");
    stdin.transform(utf8.decoder).transform(const LineSplitter()).listen((
      line,
    ) {
      final spaceIndex = line.indexOf(' ');
      if (spaceIndex == -1) {
        print("Expected '<clientId> <message>', got: $line");
        return;
      }

      final clientId = int.tryParse(line.substring(0, spaceIndex));
      final message = line.substring(spaceIndex + 1);
      if (clientId == null || message.isEmpty) {
        print("Expected '<clientId> <message>', got: $line");
        return;
      }

      client.send(Payload(clientId: clientId, data: message).toJson());
    });
  }
}
