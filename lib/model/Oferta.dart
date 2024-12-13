// lib/model/oferta.dart

class Oferta {
  final int? id; 
  final int idProduccion;
  final DateTime fechaCreacion;
  final DateTime fechaExpiracion;

  // Constructor
  Oferta({
    this.id,
    required this.idProduccion,
    required this.fechaCreacion,
    required this.fechaExpiracion,
  });

  // Método para crear un objeto Oferta a partir de JSON
  factory Oferta.fromJson(Map<String, dynamic> json) {
    return Oferta(
      id: json['id'],
      idProduccion: json['id_produccion'],
      fechaCreacion: DateTime.parse(json['fecha_creacion']),
      fechaExpiracion: DateTime.parse(json['fecha_expiracion']),
    );
  }

  // Método para convertir un objeto Oferta a JSON
  Map<String, dynamic> toJson() {
    return {
      'id_produccion': idProduccion,
      'fecha_creacion': fechaCreacion.toIso8601String(),
      'fecha_expiracion': fechaExpiracion.toIso8601String(),
    };
  }
}
