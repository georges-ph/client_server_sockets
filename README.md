A simple client-server sockets package that uses the Socket and ServerSocket classes.

## Getting started

Add the dependency:
```yaml
dependencies:
  sockets: ^0.0.1
```

Import the package:
```dart
import 'package:sockets/sockets.dart';
```

## Usage

Start the server on an address you want:
```dart
Server server = Server();
await server.startServer("192.168.1.2");
```

Add the callback function to prevent it from throwing a null exception:
```dart
server.onSocketDone = (port) {
    // Logic for when socket is closed
};
```

Listen to the response stream:
```dart
server.stream.listen(print);
```

Now initialize the client and connect to the server:
```dart
Client client = Client();
await client.connect("192.168.1.2");
```

Add the callback function to prevent it from throwing a null exception:
```dart
client.onSocketDone = () {
  // Logic for when socket is closed
};
```

Listen to the response stream:
```dart
client.stream.listen(print);
```

To send a message to the server, use the `send()` function like this:
```dart
client.send("Hello World!");
```
