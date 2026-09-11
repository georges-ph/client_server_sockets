// Serves example/web/ over http://, since browsers restrict script loading
// (including compiled dart2js output) when a page is opened via file://.
//
// Usage: dart run tool/serve_web_example.dart [port]
import 'dart:io';

Future<void> main(List<String> args) async {
  final port = args.isNotEmpty ? int.parse(args.first) : 8000;
  final webDir = Directory('example/web');
  if (!webDir.existsSync()) {
    stderr.writeln(
      'Could not find example/web — run this from the package root.',
    );
    exitCode = 1;
    return;
  }

  final server = await HttpServer.bind(InternetAddress.loopbackIPv4, port);
  print('Serving example/web at http://localhost:$port');
  print(
    '(the client_server_sockets server itself is separate — start it with '
    "'dart run example/main.dart s')",
  );

  await for (final request in server) {
    final requestPath = request.uri.path == '/'
        ? '/index.html'
        : request.uri.path;
    final file = File('${webDir.path}$requestPath');

    if (!file.existsSync()) {
      request.response.statusCode = HttpStatus.notFound;
      await request.response.close();
      continue;
    }

    request.response.headers.contentType = switch (requestPath
        .split('.')
        .last) {
      'html' => ContentType.html,
      'js' => ContentType('application', 'javascript'),
      'map' || 'json' => ContentType.json,
      _ => ContentType.binary,
    };
    await request.response.addStream(file.openRead());
    await request.response.close();
  }
}
