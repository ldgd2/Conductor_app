// lib/model/oferta_detalle.dart

class OfertaDetalle {
  final int? id; // El ID es opcional, solo necesario para detalles de oferta existentes
  final int idProduccion;
  final int idOferta;
  final int idUnidadMedida;
  final int idMoneda;
  final String descripcion;
  final int cantidadFisico;
  final int cantidadComprometido;
  final double precio;

  // Constructor
  OfertaDetalle({
    this.id,
    required this.idProduccion,
    required this.idOferta,
    required this.idUnidadMedida,
    required this.idMoneda,
    required this.descripcion,
    required this.cantidadFisico,
    required this.cantidadComprometido,
    required this.precio,
  });

  // Método para crear un objeto OfertaDetalle a partir de JSON
  factory OfertaDetalle.fromJson(Map<String, dynamic> json) {
    return OfertaDetalle(
      id: json['id'],
      idProduccion: json['id_produccion'],
      idOferta: json['id_oferta'],
      idUnidadMedida: json['id_unidadmedida'],
      idMoneda: json['id_moneda'],
      descripcion: json['descripcion'],
      cantidadFisico: json['cantidad_fisico'],
      cantidadComprometido: json['cantidad_comprometido'],
      precio: (json['precio'] as num).toDouble(),
    );
  }

  // Método para convertir un objeto OfertaDetalle a JSON
  Map<String, dynamic> toJson() {
    return {
      'id_produccion': idProduccion,
      'id_oferta': idOferta,
      'id_unidadmedida': idUnidadMedida,
      'id_moneda': idMoneda,
      'descripcion': descripcion,
      'cantidad_fisico': cantidadFisico,
      'cantidad_comprometido': cantidadComprometido,
      'precio': precio,
    };
  }
}
