import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'data.dart';
import 'layout.dart';
import 'package:flutter_bloc/flutter_bloc.dart' as bloc;
import 'package:http/http.dart' as http;

class AppLogic {
  static int goal = 1000;
  static DateTime saveddayandyear = DateTime(1, 1, 1);
  static late bool isfirsttime = true;

  static User user = User();

  static List<Activity> dailyactivitylist = [];
  static List<Activity> doneactivitylist = [];
  static List<List<Activity>> activitylists = [
    dailyactivitylist,
    doneactivitylist
  ];

  static final homescreenlogic = HomescreenLogic();
  static final entrylogic = EntryLogic();
  static final httplogic = HttpLogic();
  static final savedatalogic = SaveDataLogic();
  static final settingslogic = SettingsLogic();
  static final userlogic = UserLogic();

  static void doWhenPopUpMenuOnTap() {
    settingslogic.resetEntries();
  }

  static getActivityListFromRows(snapshot) {
    String? body = snapshot.data?.body;
    Map<dynamic, dynamic> decodedtableasmap = jsonDecode(body!) as Map;
    List<String> desiredSubKeys = ["name", "co2", "type", "exclude"];

    List decodedtableasrows = decodedtableasmap["rows"];
    List<Activity> activitylist = [];

    for (Map<String, dynamic> map in decodedtableasrows) {
      map.removeWhere((key, value) => !desiredSubKeys.contains(key));

      String? excludeWordsString = map['exclude'];
      List<String> excludeWords = excludeWordsString != null ? excludeWordsString.split(',') : [];
      bool shouldExclude = shouldExcludeActivity(excludeWords);
      if (shouldExclude) {
        continue; // Überspringe die Aktivität, wenn sie ausgeschlossen werden soll
      }

      map['checkfordaily'] = true;
      map['tomorrow'] = false;
      map['co2'] = int.parse(map['co2']);
      List<dynamic> mapValues = [];
      map.forEach((key, value) => mapValues.add(value));
      activitylist.add(Activity.createActivity(map));
    }

    return activitylist;
  }

  static bool shouldExcludeActivity(List<String> excludeWords) {
    List<String> userProperties = AppLogic.user.properties;

    for (String excludeWord in excludeWords) {
      if (userProperties.contains(excludeWord.trim())) {
        return true; // Die Aktivität soll ausgeschlossen werden
      }
    }

    return false; // Die Aktivität soll nicht ausgeschlossen werden
  }



  static Widget startApp() {
    return bloc.BlocProvider(
      create: (_) => homescreenlogic,
      child: HomescreenLayout(),
    );
  }
}

class HomescreenLogic extends bloc.Cubit<List> {
  HomescreenLogic() : super(AppLogic.activitylists);

  bool showfetchbutton = true;

