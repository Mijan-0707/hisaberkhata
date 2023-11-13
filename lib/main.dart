import 'package:flutter/material.dart';
import 'package:hisaberkhata/appdata/appdata.dart';
import 'package:hisaberkhata/core/data_model/student.dart';
import 'package:hisaberkhata/core/theme/app_theme.dart';
import 'package:hisaberkhata/feature/home/screen/home_screen.dart';
import 'package:hisaberkhata/screens/inherited_widget.dart';
import 'package:hisaberkhata/screens/student_info_screen.dart';
import 'package:isar/isar.dart';
import 'package:shared_preferences/shared_preferences.dart';

// import 'package:hisaberkhata/screens/studentlist.dart';
// import 'package:hisaberkhata/screens/studentprofile.dart';

main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.getInstance().then((prefs) {
    final themeIndex = prefs.getInt('theme') ?? 0;
    themeValueNotifier.value = ThemeMode.values[themeIndex];
  });

  // print(dir.path);

  // ..name = 'Rahul'
  // ..mobile = '1234567890'
  // ..address = 'Kolkata'
  // ..roll = '1'
  // ..payment = '1000'
  // ..batch = 'Batch 1'
  // ..section = 'A'
  // ..paymentHistory = ['1000', '2000', '3000'];

  // await isar.writeTxn(() async {
  //   await isar.students.put(std);
  // });
  // print(await isar.students.filter().batchEqualTo('value').findAll());
  // dart run build_runner build
  // dart run build_runner build --delete-conflicting-outputs
  // flutter pub run build_runner build
  AppData appData = AppData();
  await appData.initialize();
  runApp(
    AppDataProvider(
      appData: appData,
      child: ValueListenableBuilder<ThemeMode>(
          valueListenable: themeValueNotifier,
          builder: (context, themeMode, child) {
            return MaterialApp(
              themeMode: themeMode,
              theme: AppTheme.lightTheme,
              darkTheme: AppTheme.darkTheme,
              home: const HomeScreen(),
            );
          }),
    ),
  );
}

class StreamTest extends StatelessWidget {
  const StreamTest({super.key});

  @override
  Widget build(BuildContext context) {
    final isar = AppDataProvider.of(context).appData.isar!;
    final studentsStream = isar.students
        .filter()
        .batchIdEqualTo(1)
        .nameContains('12')
        .or()
        .mobileContains('12')
        .build()
        .watch(fireImmediately: true);
    return Scaffold(
      floatingActionButton: FloatingActionButton(onPressed: () async {
        final res = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => StudentInfoScreen(batchId: 1),
          ),
        );

        if (res != null) {
          isar.writeTxn(() async {
            await isar.students.put(res as Student);
          });
        }
      }),
      body: StreamBuilder(
        stream: studentsStream,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                return ListTile(
                  onTap: () async {
                    final res = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => StudentInfoScreen.update(
                            batchId: 1, details: snapshot.data![index]),
                      ),
                    );

                    if (res != null) {
                      isar.writeTxn(() async {
                        await isar.students.put(res as Student);
                      });
                    }
                  },
                  title: Text(snapshot.data![index].name ?? ''),
                  subtitle: Text(snapshot.data![index].mobile ?? ''),
                );
              },
            );
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}
