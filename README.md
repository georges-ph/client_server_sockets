A simple WebSocket-based client-server package that works on every platform, including web.

`SocketClient` runs anywhere Dart/Flutter runs — native and web — since it's built on WebSocket rather than raw TCP sockets (which browsers can't open). `SocketServer` runs on native platforms only, since a browser page can never accept incoming connections.

## Usage

Start the server:
```dart
final server = SocketServer();
await server.start(); // pass a port, or omit for a random one
```

Connect a client to it (works from native code and from web):
```dart
final client = SocketClient();
await client.connect(serverIp, serverPort);
```

Use `secure: true` in `connect()` (`wss://` instead of `ws://`) when connecting from a web page served over `https://`, otherwise the browser will block the connection as mixed content.

Send a message to the server:
```dart
client.send("Hello World!");
```

Broadcast a message to all connected clients:
```dart
server.broadcast("Broadcasted message");
```

Send a message to one specific client using the `clientId` it was assigned in `server.onNewClient`:
```dart
server.sendTo(clientId, "Hello, client!");
```

To route a message from one client to another through the server, use the `Payload` class along with `sendTo()` — check the [example](https://pub.dev/packages/client_server_sockets/example) for more info.

## Trying the example

Native server and client:
```
dart run example/main.dart s
dart run example/main.dart c
```

Web client — open `example/web/index.html` through a real `http://` server rather than double-clicking it, since browsers block script loading (including compiled `dart2js` output) from `file://` pages:
```
dart run tool/serve_web_example.dart
```
then visit `http://localhost:8000` with the native server already running.
