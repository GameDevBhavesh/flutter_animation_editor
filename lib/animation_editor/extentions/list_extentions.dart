extension ListExtentions<T> on List<T> {
  List<T> union(dynamic Function(T element) getProperty) {
    Map<dynamic, T> uniqueObjects = {};

    for (var obj in this) {
      var propertyValue = getProperty(obj);
      if (!uniqueObjects.containsKey(propertyValue)) {
        uniqueObjects[propertyValue] = obj;
      } else {
        // Merge or update objects with the same property value here if needed
      }
    }

    return uniqueObjects.values.toList();
  }
}
