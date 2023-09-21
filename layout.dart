import 'dart:async';
import 'dart:math';
import 'package:flutter/services.dart';
import 'package:saveco2/logic.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'data.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter_svg/flutter_svg.dart';


///Pop-Up Menu / Sidebar
class PopUpMenu extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
        width: MediaQuery.of(context).size.width * 0.6,
        child: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              Container(
                height: 40,
                color: Colors.green,
              ),
              ListTile(
                title: Text('Home'),
                onTap: () {
                  AppLogic.doWhenPopUpMenuOnTap();
                  if (ModalRoute.of(context)!.settings.name == "/") {
                    Navigator.pop(context);
                  } else {
                    Navigator.pop(context);
                    Navigator.of(context).pushNamed("/");
                  }
                },
                trailing: Icon(Icons.arrow_forward_ios),
                contentPadding: EdgeInsets.symmetric(horizontal: 16),
                visualDensity: VisualDensity(horizontal: 0, vertical: -4),
                tileColor: Colors.transparent,
                shape: Border(bottom: BorderSide(color: Colors.green)),
              ),
              ListTile(
                title: Text('New Entry'),
                onTap: () {
                  AppLogic.doWhenPopUpMenuOnTap();
                  if (ModalRoute.of(context)!.settings.name == "/newentry") {
                    Navigator.pop(context);
                  } else {
                    Navigator.pop(context);
                    Navigator.of(context).pushNamed("/newentry");
                  }
                },
                trailing: Icon(Icons.arrow_forward_ios),
                contentPadding: EdgeInsets.symmetric(horizontal: 16),
                visualDensity: VisualDensity(horizontal: 0, vertical: -4),
                tileColor: Colors.transparent,
                shape: Border(bottom: BorderSide(color: Colors.green)),
              ),
              ListTile(
                title: Text('Information'),
                onTap: () {
                  AppLogic.doWhenPopUpMenuOnTap();
                  if (ModalRoute.of(context)!.settings.name == "/information") {
                    Navigator.pop(context);
                  } else {
                    Navigator.pop(context);
                    Navigator.of(context).pushNamed("/information");
                  }
                },
                trailing: Icon(Icons.arrow_forward_ios),
                contentPadding: EdgeInsets.symmetric(horizontal: 16),
                visualDensity: VisualDensity(horizontal: 0, vertical: -4),
                tileColor: Colors.transparent,
                shape: Border(bottom: BorderSide(color: Colors.green)),
              ),
              ListTile(
                title: Text('Settings'),
                onTap: () {
                  AppLogic.doWhenPopUpMenuOnTap();
                  if (ModalRoute.of(context)!.settings.name == "/settings") {
                    Navigator.pop(context);
                  } else {
                    Navigator.pop(context);
                    Navigator.of(context).pushNamed("/settings");
                  }
                },
                trailing: Icon(Icons.arrow_forward_ios),
                contentPadding: EdgeInsets.symmetric(horizontal: 16),
                visualDensity: VisualDensity(horizontal: 0, vertical: -4),
                tileColor: Colors.transparent,
                shape: Border(bottom: BorderSide(color: Colors.green)),
              ),
              /*ListTile(
                title: Text('Bug Report'),
                onTap: () {},
                trailing: Icon(Icons.arrow_forward_ios),
                contentPadding: EdgeInsets.symmetric(horizontal: 16),
                visualDensity: VisualDensity(horizontal: 0, vertical: -4),
                tileColor: Colors.transparent,
                shape: Border(bottom: BorderSide(color: Colors.green)),
              ),*/
              /*ListTile(
                title: Text('Impressum – Legal Notice'),
                onTap: () {},
                trailing: Icon(Icons.arrow_forward_ios),
                contentPadding: EdgeInsets.symmetric(horizontal: 16),
                visualDensity: VisualDensity(horizontal: 0, vertical: -4),
                tileColor: Colors.transparent,
              ),*/
            ],
          ),
        ));
  }
}

///helper class of header of each AppBar
class EveryAppBar extends StatelessWidget implements PreferredSizeWidget {
  final GlobalKey<ScaffoldState> _scaffoldKey;
  final String _title;
  final Icon _icon;

