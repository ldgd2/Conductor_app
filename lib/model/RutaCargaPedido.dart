// lib/model/ruta_carga_pedido.dart

class RutaCargaPedido {
  final int? id; // El ID es opcional ya que solo es necesario para rutas de carga de pedido existentes
  final int idCargaPedido;
  final int idRutaPedido;
  final int idTransporte;
  final int orden;
  final String estado;
  final double distancia;

  // Constructor
  RutaCargaPedido({
    this.id,
    required this.idCargaPedido,
    required this.idRutaPedido,
    required this.idTransporte,
    required this.orden,
    required this.estado,
    required this.distancia,
  });

  // Método para crear un objeto RutaCargaPedido a partir de JSON
  factory RutaCargaPedido.fromJson(Map<String, dynamic> json) {
    return RutaCargaPedido(
      id: json['id'],
      idCargaPedido: json['id_carga_pedido'],
      idRutaPedido: json['id_ruta_pedido'],
      idTransporte: json['id_transporte'],
      orden: json['orden'],
      estado: json['estado'],
      distancia: (json['distancia'] as num).toDouble(),
    );
  }

  // Método para convertir un objeto RutaCargaPedido a JSON
  Map<String, dynamic> toJson() {
    return {
      'id_carga_pedido': idCargaPedido,
      'id_ruta_pedido': idRutaPedido,
      'id_transporte': idTransporte,
      'orden': orden,
      'estado': estado,
      'distancia': distancia,
    };
  }
}
