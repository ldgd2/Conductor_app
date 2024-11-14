// lib/model/categoria.dart

class Categoria {
  final int? id; // El ID es opcional ya que solo es necesario para categorías existentes
  final String nombre;
  final String descripcion;

  // Constructor
  Categoria({
    this.id,
    required this.nombre,
    required this.descripcion,
  });

  // Método para crear un objeto Categoria a partir de JSON
  factory Categoria.fromJson(Map<String, dynamic> json) {
    return Categoria(
      id: json['id'],
      nombre: json['nombre'],
      descripcion: json['descripcion'],
    );
  }

  // Método para convertir un objeto Categoria a JSON
  Map<String, dynamic> toJson() {
    return {
      'nombre': nombre,
      'descripcion': descripcion,
    };
  }
}