  EveryAppBar(this._title, this._scaffoldKey, this._icon);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(_title),
        SvgPicture.asset(
          'assets/SaveCO2.svg',
          height: 40.0,
          width: 40.0,
          allowDrawingOutsideViewBox: true,
        )
      ]),
      leading: IconButton(
        onPressed: () {
          _scaffoldKey.currentState!.openDrawer();
        },
        icon: _icon,
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}

//----------------------Homescreen----------------------------------------------

///Layout for Homescreen
class HomescreenLayout extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => HomescreenLayoutState();
}

///State of Homescreen
class HomescreenLayoutState extends State<HomescreenLayout>
    with WidgetsBindingObserver {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    super.initState();
    print("initState");
  }

  @override
  void dispose() {
    print("dispose");
    AppLogic.savedatalogic.saveData();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeDependencies() async {
    print("didChangeDependencies");
    await AppLogic.homescreenlogic.updateHomescreenList(context, () async {
      await AppLogic.savedatalogic.loadData();
    });
    if (AppLogic.isfirsttime) {
      print("isfirsttme");
      AppLogic.homescreenlogic.isFirstTime(context);
    }
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: EveryAppBar("Home", _scaffoldKey, Icon(Icons.list)),
      drawer: PopUpMenu(),
      body: BlocBuilder<HomescreenLogic, List>(
          builder: (context, activitylists) => ListView(
                children: [
                  Container(
                      // Container with Circle and Progress
                      margin: const EdgeInsets.all(20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          PercentageCircle(
                            percentage: min(
                                max(
                                    (AppLogic.homescreenlogic.getSavedCO2() /
                                            AppLogic.goal) *
                                        100,
                                    0.0001),
                                100),
                            size: 100,
                            color: Colors.green,
                          ),
                          Container(
                            padding: const EdgeInsets.all(16.0),
                            decoration: BoxDecoration(
                              color: Colors.green,
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  "${min(AppLogic.homescreenlogic.getSavedCO2(), AppLogic.goal)}g / ${AppLogic.goal}g",
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18.0,
                                  ),
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                const Text(
                                  "saved CO₂",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14.0,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      )),
                  Container(
                    // Container Daily Tasks banner
                    margin: const EdgeInsets.all(5),
                    padding: const EdgeInsets.all(15),
                    color: Colors.orange[700],
                    child: const Center(
                        child: Text("Daily Tasks",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontFamily: 'Roboto'))),
                  ),
                  ...activitylists[0].map((activity) {
                    if (activity.checkfordaily) {
                      return ContainerDailyActivityList(activity);
                    } else {
                      return const Icon(Icons.check);
                    }
                  }),
                  if (AppLogic.homescreenlogic.showfetchbutton) //FetchButton
                    const Align(child: FetchButton()),
                  Container(
                    //Banner Completed Tasks
                    margin: const EdgeInsets.all(5),
                    padding: const EdgeInsets.all(15),
                    color: Colors.green[700],
                    child: const Center(
                        child: Text("Completed Tasks",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontFamily: 'Roboto'))),
                  ),
                  ...activitylists[1].map((activity) {
                    // Completed Tasks List
                    return ContainerDoneActivityList(activity);
                  }),
                ],
              )),
    );
  }
}

///Class for DailyActivityList
class ContainerDailyActivityList extends StatelessWidget {
  final Activity activity;

  const ContainerDailyActivityList(this.activity, {super.key});

  @override
  Widget build(BuildContext context) {
    // Daily Tasks List
    return Container(
        margin: const EdgeInsets.all(5),
        padding: const EdgeInsets.all(15),
        color: Colors.orange[200],
        child: Column(children: [
          Text(activity.name, textAlign: TextAlign.center),
          const SizedBox(
            height: 15,
          ),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            IntrinsicWidth(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange),
                    onPressed: () {
                      AppLogic.homescreenlogic
                          .taskCompletedOnPressed(activity, context);
                    },
                    icon: const Icon(Icons.check),
                    label: const Text('Task Completed'),
                  ),
                  SizedBox(height: 5),
                  if (!activity.tomorrow!)
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange),
                      onPressed: () {
                        AppLogic.homescreenlogic
                            .postponeTask(activity, context);
                      },
                      label: const Text('Do it tomorrow'),
                      icon: const Icon(Icons.arrow_forward_sharp),
                    ),
                  if (activity.tomorrow!)
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange),
                      onPressed: () {
                        AppLogic.homescreenlogic
                            .postponeTask(activity, context);
                      },
                      label: const Text('Marked for tomorrow'),
                      icon: const Icon(Icons.markunread_mailbox),
                    )
                ])),
            SizedBox(
              width: 20,
            ),
            Container(
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  color: Colors.lightBlue,
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Text(
                  "${activity.co2}g CO₂",
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ))
          ]),
        ]));
  }
}

