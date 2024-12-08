
class RutaOferta {
  final int id;
  final String fechaRecogida;
  final double capacidadUtilizada;
  final double distanciaTotal;
  final String estado;

  RutaOferta({
    required this.id,
    required this.fechaRecogida,
    required this.capacidadUtilizada,
    required this.distanciaTotal,
    required this.estado,
  });

  factory RutaOferta.fromJson(Map<String, dynamic> json) {
    return RutaOferta(
      id: json['id'],
      fechaRecogida: json['fecha_recogida'],
      capacidadUtilizada: _parseDouble(json['capacidad_utilizada']),
      distanciaTotal: _parseDouble(json['distancia_total']),
      estado: json['estado'] ?? "activo", // Valor por defecto
    );
  }
 static double _parseDouble(dynamic value) {
    if (value is String) {
      return double.tryParse(value) ?? 0.0; // Convierte de String a double, o retorna 0.0 si la conversión falla.
    }
    return value?.toDouble() ?? 0.0; // Si ya es un número, lo convierte a double.
  }
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fecha_recogida': fechaRecogida,
      'capacidad_utilizada': capacidadUtilizada,
      'distancia_total': distanciaTotal,
      'estado': estado,
    };
  }
}
