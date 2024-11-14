// lib/model/ruta_oferta.dart

class RutaOferta {
  final int? id; // El ID es opcional, solo es necesario para rutas de oferta existentes
  final DateTime fechaRecogida;
  final double capacidadUtilizada;
  final double distanciaTotal;
  final String estado;

  // Constructor
  RutaOferta({
    this.id,
    required this.fechaRecogida,
    required this.capacidadUtilizada,
    required this.distanciaTotal,
    required this.estado,
  });

  // Método para crear un objeto RutaOferta a partir de JSON
  factory RutaOferta.fromJson(Map<String, dynamic> json) {
    return RutaOferta(
      id: json['id'],
      fechaRecogida: DateTime.parse(json['fecha_recogida']),
      capacidadUtilizada: (json['capacidad_utilizada'] as num).toDouble(),
      distanciaTotal: (json['distancia_total'] as num).toDouble(),
      estado: json['estado'],
    );
  }

  // Método para convertir un objeto RutaOferta a JSON
  Map<String, dynamic> toJson() {
    return {
      'fecha_recogida': fechaRecogida.toIso8601String(),
      'capacidad_utilizada': capacidadUtilizada,
      'distancia_total': distanciaTotal,
      'estado': estado,
    };
  }
}