///Class for DoneActivityList
class ContainerDoneActivityList extends StatelessWidget {
  final Activity activity;

  const ContainerDoneActivityList(this.activity, {super.key});

  @override
  Widget build(BuildContext context) {
    // Daily Tasks List
    return Container(
        margin: const EdgeInsets.all(5),
        padding: const EdgeInsets.all(15),
        color: Colors.green[200],
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text(activity.name, textAlign: TextAlign.center),
          const SizedBox(
            height: 15,
          ),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            IconButton(
              onPressed: () {
                AppLogic.homescreenlogic.deleteActivity(activity, context);
              },
              icon: const Icon(Icons.delete),
            ),
            SizedBox(
              width: 20,
            ),
            Container(
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Text(
                  "${activity.co2}g CO₂",
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ))
          ])
        ]));
  }
}

///Button to get daily tasks
class FetchButton extends StatelessWidget {
  const FetchButton({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<http.Response>(
        future: AppLogic.httplogic.fetchData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  padding: const EdgeInsets.symmetric(horizontal: 20)),
              onPressed: null,
              icon: const CircularProgressIndicator(),
              label: const Text(
                'Loading...',
                style: TextStyle(fontSize: 16),
              ),
            );
          } else if (snapshot.hasError) {
            return const Text('Error');
          } else {
            return ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  padding: const EdgeInsets.symmetric(horizontal: 20)),
              onPressed: () {
                AppLogic.homescreenlogic
                    .fetchButtonOnPressed(context, snapshot);
              },
              icon: const Icon(Icons.arrow_circle_down_outlined),
              label: const Text(
                'Get Daily Tasks',
                style: TextStyle(fontSize: 16),
              ),
            );
          }
        });
  }
}

///Circle for target
class PercentageCircle extends StatelessWidget {
  final double percentage;
  final double size;
  final Color color;

  const PercentageCircle({
    Key? key,
    required this.percentage,
    this.size = 50.0,
    this.color = Colors.blue,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        children: [
          Center(
            child: Container(
              width: size * 0.8,
              height: size * 0.8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: color, width: 2.0),
              ),
            ),
          ),
          CustomPaint(
            painter: CirclePainter(
              color: color,
              percentage: percentage,
            ),
            child: Center(
              child: Text(
                '${percentage.toInt()}%',
                style: TextStyle(fontSize: size * 0.2),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

///Confetti for completing a task
class Confetti extends StatefulWidget {
  final double direction;

  Confetti(this.direction);

  @override
  State<StatefulWidget> createState() => ConfettiState(direction);
}

///ConfettiState for completing a task
class ConfettiState extends State<Confetti> {
  late ConfettiController _controller;
  double direction;

  ConfettiState(this.direction);

  @override
  void initState() {
    super.initState();
    _controller = ConfettiController(duration: const Duration(seconds: 3));
    _controller.play();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ConfettiWidget(
      confettiController: _controller,
      blastDirectionality: BlastDirectionality.directional,
      blastDirection: direction,
      particleDrag: 0.05,
      emissionFrequency: 0.05,
      numberOfParticles: 10,
      maxBlastForce: 100,
      minBlastForce: 80,
      gravity: 0.1,
      shouldLoop: false,
      colors: const [
        Colors.green,
        Colors.blue,
        Colors.pink,
        Colors.orange,
        Colors.purple,
      ],
    );
  }
}

///ConfettiDialog for completing a task
class ConfettiDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
        content: Column(mainAxisSize: MainAxisSize.min, children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
        Confetti(-0.55 * pi),
        Confetti(-0.525 * pi),
        Confetti(-0.475 * pi),
        Confetti(-0.45 * pi)
      ]),
      SizedBox(height: 20),
      Text("Congratulations!"),
      SizedBox(height: 20),
      ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text("yey!")),
    ]));
  }
}

//----------------------New Entry-----------------------------------------------