  void reachedSavedCO2(context) {
    TextEditingController _newgoaltextcontroller = TextEditingController();
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
              content: Container(
            width: double.maxFinite,
            child: ListView(children: [
              Text("Nice!",
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.green)),
              SizedBox(height: 5),
              Text(
                "You did very well and reached your goal of saving: ${AppLogic.goal}gCO2!",
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.green),
              ),
              SizedBox(height: 5),
              Text("You can enter a new goal now"),
              TextFormField(
                controller: _newgoaltextcontroller,
                decoration: InputDecoration(
                  labelText: 'Enter your new goal',
                  border: OutlineInputBorder(),
                ),
              ),
              TextButton(
                onPressed: () async {
                  if (int.tryParse(_newgoaltextcontroller.text) != null &&
                      int.parse(_newgoaltextcontroller.text) > 0) {
                    AppLogic.doneactivitylist = [];
                    AppLogic.goal = int.parse(_newgoaltextcontroller.text);
                    AppLogic.savedatalogic.saveData();
                    print("goal achieved");
                    Navigator.of(context).pop();
                    Navigator.pushNamed(context, "/");
                  } else {
                    _newgoaltextcontroller.text =
                        "please enter valid number (no decimal point allowed)";
                  }
                },
                child: Text('Start with the entered goal'),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.of(context).pop();
                },
                child: Text('I don\'t know my goal yet'),
              ),
            ]),
          ));
        });
  }

  void isFirstTime(BuildContext context) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext dialogcontext) {
        TextEditingController _firsttimetextcontroller =
            TextEditingController();
        return AlertDialog(
            content: Container(
          width: double.maxFinite,
          child: ListView(children: [
            Text(
              'Welcome to SaveCO2!',
              style: TextStyle(
                  fontSize: 18,
                  color: Colors.green,
                  fontWeight: FontWeight.bold),
            ),
            Text(
              "You are the first time here. The app is made to get daily activities to compensate your CO2 with daily tasks. If you already know your amount of CO2 which you want to compensate, you can enter it here. No worries, you can change it later. You can find further information on the menu-tab \"Information\". Thanks and have fun!",
              textAlign: TextAlign.justify,
            ),
            SizedBox(height: 20),
            TextFormField(
              controller: _firsttimetextcontroller,
              decoration: InputDecoration(
                labelText: 'Enter your new goal',
                border: OutlineInputBorder(),
              ),
            ),
            TextButton(
              onPressed: () async {
                if (int.tryParse(_firsttimetextcontroller.text) != null &&
                    int.parse(_firsttimetextcontroller.text) > 0) {
                  AppLogic.goal = int.parse(_firsttimetextcontroller.text);
                  Navigator.of(dialogcontext).pop();

                  Completer<void> completer = Completer<void>();
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => FirstTimeUserLayout(completer)),
                  );
                  await completer.future;

                  showDialog(
                    barrierDismissible: false,
                    context: context,
                    builder: (BuildContext dialogcontext) {
                      return AlertDialog(
                        content: Text(
                            'Perfect, now we can start! Click on \"Get Daily Tasks"'),
                        actions: [
                          TextButton(
                            onPressed: () async {
                              await AppLogic.homescreenlogic
                                  .updateHomescreenList(context, () {
                                AppLogic.isfirsttime = false;
                              });
                              Navigator.of(dialogcontext).pop();
                            },
                            child: Text('Let\'s go!'),
                          ),
                        ],
                      );
                    },
                  );
                } else {
                  _firsttimetextcontroller.text =
                      "please enter valid number (no decimal point allowed)";
                }
              },
              child: Text('Start with the entered goal'),
            ),
            TextButton(
              onPressed: () async {
                await AppLogic.homescreenlogic
                    .updateHomescreenList(context, () {
                      AppLogic.isfirsttime = false;
                });
                Navigator.of(dialogcontext).pop();
                Navigator.pushNamed(context, "/information");
              },
              child: Text('I don\'t know my goal yet'),
            ),
          ]),
        ));
      },
    );
  }

  void addNewEntry(BuildContext context) {
    Navigator.pushNamed(context, '/newentry');
  }

  Future<void> updateHomescreenList(context, Function callback) async {
    print("callback");
    await callback();
    print("callback done");

    AppLogic.activitylists = [
      AppLogic.dailyactivitylist,
      AppLogic.doneactivitylist
    ];
    await AppLogic.savedatalogic.saveData();
    print("emit");
    emit(AppLogic.activitylists);

    if (getSavedCO2() >= AppLogic.goal) {
      print("reachedCo2");
      reachedSavedCO2(context);
    }
  }

  List<Activity> addDailyActivitiesFromRows(snapshot) {
    List<Activity> activitylist = AppLogic.getActivityListFromRows(snapshot);
    activitylist.shuffle();
    activitylist = activitylist.sublist(0, 3);

    AppLogic.dailyactivitylist.addAll(activitylist);

    return activitylist;
  }

  void fetchButtonOnPressed(context, snapshot) async {
    await AppLogic.homescreenlogic.updateHomescreenList(context, () {
      AppLogic.homescreenlogic.addDailyActivitiesFromRows(snapshot);
      AppLogic.homescreenlogic.showfetchbutton = false;
      print("fetchbutton");
    });
  }

  int getSavedCO2() {
    int savedco2 = 0;
    for (var activity in AppLogic.doneactivitylist) {
      savedco2 = activity.co2 + savedco2;
    }
    return savedco2;
  }

  void taskCompletedOnPressed(activity, context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Text('Did you complete this task successfully?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('No'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return ConfettiDialog();
                    });

                await AppLogic.homescreenlogic.updateHomescreenList(context,
                    () {
                  int index = AppLogic.dailyactivitylist.indexOf(activity);
                  AppLogic.doneactivitylist
                      .add(AppLogic.dailyactivitylist[index]);
                  AppLogic.dailyactivitylist[index].checkfordaily = false;
                });
              },
              child: Text('Yes'),
            ),
          ],
        );
      },
    );
  }

  void deleteActivity(activity, context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Text('Do you really want to delete the activity?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('No'),
            ),
            TextButton(
              onPressed: () async {
                await AppLogic.homescreenlogic.updateHomescreenList(context,
                    () {
                  AppLogic.doneactivitylist.remove(activity);
                });
                Navigator.of(context).pop();
              },
              child: Text('Yes'),
            ),
          ],
        );
      },
    );
  }

  void postponeTask(activity, context) {
      AppLogic.homescreenlogic.updateHomescreenList(context, (){
        activity.tomorrow = !activity.tomorrow;
      });
  }

}

