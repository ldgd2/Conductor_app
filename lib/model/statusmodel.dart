import 'package:flutter/foundation.dart';

class StatusModel with ChangeNotifier {
  int? _conductorId;
  String? _token;
  bool _isActive = false;

  int? get conductorId => _conductorId;
  String? get token => _token;
  bool get isActive => _isActive;

  void setStatus(int conductorId, String token, bool isActive) {
    _conductorId = conductorId;
    _token = token;
    _isActive = isActive;
    notifyListeners();
  }

  void clearStatus() {
    _conductorId = null;
    _token = null;
    _isActive = false;
    notifyListeners();
  }
}