///Layout for Screen where you are choosing activites
class EntryLayout extends StatelessWidget {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        appBar: EveryAppBar("New Entry", _scaffoldKey, Icon(Icons.list)),
        drawer: PopUpMenu(),
        body: Container(
            padding: EdgeInsets.only(top: 15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                SizedBox(height: 20),
                Text("You can add extra activities here:",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.green,
                    )),
                SizedBox(height: 20),
                Container(
                    child: EntryDropdown(),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                        border: Border.all(
                      color: Colors.green,
                      width: 2,
                    )),
                    padding: EdgeInsets.only(left: 10, right: 10),
                    margin: EdgeInsets.only(
                        left: MediaQuery.of(context).size.width * 0.02,
                        right: MediaQuery.of(context).size.width * 0.02)),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {
                    AppLogic.entrylogic.addEntryToData(context);
                  },
                  child: const Text("add entry"),
                ),
              ],
            )));
  }
}

///The Dropdownmenu of the EntryLayout
class EntryDropdown extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => EntryDropdownState();
}

///The DropdownmenuState of the EntryLayout
class EntryDropdownState extends State<EntryDropdown> {
  Activity? dropdownvalue = AppLogic.entrylogic.placeholder;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<http.Response>(
        future: AppLogic.httplogic.fetchData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  padding: const EdgeInsets.symmetric(horizontal: 20)),
              onPressed: null,
              icon: const CircularProgressIndicator(),
              label: const Text(
                'Loading...',
                style: TextStyle(fontSize: 16),
              ),
            );
          } else if (snapshot.hasError) {
            return const Text('Error');
          } else {
            var activities = AppLogic.getActivityListFromRows(snapshot);
            activities.insert(0, dropdownvalue!);
            return DropdownButton<Activity>(
              itemHeight: null,
              value: dropdownvalue,
              onChanged: (Activity? newValue) {
                setState(() {
                  dropdownvalue = newValue!;
                  AppLogic.entrylogic.choosedactivity = dropdownvalue!;
                });
              },
              isExpanded: true,
              items: activities
                  .map<DropdownMenuItem<Activity>>((Activity activity) {
                return DropdownMenuItem<Activity>(
                  value: activity,
                  child: activity == AppLogic.entrylogic.placeholder
                      ? Text("Choose activity...")
                      : Text(activity.toString()),
                );
              }).toList(),
            );
          }
        });
  }
}

//----------------------Information---------------------------------------------

///Layout for Users Guide
class InformationLayout extends StatelessWidget {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        appBar: EveryAppBar("Information", _scaffoldKey, Icon(Icons.list)),
        drawer: PopUpMenu(),
        body: Container(
            child: ListView(children: [
          SizedBox(height: 20),
          Text("Thanks for joining!",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                color: Colors.green,
              )),
          SizedBox(height: 10),
          Text(
              "Good to have you here. Here you can get information about the app. ",
              textAlign: TextAlign.center),
          SizedBox(height: 10),
          FAQWidget(
              question: "What does the app do?",
              answer:
                  "The app is here to help you perform daily activities to reduce your carbon footprint. You can enter a goal, for example, the number of grams of CO2 emitted by your last flight. or you can simply set a personal goal. If you have already customized your properties under Settings, you can click on Get Daily Activities to display 3 new tasks that have been customized for you. The given CO2 values are of course not 100% exact. They should only give you a rough direction and motivate you to save CO2. "),
              FAQWidget(
              question: "What should i do first?",
              answer:
                  "If you haven\'t done it yet: First of all, you should set and save your preferences and properties via Settings. Additionally, you should set a CO2 target. This can be something smaller like a longer car trip or you save a long time for the compensation of a flight. Don\'t let it get you down. It can take a long time in some cases. You can also try out the app by setting a goal of 10000 to get familiar with it.")
              ,FAQWidget(
                  question: "How do I get tasks?",
                  answer:
                  "You will get 3 Daily Tasks every day by clicking on the Get Daily Tasks button. By clicking on the Task completed button you can enter them as completed. If you don't complete a task, it will be deleted and you will get 3 new ones the next day. However, you can always postpone it by one day. This is especially useful for activities that may not be performed every day, such as shopping. In addition, you can use New Entry to select other activities that you have done from a list and add them to the completed tasks list.")
            ,])));
  }
}

///FAQ
class FAQWidget extends StatefulWidget {
  final String question;
  final String answer;

