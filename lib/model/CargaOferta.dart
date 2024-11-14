// lib/model/carga_oferta.dart

class CargaOferta {
  final int? id; // El ID es opcional ya que solo es necesario para cargas de oferta existentes
  final int idOfertaDetalle;
  final int pesoKg;
  final double precio;
  final String estado;

  // Constructor
  CargaOferta({
    this.id,
    required this.idOfertaDetalle,
    required this.pesoKg,
    required this.precio,
    required this.estado,
  });

  // Método para crear un objeto CargaOferta a partir de JSON
  factory CargaOferta.fromJson(Map<String, dynamic> json) {
    return CargaOferta(
      id: json['id'],
      idOfertaDetalle: json['id_oferta_detalle'],
      pesoKg: json['pesokg'],
      precio: (json['precio'] as num).toDouble(),
      estado: json['estado'],
    );
  }

  // Método para convertir un objeto CargaOferta a JSON
  Map<String, dynamic> toJson() {
    return {
      'id_oferta_detalle': idOfertaDetalle,
      'pesokg': pesoKg,
      'precio': precio,
      'estado': estado,
    };
  }
}
