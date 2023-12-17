// import 'package:flutter/widgets.dart';

// abstract class BaseController extends ChangeNotifier {}

// class ControllerQuery<T extends BaseController> extends InheritedWidget {
//   const ControllerQuery(
//       {super.key, required this.controller, required super.child});
//   final T? controller;
//   static J? of<J extends BaseController>(BuildContext context) {
//     return context
//         .dependOnInheritedWidgetOfExactType<ControllerQuery<J>>()!
//         .controller;
//   }

//   @override
//   bool updateShouldNotify(covariant InheritedWidget oldWidget) {
//     return false;
//   }
// }
