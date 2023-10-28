import 'package:flutter/material.dart';

mixin MultiControllerManagerMixin<T extends ChangeNotifier> {
  final Map<String, T> _controllerMap = {};
  // Create: Add a new controller with a given key
  void addController(String key, T controller) {
    _controllerMap.putIfAbsent(key, () => controller);
  }

  // Read: Get a controller by key
  T? readController(String key) {
    return _controllerMap[key];
  }

  void updateController(String oldKey, String newKey, T controller) {
    if (_controllerMap.containsKey(oldKey)) {
      _controllerMap[newKey] = controller;
      if (oldKey != newKey) {
        _controllerMap.remove(oldKey);
      }
    }
  }

  void deleteController(String key) {
    _controllerMap.remove(key);
  }

  void disposeControllers() {
    for (var controller in _controllerMap.values) {
      controller.dispose();
    }
  }
}