class EntryLogic {
  late Activity choosedactivity;
  Activity placeholder = Activity.createActivity(
      {"type":"general", "name": "Choose activity...", "co2": 0});

  void addEntryToData(BuildContext context) {
    try {
      if (choosedactivity != AppLogic.entrylogic.placeholder) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              content: Text('Do you want to add this acitivity?'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('No'),
                ),
                TextButton(
                  onPressed: () async {
                    await AppLogic.homescreenlogic.updateHomescreenList(context,
                        () {
                      AppLogic.doneactivitylist.add(choosedactivity);
                      AppLogic.entrylogic.choosedactivity = placeholder;
                    });
                    Navigator.of(context).pop();
                    Navigator.of(context).pushNamed('/');

                    showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return ConfettiDialog();
                        });
                  },
                  child: Text('Yes'),
                ),
              ],
            );
          },
        );
      }
    } catch (e) {} //do Nothing
  }
}

class HttpLogic {
  Future<http.Response> fetchData() async {
    String url = "cloud.seatable.io";
    String path = "api/v2.1/dtable/app-access-token/";
    Map<String, String> headers = {
      "accept": "application/json",
      "authorization": "Bearer 8fad1aab54898619f9df67dcab540840a3110fef"
    };

    var response = await http.get(Uri.https(url, path), headers: headers);

    var decoded = jsonDecode(response.body) as Map;
    String accesstoken = decoded["access_token"];
    String uuid = decoded["dtable_uuid"];
    String tablename = "Advice";

    path = "dtable-server/api/v1/dtables/$uuid/rows/";
    headers = {
      "accept": "application/json",
      "authorization": "Bearer $accesstoken"
    };
    final Map<String, String> queryParameters = <String, String>{
      'table_name': tablename,
    };

    response =
        await http.get(Uri.https(url, path, queryParameters), headers: headers);

    return response;
  }
}

class CirclePainter extends CustomPainter {
  final Color color;
  final double percentage;

