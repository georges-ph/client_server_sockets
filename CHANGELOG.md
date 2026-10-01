## [2.0.0] - 2026-09-11

**Breaking changes**

- Rebuilt on WebSocket (`package:web_socket_channel`) instead of raw `dart:io` `Socket`/`ServerSocket`. `SocketClient` now runs on every platform, including web — raw TCP sockets can never work in a browser.
- `SocketServer` remains native-only (a browser page cannot accept incoming connections), but the package now compiles cleanly when imported from a web app.
- Replaced the global singletons `Client.instance`/`Server.instance` with instantiable classes `SocketClient()`/`SocketServer()`, so an app can run more than one of each.
- Clients are now identified by a server-assigned `int clientId` instead of a raw `Socket`/remote port. `Payload.port` is now `Payload.clientId`.
- Replaced `dart:io`'s `SocketException` with a new `SocketStateException` for invalid-state errors (not available on web, and not really the right fit for app-level state errors).

## [1.1.2] - 2026-01-05

- Fixed accessing properties of a closed socket

## [1.1.1] - 2026-01-05

**Breaking changes**

- Replaced callback functions with stream events
- Methods throw a `SocketException` when used in an invalid state
- Exposed a `clients` getter in `Server` class to access the connected clients
- Replaced the default server port with a random port chosen by the system
- Removed `remotePort` in `Client` class as it's already known when connecting to the server

## [1.0.1] - 2023-11-25

- Exported `payload` file to the package

## [1.0.0] - 2023-11-25

### Breaking change

- Re-written package from scratch. 
- New package, new usage, new example

## [0.0.2] - 2022-10-16

- Changed example file to `main.dart` so the *Example* tab shows up
- Removed `Getting Started` section from *README*

## [0.0.1] - 2022-10-16

- Initial version.