  FAQWidget({required this.question, required this.answer});

  @override
  _FAQWidgetState createState() => _FAQWidgetState();
}

///FAQState
class _FAQWidgetState extends State<FAQWidget> {
  bool expanded = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          expanded = !expanded;
        });
      },
      child: Card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              title: Text(
                widget.question,
                style:
                    TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
              ),
              trailing: Icon(
                expanded ? Icons.expand_less : Icons.expand_more,
              ),
            ),
            if (expanded)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(widget.answer, textAlign: TextAlign.justify,),
              ),
          ],
        ),
      ),
    );
  }
}

//------------------------Settings----------------------------------------------

///Layout for AppSettings
class SettingsLayout extends StatelessWidget {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        appBar: EveryAppBar("Information", _scaffoldKey, Icon(Icons.list)),
        drawer: PopUpMenu(),
        body: ListView(
          children: [
            SizedBox(
              height: 20,
            ),
            Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              ElevatedButton(
                onPressed: () async {
                  await AppLogic.userlogic
                      .calculateLogicProperties(AppLogic.user);
                  Navigator.pushNamed(context, "/settings/user");
                },
                child: Text("Set your properties and preferences"),
              )
            ]),
            SizedBox(
              height: 50,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text("You can adjust your goal:"),
                SizedBox(
                  height: 20,
                ),
                Container(
                    padding: EdgeInsets.only(
                        left: MediaQuery.of(context).size.width * 0.25,
                        right: MediaQuery.of(context).size.width * 0.25),
                    child: TextFormField(
                      controller:
                          AppLogic.settingslogic.adjustgoaltextcontroller,
                      decoration: InputDecoration(
                        labelText: 'Enter your new goal',
                        border: OutlineInputBorder(),
                      ),
                    )),
                SizedBox(
                  height: 10,
                ),
                ElevatedButton(
                  onPressed: () {
                    AppLogic.settingslogic.adjustGoal(context);
                  },
                  child: Text("adjust goal"),
                )
              ],
            ),
            SizedBox(
              height: 50,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text("You lost some of your progress? Enter it here:"),
                SizedBox(
                  height: 20,
                ),
                Container(
                    padding: EdgeInsets.only(
                        left: MediaQuery.of(context).size.width * 0.25,
                        right: MediaQuery.of(context).size.width * 0.25),
                    child: TextFormField(
                      controller:
                          AppLogic.settingslogic.adjustsavedco2textcontroller,
                      decoration: InputDecoration(
                        labelText: 'Enter saved CO₂',
                        border: OutlineInputBorder(),
                      ),
                    )),
                SizedBox(
                  height: 10,
                ),
                ElevatedButton(
                  onPressed: () {
                    AppLogic.settingslogic.addsavedco2(context);
                  },
                  child: Text("add saved CO₂"),
                )
              ],
            ),
            SizedBox(
              height: 50,
            ),
            Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              ElevatedButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AppLogic.settingslogic.resetProgress(context);
                      },
                    );
                  },
                  child: Text("Click this button to reset your progress"))
            ]),
          ],
        ));
  }
}

//--------------------------User-------------------------------------

///Layout for User Preferences
class UserLayout extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title:
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text("Edit User"),
            SvgPicture.asset(
              'assets/SaveCO2.svg',
              height: 40.0,
              width: 40.0,
              allowDrawingOutsideViewBox: true,
            )
          ]),
          leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
              AppLogic.userlogic.calculateLogicProperties(AppLogic.user);
            },
            icon: Icon(Icons.close),
          ),
        ),
        body: ListView(children: [
          SizedBox(height: 20),
          Text("User preferences",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                color: Colors.green,
              )),
          SizedBox(height: 20),
          DropdownEat(),
          SizedBox(height: 20),
          DropdownHeat(),
          SizedBox(height: 20),
          DropdownCar(),
          SizedBox(height: 20),
          PVCheckBox(),
          SizedBox(height: 20),
          CountContainer("dishes"),
          SizedBox(height: 20),
          CountContainer("laundry"),
          SizedBox(height: 20),
          Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            ElevatedButton(
                onPressed: () async {
                  ;
                  await AppLogic.homescreenlogic.updateHomescreenList(context,
                      () {
                    AppLogic.user.setUserProperties(
                        AppLogic.userlogic.calculateUserProperties());
                  });
                  Navigator.pop(context);
                },
                child: Text("Apply changes"))
          ])
        ]));
  }
}

