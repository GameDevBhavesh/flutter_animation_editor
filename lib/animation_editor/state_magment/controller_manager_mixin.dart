import 'package:flutter/material.dart';
import 'controller_query.dart';

mixin MultiControllerManagerMixin<T extends BaseController> {
  final Map<String, T> _controllerMap = {};
  @protected
  // Create: Add a new controller with a given key
  void addChildController(String key, T controller) {
    _controllerMap.putIfAbsent(key, () => controller);
  }

  // Read: Get a controller by key
  T? readChildController(String key) {
    return _controllerMap[key];
  }

  bool hasChildController(String key) {
    return _controllerMap.containsKey(key);
  }

  @protected
  void updateChildController(String oldKey, String newKey, T controller) {
    if (_controllerMap.containsKey(oldKey)) {
      _controllerMap[newKey] = controller;
      if (oldKey != newKey) {
        _controllerMap.remove(oldKey);
      }
    }
  }

  @protected
  void deleteController(String key) {
    _controllerMap.remove(key);
  }

  @protected
  void disposeControllers() {
    for (var controller in _controllerMap.values) {
      controller.dispose();
    }
  }
}
