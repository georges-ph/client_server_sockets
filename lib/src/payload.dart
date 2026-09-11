import 'dart:convert';

class Payload {
  final int clientId;
  final String data;

  Payload({
    required this.clientId,
    required this.data,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'clientId': clientId,
      'data': data,
    };
  }

  factory Payload.fromMap(Map<String, dynamic> map) {
    return Payload(
      clientId: map['clientId'] as int,
      data: map['data'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory Payload.fromJson(String source) =>
      Payload.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() => 'Payload(clientId: $clientId, data: $data)';
}
