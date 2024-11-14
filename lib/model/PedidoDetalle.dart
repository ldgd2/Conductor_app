// lib/model/pedido_detalle.dart

class PedidoDetalle {
  final int? id; // El ID es opcional, solo necesario para detalles de pedido existentes
  final int idPedido;
  final int idProducto;
  final int idUnidadMedida;
  final int cantidad;
  final int cantidadOfertada;

  // Constructor
  PedidoDetalle({
    this.id,
    required this.idPedido,
    required this.idProducto,
    required this.idUnidadMedida,
    required this.cantidad,
    required this.cantidadOfertada,
  });

  // Método para crear un objeto PedidoDetalle a partir de JSON
  factory PedidoDetalle.fromJson(Map<String, dynamic> json) {
    return PedidoDetalle(
      id: json['id'],
      idPedido: json['id_pedido'],
      idProducto: json['id_producto'],
      idUnidadMedida: json['id_unidadmedida'],
      cantidad: json['cantidad'],
      cantidadOfertada: json['cantidad_ofertada'],
    );
  }

  // Método para convertir un objeto PedidoDetalle a JSON
  Map<String, dynamic> toJson() {
    return {
      'id_pedido': idPedido,
      'id_producto': idProducto,
      'id_unidadmedida': idUnidadMedida,
      'cantidad': cantidad,
      'cantidad_ofertada': cantidadOfertada,
    };
  }
}
