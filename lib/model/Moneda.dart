// lib/model/moneda.dart

class Moneda {
  final int? id; 
  final String nombre;

  // Constructor
  Moneda({
    this.id,
    required this.nombre,
  });

  // Método para crear un objeto Moneda a partir de JSON
  factory Moneda.fromJson(Map<String, dynamic> json) {
    return Moneda(
      id: json['id'],
      nombre: json['nombre'],
    );
  }

  // Método para convertir un objeto Moneda a JSON
  Map<String, dynamic> toJson() {
    return {
      'nombre': nombre,
    };
  }
}
