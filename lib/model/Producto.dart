// lib/model/producto.dart

class Producto {
  final int? id; // El ID es opcional ya que solo es necesario para productos existentes
  final int idCategoria;
  final String nombre;
  final String descripcion;

  // Constructor
  Producto({
    this.id,
    required this.idCategoria,
    required this.nombre,
    required this.descripcion,
  });

  // Método para crear un objeto Producto a partir de JSON
  factory Producto.fromJson(Map<String, dynamic> json) {
    return Producto(
      id: json['id'],
      idCategoria: json['id_categoria'],
      nombre: json['nombre'],
      descripcion: json['descripcion'],
    );
  }

  // Método para convertir un objeto Producto a JSON
  Map<String, dynamic> toJson() {
    return {
      'id_categoria': idCategoria,
      'nombre': nombre,
      'descripcion': descripcion,
    };
  }
}
