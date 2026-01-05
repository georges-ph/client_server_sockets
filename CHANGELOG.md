## 1.1.0

**Breaking changes**

- Replaced callback functions with stream events
- Methods throw a `SocketException` when used in an invalid state
- Exposed a `clients` getter in `Server` class to access the connected clients
- Replaced the default server port with a random port chosen by the system
- Removed `remotePort` in `Client` class as it's already known when connecting to the server

## 1.0.1

- Exported `payload` file to the package

## 1.0.0

### Breaking change

- Re-written package from scratch. 
- New package, new usage, new example

## 0.0.2

- Changed example file to `main.dart` so the *Example* tab shows up
- Removed `Getting Started` section from *README*

## 0.0.1

- Initial version.