import 'package:saveco2/logic.dart';
import 'package:flutter/material.dart';
import 'package:saveco2/routes.dart';
import 'layout.dart';


void main() {
  runApp(const App());
}


///Start and building routes
class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "SaveCO2!",
      theme: ThemeData(
        primarySwatch: Colors.green,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: Routes.home,
      routes: {
        Routes.newentry: (context) => EntryLayout(),
        Routes.information: (context) => InformationLayout(),
        Routes.settings: (context) => SettingsLayout(),
        Routes.user: (context) => UserLayout(),
      },
      home: AppLogic.startApp(),
    );
  }
}

