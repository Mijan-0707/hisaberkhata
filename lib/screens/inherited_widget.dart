// continuing from previous example...
import 'package:flutter/material.dart';
import 'package:hisaberkhata/appdata/appdata.dart';

class AppDataProvider extends InheritedWidget {
  const AppDataProvider({
    super.key,
    required this.appData,
    required super.child,
  });

  final AppData appData;

  static AppDataProvider? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<AppDataProvider>();
  }

  static AppDataProvider of(BuildContext context) {
    final AppDataProvider? result = maybeOf(context);
    assert(result != null, 'No AppDataProvider found in context');
    return result!;
  }

  @override
  bool updateShouldNotify(AppDataProvider oldWidget) => true;
}

// class MyPage extends StatelessWidget {
//   const MyPage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: FrogColor(
//         color: Colors.green,
//         child: Builder(
//           builder: (BuildContext innerContext) {
//             return Text(
//               'Hello Frog',
//               style: TextStyle(color: FrogColor.of(innerContext).color),
//             );
//           },
//         ),
//       ),
//     );
//   }
// }
