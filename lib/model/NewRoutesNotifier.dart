import 'package:flutter/material.dart';

class NewRoutesNotifier extends ChangeNotifier {
  int _newRoutesCount = 0;

  int get newRoutesCount => _newRoutesCount;

  bool get hasNewRoutes => _newRoutesCount > 0;

  void addNewRoute() {
    _newRoutesCount++;
    notifyListeners();
  }

  void clearRoutes() {
    _newRoutesCount = 0;
    notifyListeners();
  }

  void setNewRoutesCount(int count) {
    _newRoutesCount = count;
    notifyListeners();
  }
}
