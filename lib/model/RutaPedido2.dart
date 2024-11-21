import 'package:latlong2/latlong.dart' as latLngLib;

class RutaPedido {
  final int id;
  final DateTime fechaEntrega;
  final double capacidadUtilizada;
  final double distanciaTotal;
  final String estado;
  final List<latLngLib.LatLng> points;

  RutaPedido({
    required this.id,
    required this.fechaEntrega,
    required this.capacidadUtilizada,
    required this.distanciaTotal,
    required this.estado,
    required this.points,
  });

  factory RutaPedido.fromJson(Map<String, dynamic> json) {
    return RutaPedido(
      id: json['id'] ?? 0,
      fechaEntrega: json['fechaEntrega'] != null
          ? DateTime.parse(json['fechaEntrega'])
          : DateTime.now(),
      capacidadUtilizada: json['capacidadUtilizada'] != null
          ? (json['capacidadUtilizada'] is String
              ? double.parse(json['capacidadUtilizada'])
              : json['capacidadUtilizada'])
          : 0.0,
      distanciaTotal: json['distanciaTotal'] != null
          ? (json['distanciaTotal'] is String
              ? double.parse(json['distanciaTotal'])
              : json['distanciaTotal'])
          : 0.0,
      estado: json['estado'] ?? 'Desconocido',
      points: json['points'] != null
          ? (json['points'] as List<dynamic>)
              .map((point) => latLngLib.LatLng(point['lat'], point['lon']))
              .toList()
          : [],
    );
  }
}
