// lib/model/temporada.dart

class Temporada {
  final int? id; // El ID es opcional ya que solo es necesario cuando la temporada existe
  final String nombre;
  final DateTime fechaInicio;
  final DateTime fechaFin;
  final String descripcion;

  // Constructor
  Temporada({
    this.id,
    required this.nombre,
    required this.fechaInicio,
    required this.fechaFin,
    required this.descripcion,
  });

  // Método para crear un objeto Temporada a partir de JSON
  factory Temporada.fromJson(Map<String, dynamic> json) {
    return Temporada(
      id: json['id'],
      nombre: json['nombre'],
      fechaInicio: DateTime.parse(json['fecha_inicio']),
      fechaFin: DateTime.parse(json['fecha_fin']),
      descripcion: json['descripcion'],
    );
  }

  // Método para convertir un objeto Temporada a JSON
  Map<String, dynamic> toJson() {
    return {
      'nombre': nombre,
      'fecha_inicio': fechaInicio.toIso8601String(),
      'fecha_fin': fechaFin.toIso8601String(),
      'descripcion': descripcion,
    };
  }
}
