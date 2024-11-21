import 'package:google_maps_flutter/google_maps_flutter.dart';

class RutaPedido {
  final int id;
  final DateTime fechaEntrega;
  final double capacidadUtilizada;
  final double distanciaTotal;
  final String estado;
  final List<LatLng> points;

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
      id: json['id'] ?? 0, // Valor predeterminado si es null
      fechaEntrega: json['fechaEntrega'] != null
          ? DateTime.parse(json['fechaEntrega'])
          : DateTime.now(), // Fecha predeterminada si es null
      capacidadUtilizada: json['capacidadUtilizada'] != null
          ? (json['capacidadUtilizada'] is String
              ? double.parse(json['capacidadUtilizada'])
              : json['capacidadUtilizada'])
          : 0.0, // Valor predeterminado si es null
      distanciaTotal: json['distanciaTotal'] != null
          ? (json['distanciaTotal'] is String
              ? double.parse(json['distanciaTotal'])
              : json['distanciaTotal'])
          : 0.0, // Valor predeterminado si es null
      estado: json['estado'] ?? 'Desconocido', // Valor predeterminado si es null
      points: json['points'] != null
          ? (json['points'] as List<dynamic>)
              .map((point) => LatLng(point['lat'], point['lng']))
              .toList()
          : [], // Lista vacía si es null
    );
  }
}

