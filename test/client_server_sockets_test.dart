import 'package:client_server_sockets/client_server_sockets.dart';
import 'package:test/test.dart';

void main() {
  late SocketServer server;

  setUp(() => server = SocketServer());

  tearDown(() async {
    if (server.port != null) await server.stop();
  });

  test('client connects and server assigns a clientId', () async {
    await server.start();

    final newClientFuture = server.onNewClient.first;
    final client = SocketClient();
    await client.connect('localhost', server.port!);

    final clientId = await newClientFuture;
    expect(clientId, 0);
    expect(server.clientIds, [0]);
    expect(client.isConnected, isTrue);

    await client.disconnect();
  });

  test('client -> server data delivery', () async {
    await server.start();
    final client = SocketClient();
    await client.connect('localhost', server.port!);

    final dataFuture = server.onClientData.first;
    client.send('hello from client');

    final event = await dataFuture;
    expect(event.data, 'hello from client');

    await client.disconnect();
  });

  test('server sendTo and broadcast deliver to the client', () async {
    await server.start();
    final client = SocketClient();
    await client.connect('localhost', server.port!);
    final clientId = await server.onNewClient.first;

    final firstMessage = client.onData.first;
    server.sendTo(clientId, 'direct message');
    expect(await firstMessage, 'direct message');

    final secondMessage = client.onData.first;
    server.broadcast('broadcast message');
    expect(await secondMessage, 'broadcast message');

    await client.disconnect();
  });

  test('server.onClientLeft fires when the client disconnects', () async {
    await server.start();
    final client = SocketClient();
    await client.connect('localhost', server.port!);
    final clientId = await server.onNewClient.first;

    final leftFuture = server.onClientLeft.first;
    await client.disconnect();

    expect(await leftFuture, clientId);
  });

  test('SocketClient throws when connecting twice', () async {
    await server.start();
    final client = SocketClient();
    await client.connect('localhost', server.port!);

    expect(
      () => client.connect('localhost', server.port!),
      throwsA(isA<SocketStateException>()),
    );

    await client.disconnect();
  });

  test('SocketClient.send throws when not connected', () {
    final client = SocketClient();
    expect(() => client.send('data'), throwsA(isA<SocketStateException>()));
  });

  test('SocketServer.sendTo throws for an unknown clientId', () async {
    await server.start();
    expect(
      () => server.sendTo(999, 'data'),
      throwsA(isA<SocketStateException>()),
    );
  });
}
