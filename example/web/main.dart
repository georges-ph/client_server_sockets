// ignore_for_file: deprecated_member_use, dart:html kept for a minimal example without a build step
import 'dart:html';

import 'package:client_server_sockets/client_server_sockets.dart';

void main() {
  final hostInput = querySelector('#host') as InputElement;
  final portInput = querySelector('#port') as InputElement;
  final connectButton = querySelector('#connect') as ButtonElement;
  final messageInput = querySelector('#message') as InputElement;
  final sendButton = querySelector('#send') as ButtonElement;
  final log = querySelector('#log')!;

  final client = SocketClient();

  void addLog(String text) {
    log.append(ParagraphElement()..text = text);
    log.scrollTop = log.scrollHeight;
  }

  connectButton.onClick.listen((_) async {
    final host = hostInput.value!.isEmpty ? 'localhost' : hostInput.value!;
    final port = int.tryParse(portInput.value ?? '') ?? 8080;

    connectButton.disabled = true;
    try {
      await client.connect(host, port);
      addLog('Connected to $host:$port');
      sendButton.disabled = false;
    } catch (e) {
      addLog('Failed to connect: $e');
      connectButton.disabled = false;
    }
  });

  client.onData.listen((data) => addLog('Server: $data'));
  client.onError.listen((error) => addLog('Connection error: $error'));
  client.onDone.listen((_) {
    addLog('Server closed the connection');
    sendButton.disabled = true;
    connectButton.disabled = false;
  });

  sendButton.onClick.listen((_) {
    final message = messageInput.value ?? '';
    if (message.isEmpty) return;
    client.send(message);
    addLog('You: $message');
    messageInput.value = '';
  });

  messageInput.onKeyDown.listen((event) {
    if (event.key == 'Enter') sendButton.click();
  });
}
