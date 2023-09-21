import 'logic.dart';

///abstract class of Activity
abstract class Activity {
  String name;
  int co2;
  bool? checkfordaily;
  bool? tomorrow;
  String? type;

  Activity(
      {required this.name,
      required this.co2,
      this.checkfordaily,
      this.tomorrow});

  factory Activity.createActivity(Map<String, dynamic> json) {
    String name = json['name'];
    bool checkfordaily = json["checkfordaily"] ?? false;
    bool tomorrow = json["tomorrow"] ?? false;
    String type = json["type"] ?? "general";
    switch (type) {
      case "car":
        return CarActivity.fromJson(name, checkfordaily, tomorrow, json);
      case "heat":
        return HeatActivity.fromJson(name, checkfordaily, tomorrow, json);
      case "general":
        return GeneralActivity.fromJson(name, checkfordaily, tomorrow, json);
      default:
        throw Exception("Ungültiger Aktivitätstyp: $type");
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'co2': co2,
      'checkfordaily': checkfordaily,
      'tomorrow': tomorrow,
      'type': type,
      ...getSpecificPropertiesToJson(),
    };
  }

  Map<String, dynamic> getSpecificPropertiesToJson();

  @override
  String toString() {
    return "$name";
  }
}

///CarActivity
class CarActivity extends Activity {
  int _distance;
  double _consumption;
  List<String> _properties;

  CarActivity({
    required String name,
    required int distance,
    required double consumption,
    required List<String> properties,
    required bool checkfordaily,
    required bool tomorrow,
  })  : _distance = distance,
        _consumption = consumption,
        _properties = properties,
        super(
        name: name,
        co2: 0,
        checkfordaily: checkfordaily,
        tomorrow: tomorrow,
      );

  int get co2 => calculateCO2ByDistance();

  int calculateCO2ByDistance() {
    double liters = _distance * _consumption / 100;

    if (_properties.contains("petrol")) {
      return (liters * 2370).ceil();
    } else if (_properties.contains("diesel")) {
      return (liters * 2650).ceil();
    } else if (_properties.contains("LPG")) {
      return (liters * 2140).ceil();
    } else if (_properties.contains("hybrid")) {
      return (liters * 2140).ceil();
    } else if (_properties.contains("ev")) {
      return (liters * 420).ceil();
    } else {
      return 0;
    }
  }

  @override
  Map<String, dynamic> getSpecificPropertiesToJson() {
    return {
      'distance': _distance,
      'consumption': _consumption,
      'properties': _properties,
    };
  }

  factory CarActivity.fromJson(String name, bool checkfordaily, bool tomorrow,
      Map<String, dynamic> json) {
    int distance = json['distance'] ?? AppLogic.user.distance;
    double consumption = json['consumption'] ?? AppLogic.user.carconumption;
    List<String> properties = List<String>.from(json['properties'] ?? []);

    CarActivity carActivity = CarActivity(
      name: name,
      checkfordaily: checkfordaily,
      tomorrow: tomorrow,
      distance: distance,
      consumption: consumption,
      properties: properties,
    );

    carActivity._properties = AppLogic.user.properties;
    int co2 = carActivity.calculateCO2ByDistance();
    carActivity.co2 = co2;

    return carActivity;
  }
}

///HeatActivity
class HeatActivity extends Activity {
  String _type;

  HeatActivity(
      {required String name,
      required String type,
      required int co2,
      required bool checkfordaily,
      required bool tomorrow})
      : _type = type,
        super(
            name: name,
            co2: co2,
            checkfordaily: checkfordaily,
            tomorrow: tomorrow);

  factory HeatActivity.fromJson(String name, bool checkfordaily, bool tomorrow,
      Map<String, dynamic> json) {
    return HeatActivity(
      name: name,
      checkfordaily: checkfordaily,
      tomorrow: tomorrow,
      type: json['type'],
      co2: json['co2'],
    );
  }

  @override
  Map<String, dynamic> getSpecificPropertiesToJson() {
    return {
      'type': _type,
    };
  }
}

///GeneralActivity
class GeneralActivity extends Activity {
  GeneralActivity(
      {required String name,
      required int co2,
      required bool checkfordaily,
      required bool tomorrow})
      : super(
            name: name,
            co2: co2,
            checkfordaily: checkfordaily,
            tomorrow: tomorrow);

  factory GeneralActivity.fromJson(String name, bool checkfordaily,
      bool tomorrow, Map<String, dynamic> json) {
    return GeneralActivity(
      name: name,
      checkfordaily: checkfordaily,
      tomorrow: tomorrow,
      co2: json['co2'],
    );
  }

  @override
  Map<String, dynamic> getSpecificPropertiesToJson() {
    return {};
  }
}

///User preferences
class User {

  int distance = 10;

  List<String> _properties = [];
  double _carconumption = 0;
  double _co2car = 0;
  int _countlaundry = 0;
  int _countdishes = 0;

  User();

  void setUserProperties(List propertiesandcounts) {
    _properties = propertiesandcounts[0];
    _carconumption = propertiesandcounts[1];
    _co2car = propertiesandcounts[2];
    _countlaundry = propertiesandcounts[3];
    _countdishes = propertiesandcounts[4];
  }

  List<String> get properties => _properties;

  double get carconumption => _carconumption;

  double get co2car => _co2car;

  int get countlaundry => _countlaundry;

  int get countdishes => _countdishes;

  Map<String, dynamic> toJson() {
    return {
      'properties': _properties,
      'carconumption': _carconumption,
      'co2car': _co2car,
      'countlaundry': _countlaundry,
      'countdishes': _countdishes,
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    User user = User();
    user._properties = List<String>.from(json['properties']);
    user._carconumption = json['carconumption'];
    user._co2car = json['co2car'];
    user._countlaundry = json['countlaundry'];
    user._countdishes = json['countdishes'];
    return user;
  }
}
