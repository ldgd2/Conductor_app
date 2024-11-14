import 'package:flutter/material.dart';

class ConductorProvider with ChangeNotifier {
  int? _conductorId;
  String? _nombre;
  String? _email;

  int? get conductorId => _conductorId;
  String? get nombre => _nombre;
  String? get email => _email;

  void setConductor(int conductorId, String nombre, String email) {
    _conductorId = conductorId;
    _nombre = nombre;
    _email = email;
    notifyListeners();
  }

  void clearConductor() {
    _conductorId = null;
    _nombre = null;
    _email = null;
    notifyListeners();
  }
}