  CirclePainter({required this.color, required this.percentage});

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTRB(0, 0, size.width, size.height);
    final gradient = SweepGradient(
      colors: [color, color.withOpacity(1)],
      startAngle: -pi / 2,
      endAngle: 2 * pi * percentage / 100 - pi / 2,
    );
    final paint = Paint()
      ..shader = gradient.createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.1
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(rect, -pi / 2, 2 * pi * percentage / 100, false, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

class SaveDataLogic {

  Future<void> loadData() async {
    print("start loading");
    final prefs = await SharedPreferences.getInstance();
    DateTime now = DateTime.now();
    now = DateTime(now.year, now.month, now.day);

    AppLogic.isfirsttime = (await prefs.getBool("isfirsttime") ?? true);
    AppLogic.doneactivitylist =
        jsonDecode(await prefs.getString('doneactivitylist') ?? '[]')
            .map<Activity>((json) => Activity.createActivity(json))
            .toList();
    AppLogic.saveddayandyear = DateTime.parse(
        await prefs.getString('saveddayandyear') ?? '1969-07-20');
    AppLogic.homescreenlogic.showfetchbutton =
        (await prefs.getBool("showfetchbutton") ?? true);
    AppLogic.goal = (await prefs.getInt("goal") ?? 1000);



    String user = await prefs.getString('user') ?? "no user";
    if(user != "no user"){
      dynamic jsonData = jsonDecode(user);
      AppLogic.user = User.fromJson(jsonData);
    }

    if (now.isAfter(AppLogic.saveddayandyear)) {

      AppLogic.dailyactivitylist.removeWhere((element) => element.tomorrow == false);
      for (int i = 0; i < AppLogic.dailyactivitylist.length; i++) {
        AppLogic.dailyactivitylist[i].tomorrow = false;
      }

      AppLogic.homescreenlogic.showfetchbutton = true;
      AppLogic.saveddayandyear = now;
    } else {
      AppLogic.dailyactivitylist =
          await jsonDecode(prefs.getString('dailyactivitylist') ?? '[]')
              .map<Activity>((json) => Activity.createActivity(json))
              .toList();
    }
    print("finish loading");
  }

  Future<void> saveData() async {
    print("start Saving");
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        "dailyactivitylist",
        jsonEncode(AppLogic.dailyactivitylist
            .map((activity) => activity.toJson())
            .toList()));
    await prefs.setString(
        "doneactivitylist",
        jsonEncode(AppLogic.doneactivitylist
            .map((activity) => activity.toJson())
            .toList()));
    await prefs.setString(
        "saveddayandyear", AppLogic.saveddayandyear.toString());

    await prefs.setBool(
        "showfetchbutton", AppLogic.homescreenlogic.showfetchbutton);

    await prefs.setInt("goal", AppLogic.goal);

    await prefs.setBool("isfirsttime", AppLogic.isfirsttime);

    await prefs.setString(
        "user",
        jsonEncode(AppLogic.user.toJson()));

    print("finish saving");
  }

}

class SettingsLogic {
  TextEditingController adjustgoaltextcontroller =
      TextEditingController(text: AppLogic.goal.toString());
  TextEditingController adjustsavedco2textcontroller =
      TextEditingController(text: "0");

