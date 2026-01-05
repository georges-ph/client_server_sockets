A simple client-server sockets wrapper package around the Socket and the ServerSocket classes.

## Usage

Start the server using:
```dart
Server.instance.start();
```

Connect the client to the server using its address and port:
```dart
Client.instance.connect(serverIp, serverPort);
```

To send a message to the server, use the `send()` function like this:
```dart
Client.instance.send("Hello World!");
```

To broadcast a message to all clients, use the `broadcast()` function like this:
```dart
Server.instance.broadcast("Broadcasted message");
```

To send a message from a client to another, you can use the `Payload` class to help you with that along with the `sendTo()` function in the server. Check the [example](https://pub.dev/packages/client_server_sockets/example) for more info.