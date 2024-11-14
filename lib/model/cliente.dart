// lib/model/cliente.dart

class Cliente {
  final int? id; // El ID es opcional porque solo se usa para clientes existentes
  final String nombre;
  final String apellido;
  final String email;
  final String telefono;
  final String password;
  final String direccion;

  // Constructor
  Cliente({
    this.id,
    required this.nombre,
    required this.apellido,
    required this.email,
    required this.telefono,
    required this.password,
    required this.direccion,
  });

  // Método para crear un objeto Cliente a partir de JSON
  factory Cliente.fromJson(Map<String, dynamic> json) {
    return Cliente(
      id: json['id'],
      nombre: json['nombre'],
      apellido: json['apellido'],
      email: json['email'],
      telefono: json['telefono'],
      password: json['password'],
      direccion: json['direccion'],
    );
  }

  // Método para convertir un objeto Cliente a JSON
  Map<String, dynamic> toJson() {
    return {
      'nombre': nombre,
      'apellido': apellido,
      'email': email,
      'telefono': telefono,
      'password': password,
      'direccion': direccion,
    };
  }
}
