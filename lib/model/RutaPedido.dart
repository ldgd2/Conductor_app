// lib/model/ruta_pedido.dart

class RutaPedido {
  final int? id; // El ID es opcional ya que solo es necesario para rutas de pedido existentes
  final DateTime fechaEntrega;
  final double capacidadUtilizada;
  final double distanciaTotal;
  final String estado;

  // Constructor
  RutaPedido({
    this.id,
    required this.fechaEntrega,
    required this.capacidadUtilizada,
    required this.distanciaTotal,
    required this.estado,
  });

  // Método para crear un objeto RutaPedido a partir de JSON
  factory RutaPedido.fromJson(Map<String, dynamic> json) {
    return RutaPedido(
      id: json['id'],
      fechaEntrega: DateTime.parse(json['fecha_entrega']),
      capacidadUtilizada: double.parse(json['capacidad_utilizada'].toString()), // Convertir String a double
      distanciaTotal: double.parse(json['distancia_total'].toString()), // Convertir String a double
      estado: json['estado'],
    );
  }

  // Método para convertir un objeto RutaPedido a JSON
  Map<String, dynamic> toJson() {
    return {
      'fecha_entrega': fechaEntrega.toIso8601String(),
      'capacidad_utilizada': capacidadUtilizada,
      'distancia_total': distanciaTotal,
      'estado': estado,
    };
  }
}
