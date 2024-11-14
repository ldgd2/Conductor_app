// lib/model/pedido.dart

class Pedido {
  final int? id; // El ID es opcional, solo necesario para pedidos existentes
  final int idCliente;
  final DateTime fechaEntrega;
  final double ubicacionLatitud;
  final double ubicacionLongitud;
  final String estado;

  // Constructor
  Pedido({
    this.id,
    required this.idCliente,
    required this.fechaEntrega,
    required this.ubicacionLatitud,
    required this.ubicacionLongitud,
    required this.estado,
  });

  // Método para crear un objeto Pedido a partir de JSON
  factory Pedido.fromJson(Map<String, dynamic> json) {
    return Pedido(
      id: json['id'],
      idCliente: json['id_cliente'],
      fechaEntrega: DateTime.parse(json['fecha_entrega']),
      ubicacionLatitud: (json['ubicacion_latitud'] as num).toDouble(),
      ubicacionLongitud: (json['ubicacion_longitud'] as num).toDouble(),
      estado: json['estado'],
    );
  }

  // Método para convertir un objeto Pedido a JSON
  Map<String, dynamic> toJson() {
    return {
      'id_cliente': idCliente,
      'fecha_entrega': fechaEntrega.toIso8601String(),
      'ubicacion_latitud': ubicacionLatitud,
      'ubicacion_longitud': ubicacionLongitud,
      'estado': estado,
    };
  }
}
