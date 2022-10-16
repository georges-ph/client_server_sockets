import 'dart:convert';
import 'dart:io';

import 'package:args/args.dart';
import 'package:client_server_sockets/client_server_sockets.dart';

Future<void> main(List<String> args) async {
  late Server server;
  late Client client;

  String serverWord = "server";
  String clientWord = "client";
  String addressWord = "address";

  var parser = ArgParser()
    ..addFlag(
      serverWord,
      abbr: serverWord.substring(0, 1),
      help: "Start the program as a server on the specified [address] option",
      negatable: false,
    )
    ..addFlag(
      clientWord,
      abbr: clientWord.substring(0, 1),
      help:
          "Start the program as a client and connect to the server using the specified [address] option",
      negatable: false,
    )
    ..addOption(
      addressWord,
      abbr: addressWord.substring(0, 1),
      help: "The IP address on which the program will run",
      valueHelp: "192.168.1.1",
    );

  final results = parser.parse(args);

  if (results.arguments.isEmpty) {
    print(parser.usage);
  } else if (results.wasParsed(serverWord) && results.wasParsed(addressWord)) {

    server = Server();
    final started = await server.startServer(results[addressWord]);
    if (!started) return;

    // Prevents a null exception
    server.onSocketDone = (port) {};

    server.stream.listen((event) {
      Payload payload = Payload.fromJson(event);
      if (payload.port != server.port) {
        server.sendTo(payload.port, payload.toJson());
      } else {
        print(payload.data);
      }
    });

  } else if (results.wasParsed(clientWord) && results.wasParsed(addressWord)) {

    client = Client();
    final connected = await client.connect(results[addressWord]);
    if (!connected) return;

    // Prevents a null exception
    client.onSocketDone = () {};

    client.stream.listen((event) {
      Payload payload = Payload.fromJson(event);
      if (payload.port == client.port) {
        print(payload.data);
      }
    });

    String destinationPort = "";
    String message = "";

    do {
      print("Enter destination port: ");
      destinationPort = stdin.readLineSync() ?? "";
    } while (destinationPort.isEmpty);

    do {
      print("Enter message to send: ");
      message = stdin.readLineSync() ?? "";
    } while (message.isEmpty);

    Payload payload = Payload(
      port: int.parse(destinationPort),
      data: message,
    );

    client.send(payload.toJson());
  }
}

class Payload {
  final int port;
  final String data;

  Payload({
    required this.port,
    required this.data,
  });

  Map<String, dynamic> toMap() {
    return {
      'port': port,
      'data': data,
    };
  }

  factory Payload.fromMap(Map<String, dynamic> map) {
    return Payload(
      port: map['port']?.toInt() ?? 0,
      data: map['data'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory Payload.fromJson(String source) =>
      Payload.fromMap(json.decode(source));
}
