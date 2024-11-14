// lib/model/carga_pedido.dart

class CargaPedido {
  final int? id; // El ID es opcional ya que solo es necesario para cargas de pedido existentes
  final int idPedidoDetalle;
  final int cantidad;
  final String estado;

  // Constructor
  CargaPedido({
    this.id,
    required this.idPedidoDetalle,
    required this.cantidad,
    required this.estado,
  });

  // Método para crear un objeto CargaPedido a partir de JSON
  factory CargaPedido.fromJson(Map<String, dynamic> json) {
    return CargaPedido(
      id: json['id'],
      idPedidoDetalle: json['id_pedido_detalle'],
      cantidad: json['cantidad'],
      estado: json['estado'],
    );
  }

  // Método para convertir un objeto CargaPedido a JSON
  Map<String, dynamic> toJson() {
    return {
      'id_pedido_detalle': idPedidoDetalle,
      'cantidad': cantidad,
      'estado': estado,
    };
  }
}