class PVCheckBox extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => PVCheckBoxContainer();
}

class PVCheckBoxContainer extends State<PVCheckBox> {
  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.green,
            width: 2,
          ),
        ),
        padding: EdgeInsets.only(left: 10, right: 10),
        margin: EdgeInsets.only(
          left: MediaQuery.of(context).size.width * 0.02,
          right: MediaQuery.of(context).size.width * 0.02,
        ),
        child: Column(
          children: [
            Row(children: [
              Checkbox(
                  value: AppLogic.userlogic.hasPV,
                  onChanged: (bool? value) => setState(() {
                        AppLogic.userlogic.hasPV = value!;
                      })),
              Text("I have PV")
            ]),
            SizedBox(height: 5),
            Row(children: [
              Checkbox(
                  value: AppLogic.userlogic.loadEVwithPV,
                  onChanged: (bool? value) => setState(() {
                        AppLogic.userlogic.loadEVwithPV = value!;
                      })),
              Text("I mostly charge my EV/Hybrid with PV")
            ]),
            SizedBox(height: 5),
            Row(children: [
              Checkbox(
                  value: AppLogic.userlogic.heatwithPV,
                  onChanged: (bool? value) => setState(() {
                        AppLogic.userlogic.heatwithPV = value!;
                      })),
              Text("I mostly heat with my PV")
            ]),
            SizedBox(height: 5),
            Row(children: [
              Checkbox(
                  value: AppLogic.userlogic.dontusecar,
                  onChanged: (bool? value) => setState(() {
                        AppLogic.userlogic.dontusecar = value!;
                      })),
              Text("Under 10% of my trips are with the car")
            ]),
            SizedBox(height: 5),
            Row(children: [
              Checkbox(
                  value: AppLogic.userlogic.hasLift,
                  onChanged: (bool? value) => setState(() {
                        AppLogic.userlogic.hasLift = value!;
                      })),
              Text("I have a lift at home or my workplace")
            ])
          ],
        ));
  }
}

class DropdownEat extends StatefulWidget {
  @override
  _DropdownMenuEat createState() => _DropdownMenuEat();
}

class _DropdownMenuEat extends State<DropdownEat> {
  String _selectedOption = AppLogic.userlogic.eatpreference;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      child: SizedBox(
        width: 300, // Gewünschte Breite des Containers
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.green,
              width: 2,
            ),
          ),
          padding: EdgeInsets.only(left: 10, right: 10),
          margin: EdgeInsets.only(
            left: MediaQuery.of(context).size.width * 0.02,
            right: MediaQuery.of(context).size.width * 0.02,
          ),
          child: DropdownButton<String>(
            isExpanded: true,
            value: _selectedOption,
            onChanged: (String? newValue) {
              setState(() {
                _selectedOption = newValue!;
                AppLogic.userlogic.eatpreference = newValue;
              });
            },
            items: <String>['I eat meat', 'I eat vegetarian', 'I eat vegan']
                .map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

class DropdownCar extends StatefulWidget {
  @override
  _DropdownMenuCarContainer createState() => _DropdownMenuCarContainer();
}

class _DropdownMenuCarContainer extends State<DropdownCar> {
  String _selectedOption = AppLogic.userlogic.car;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      child: SizedBox(
        width: 300, // Gewünschte Breite des Containers
        child: Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.green,
                width: 2,
              ),
            ),
            padding: EdgeInsets.only(left: 10, right: 10),
            margin: EdgeInsets.only(
              left: MediaQuery.of(context).size.width * 0.02,
              right: MediaQuery.of(context).size.width * 0.02,
            ),
            child: Column(children: [
              DropdownButton<String>(
                isExpanded: true,
                value: _selectedOption,
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedOption = newValue!;
                    AppLogic.userlogic.car = newValue;
                  });
                },
                items: <String>[
                  'I drive with petrol',
                  'I drive with diesel',
                  'I drive with eletricity',
                  'I drive with hybrid',
                  'I drive with LPG',
                  'I don\'t have a car'
                ].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
              SizedBox(height: 5),
              TextFormField(
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                ],
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                controller: AppLogic.userlogic.consumptionController,
                decoration: InputDecoration(
                  labelText: 'Enter consumption in l/kWh/m³ per 100km',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 5),
              TextFormField(
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                ],
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                controller: AppLogic.userlogic.co2kmController,
                decoration: InputDecoration(
                  labelText: 'or if you know enter CO₂/km',
                  border: OutlineInputBorder(),
                ),
              ),
            ])),
      ),
    );
  }
}

