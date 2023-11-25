import 'dart:convert';

class Payload {
  final int port;
  final String data;

  Payload({
    required this.port,
    required this.data,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'port': port,
      'data': data,
    };
  }

  factory Payload.fromMap(Map<String, dynamic> map) {
    return Payload(
      port: map['port'] as int,
      data: map['data'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory Payload.fromJson(String source) =>
      Payload.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() => 'Payload(port: $port, data: $data)';
}
