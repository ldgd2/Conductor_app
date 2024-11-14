// lib/model/produccion.dart

class Produccion {
  final int? id; // El ID es opcional ya que solo es necesario para producciones existentes
  final int idTerreno;
  final int idTemporada;
  final int idProducto;
  final int idUnidadMedida;
  final String descripcion;
  final int cantidad;
  final DateTime fechaCosecha;
  final DateTime fechaExpiracion;
  final String estado;

  // Constructor
  Produccion({
    this.id,
    required this.idTerreno,
    required this.idTemporada,
    required this.idProducto,
    required this.idUnidadMedida,
    required this.descripcion,
    required this.cantidad,
    required this.fechaCosecha,
    required this.fechaExpiracion,
    required this.estado,
  });

  // Método para crear un objeto Produccion a partir de JSON
  factory Produccion.fromJson(Map<String, dynamic> json) {
    return Produccion(
      id: json['id'],
      idTerreno: json['id_terreno'],
      idTemporada: json['id_temporada'],
      idProducto: json['id_producto'],
      idUnidadMedida: json['id_unidadmedida'],
      descripcion: json['descripcion'],
      cantidad: json['cantidad'],
      fechaCosecha: DateTime.parse(json['fecha_cosecha']),
      fechaExpiracion: DateTime.parse(json['fecha_expiracion']),
      estado: json['estado'],
    );
  }

  // Método para convertir un objeto Produccion a JSON
  Map<String, dynamic> toJson() {
    return {
      'id_terreno': idTerreno,
      'id_temporada': idTemporada,
      'id_producto': idProducto,
      'id_unidadmedida': idUnidadMedida,
      'descripcion': descripcion,
      'cantidad': cantidad,
      'fecha_cosecha': fechaCosecha.toIso8601String(),
      'fecha_expiracion': fechaExpiracion.toIso8601String(),
      'estado': estado,
    };
  }
}