class DropdownHeat extends StatefulWidget {
  @override
  _DropdownMenuHeat createState() => _DropdownMenuHeat();
}

class _DropdownMenuHeat extends State<DropdownHeat> {
  String _selectedOption = AppLogic.userlogic.heat;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      child: SizedBox(
        width: 300, // Gewünschte Breite des Containers
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.green,
              width: 2,
            ),
          ),
          padding: EdgeInsets.only(left: 10, right: 10),
          margin: EdgeInsets.only(
            left: MediaQuery.of(context).size.width * 0.02,
            right: MediaQuery.of(context).size.width * 0.02,
          ),
          child: DropdownButton<String>(
            isExpanded: true,
            value: _selectedOption,
            onChanged: (String? newValue) {
              setState(() {
                _selectedOption = newValue!;
                AppLogic.userlogic.heat = newValue;
              });
            },
            items: <String>[
              'I heat with gas',
              'I heat with oil',
              'I heat with eletricity',
            ].map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

class DropdownCount extends StatefulWidget {
  final String text;

  DropdownCount(this.text);

  @override
  _DropdownCount createState() => _DropdownCount(text);
}

class _DropdownCount extends State<DropdownCount> {
  String _selectedOption;
  String text;

  _DropdownCount(this.text)
      : _selectedOption = (text == "dishes")
            ? AppLogic.userlogic.countdishes
            : AppLogic.userlogic.countlaundry;

  @override
  Widget build(BuildContext context) {
    return DropdownButton<String>(
      value: _selectedOption,
      onChanged: (String? newValue) {
        setState(() {
          _selectedOption = newValue!;
          if (text == "dishes") {
            AppLogic.userlogic.countdishes = newValue;
          } else if (text == "laundry") {
            AppLogic.userlogic.countlaundry = newValue;
          }
        });
      },
      items: <String>[
        "< 1",
        "1",
        "2",
        "3",
        "4",
        "5",
        "6",
        "7",
        "> 7",
      ].map((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
    );
  }
}

class CountContainer extends StatelessWidget {
  final String text;

  CountContainer(this.text);

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.green,
            width: 2,
          ),
        ),
        padding: EdgeInsets.only(left: 10, right: 10),
        margin: EdgeInsets.only(
          left: MediaQuery.of(context).size.width * 0.02,
          right: MediaQuery.of(context).size.width * 0.02,
        ),
        child: Column(
          children: [
            SizedBox(height: 5),
            Text("I make the $text the follwing times a week:"),
            SizedBox(height: 5),
            DropdownCount(text)
          ],
        ));
  }
}


//--------------------------FirstTimeUser-------------------------

///Popsup when you open the App the first time
class FirstTimeUserLayout extends StatelessWidget {
  Completer<void> completer = Completer<void>();

  FirstTimeUserLayout(this.completer);

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async {
          return Future.value(false);
        },
        child: Scaffold(
        appBar: AppBar(
          title:
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text("Edit User"),
            SvgPicture.asset(
              'assets/SaveCO2.svg',
              height: 40.0,
              width: 40.0,
              allowDrawingOutsideViewBox: true,
            )
          ]),
        ),
        body: ListView(children: [
          SizedBox(height: 20),
          Text("User preferences",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                color: Colors.green,
              )),
          SizedBox(height: 20),
          DropdownEat(),
          SizedBox(height: 20),
          DropdownHeat(),
          SizedBox(height: 20),
          DropdownCar(),
          SizedBox(height: 20),
          PVCheckBox(),
          SizedBox(height: 20),
          CountContainer("dishes"),
          SizedBox(height: 20),
          CountContainer("laundry"),
          SizedBox(height: 20),
          Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            ElevatedButton(
                onPressed: () async {

                  await AppLogic.homescreenlogic.updateHomescreenList(context,
                          () {
                        AppLogic.user.setUserProperties(
                            AppLogic.userlogic.calculateUserProperties());
                      });
                  Navigator.pop(context);
                  completer.complete();
                },
                child: Text("Apply changes"))
          ])
        ])));
  }
}