  void adjustGoal(context) async {
    if (int.tryParse(AppLogic.settingslogic.adjustgoaltextcontroller.text) !=
            null &&
        int.parse(AppLogic.settingslogic.adjustgoaltextcontroller.text) > 0) {
      AppLogic.goal = int.parse(adjustgoaltextcontroller.text);

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: Text('Successfully changed'),
            actions: [
              TextButton(
                onPressed: () async {
                  Navigator.of(context).pop();
                  await AppLogic.homescreenlogic
                      .updateHomescreenList(context, () {});
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    } else {
      AppLogic.settingslogic.adjustgoaltextcontroller.text =
          "please enter valid number (no decimal point allowed)";
    }
  }

  void addsavedco2(context) async {
    if (int.tryParse(
                AppLogic.settingslogic.adjustsavedco2textcontroller.text) !=
            null &&
        int.parse(AppLogic.settingslogic.adjustsavedco2textcontroller.text) >
            0) {
      AppLogic.doneactivitylist.add(Activity.createActivity({"type": "general",
        "name": "Manually added CO2",
        "co2": int.parse(adjustsavedco2textcontroller.text)
      }));

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: Text('Successfully changed'),
            actions: [
              TextButton(
                onPressed: () async {
                  Navigator.of(context).pop();
                  await AppLogic.homescreenlogic
                      .updateHomescreenList(context, () {});
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    } else {
      AppLogic.settingslogic.adjustsavedco2textcontroller.text =
          "please enter valid number (no decimal point allowed)";
    }
  }

  void resetEntries() {
    adjustgoaltextcontroller =
        TextEditingController(text: AppLogic.goal.toString());
    adjustsavedco2textcontroller = TextEditingController(text: "0");
  }

  Widget resetProgress(context) {
    return AlertDialog(
      content: Text('Do you really want to reset your progress?'),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text('No'),
        ),
        TextButton(
          onPressed: () async {
            await AppLogic.homescreenlogic.updateHomescreenList(context, () {
              AppLogic.doneactivitylist = [];
              AppLogic.dailyactivitylist = [];
              AppLogic.goal = 1000;
              AppLogic.saveddayandyear = DateTime(1, 1, 1);
              AppLogic.homescreenlogic.showfetchbutton = true;
              AppLogic.isfirsttime = true;
            });
            Navigator.of(context).pop();
            Navigator.of(context).pushNamed("/");
          },
          child: Text('Yes'),
        ),
      ],
    );
  }
}

class UserLogic {
  TextEditingController consumptionController = TextEditingController(text:"0.0");
  TextEditingController co2kmController = TextEditingController(text:"0.0");

  bool hasPV = false;
  bool loadEVwithPV = false;
  bool heatwithPV = false;
  bool dontusecar = false;
  bool hasLift = false;

  String countdishes = '< 1';
  String countlaundry = '< 1';

  String eatpreference = 'I eat meat';
  String car = 'I drive with petrol';
  String heat = 'I heat with gas';

  List calculateUserProperties() {
    List<String> properties = [];
    int intcountdishes = 0;
    int intcountlaundry = 0;

    if (hasPV) {
      properties.add("hasPV");
      if (loadEVwithPV) properties.add("loadEVwithPV");
      if (heatwithPV && heat == 'I heat with eletricity')
        properties.add("heatwithPV");
    }
    if (dontusecar) properties.add("dontUseCar");
    if (!hasLift) properties.add("noLift");

    switch (eatpreference) {
      case ('I eat meat'):
        properties.add("meat");
        break;
      case ('I eat vegetarian'):
        properties.add("vegetarian");
        break;
      case ('I eat vegan'):
        properties.add("vegan");
        break;
    }

    switch (heat) {
      case ('I heat with eletricity'):
        properties.add("heatEletricity");
        break;
      case ('I heat with gas'):
        properties.add("heatGas");
        break;
      case ('I heat with Oil'):
        properties.add("heatOil");
        break;
    }

    switch (car) {
      case "I drive with petrol":
        properties.add("petrol");
        break;
      case "I drive with diesel":
        properties.add("diesel");
        break;
      case 'I drive with LPG':
        properties.add("LPG");
        break;
      case 'I drive with hybrid':
        properties.add("hybrid");
        break;
      case "I drive with eletricity":
        properties.add("ev");
        break;
      case 'I don\'t have a car':
        properties.add("noCar");
        break;
    }

    switch (countdishes) {
      case "< 1":
        intcountdishes = 0;
        break;
      case "1":
        intcountdishes = 1;
        break;
      case "2":
        intcountdishes = 2;
        break;
      case "3":
        intcountdishes = 3;
        break;
      case "4":
        intcountdishes = 4;
        break;
      case "5":
        intcountdishes = 5;
        break;
      case "6":
        intcountdishes = 6;
        break;
      case "7":
        intcountdishes = 7;
        break;
      case "> 7":
        intcountdishes = 8;
        break;
    }

    switch (countlaundry) {
      case "< 1":
        intcountlaundry = 0;
        break;
      case "1":
        intcountlaundry = 1;
        break;
      case "2":
        intcountlaundry = 2;
        break;
      case "3":
        intcountlaundry = 3;
        break;
      case "4":
        intcountlaundry = 4;
        break;
      case "5":
        intcountlaundry = 5;
        break;
      case "6":
        intcountlaundry = 6;
        break;
      case "7":
        intcountlaundry = 7;
        break;
      case "> 7":
        intcountlaundry = 8;
        break;
    }

   if(intcountlaundry<=2) properties.add("littleLaundry");
   if(intcountdishes<=3) properties.add("littleDishes");

    return [properties, double.parse(consumptionController.text), double.parse(co2kmController.text), intcountdishes, intcountlaundry];
  }

  bool calculateLogicProperties(User user){
    consumptionController.text = "${user.carconumption}";
    co2kmController.text = "${user.co2car}";

    hasPV = user.properties.contains("hasPV") ? true : false;
    loadEVwithPV = user.properties.contains("loadEVwithPV") ? true : false;
    heatwithPV = user.properties.contains("heatwithPV") ? true : false;
    dontusecar = user.properties.contains("dontUseCar") ? true : false;
    hasLift = user.properties.contains("hasLift") ? true : false;

    switch (user.countlaundry) {
      case 0:
        countlaundry = "< 1";
        break;
      case 1:
        countlaundry = "1";
        break;
      case 2:
        countlaundry = "2";
        break;
      case 3:
        countlaundry = "3";
        break;
      case 4:
        countlaundry = "4";
        break;
      case 5:
        countlaundry = "5";
        break;
      case 6:
        countlaundry = "6";
        break;
      case 7:
        countlaundry = "7";
        break;
      case 8:
        countlaundry = "> 7";
        break;
    }

    switch (user.countdishes) {
      case 0:
        countdishes = "< 1";
        break;
      case 1:
        countdishes = "1";
        break;
      case 2:
        countdishes = "2";
        break;
      case 3:
        countdishes = "3";
        break;
      case 4:
        countdishes = "4";
        break;
      case 5:
        countdishes = "5";
        break;
      case 6:
        countdishes = "6";
        break;
      case 7:
        countdishes = "7";
        break;
      case 8:
        countdishes = "> 7";
        break;
    }

    bool foundCar = false;

    for (String property in user.properties) {
      switch (property) {
        case "petrol":
          car = "I drive with petrol";
          foundCar = true;
          break;
        case "diesel":
          car = "I drive with diesel";
          foundCar = true;
          break;
        case "LPG":
          car = "I drive with LPG";
          foundCar = true;
          break;
        case "hybrid":
          car = "I drive with hybrid";
          foundCar = true;
          break;
        case "ev":
          car = "I drive with eletricity";
          foundCar = true;
          break;
        case "noCar":
          car = "I don't have a car";
          foundCar = true;
          break;
      }
      if (foundCar) {
        break;
      }
    }

    bool foundHeat = false;

    for (String property in user.properties) {
      switch (property) {
        case "heatEletricity":
          heat = "I heat with eletricity";
          foundHeat = true;
          break;
        case "heatGas":
          heat = "I heat with gas";
          foundHeat = true;
          break;
        case "heatOil":
          heat = "I heat with Oil";
          foundHeat = true;
          break;
      }

      if (foundHeat) {
        break;
      }
    }

    bool eatflag = false;
    for (String property in user.properties) {

      switch (property) {
        case 'meat':
          eatpreference = 'I eat meat';
          eatflag = true;
          break;
        case 'vegetarian':
          eatpreference = 'I eat vegetarian';
          eatflag = true;
          break;
        case 'vegan':
          eatpreference = 'I eat vegan';
          eatflag = true;
          break;
      }

      if (eatflag) {
        break;
      }

    }
    return true;
  }

}
