import 'package:flutter/material.dart';

class StatusModel extends ChangeNotifier {
  int? _conductorId;
  String? _token;

  // Getter para verificar si el usuario está autenticado
  bool get isAuthenticated => _conductorId != null && _token != null;

  int? get conductorId => _conductorId;
  String? get token => _token;

  // Establecer el estado del usuario
  void setStatus(int conductorId, String token, bool isAuthenticated) {
    _conductorId = conductorId;
    _token = token;
    notifyListeners();
  }

  // Limpiar el estado al cerrar sesión
  void clearStatus() {
    _conductorId = null;
    _token = null;
    notifyListeners();
  }
}
