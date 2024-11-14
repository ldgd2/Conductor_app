// lib/model/unidad_medida.dart

class UnidadMedida {
  final int? id; // El ID es opcional, solo necesario para unidades existentes
  final String nombre;

  // Constructor
  UnidadMedida({
    this.id,
    required this.nombre,
  });

  // Método para crear un objeto UnidadMedida a partir de JSON
  factory UnidadMedida.fromJson(Map<String, dynamic> json) {
    return UnidadMedida(
      id: json['id'],
      nombre: json['nombre'],
    );
  }

  // Método para convertir un objeto UnidadMedida a JSON
  Map<String, dynamic> toJson() {
    return {
      'nombre': nombre,
    };
  }
}
