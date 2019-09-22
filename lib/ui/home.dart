import 'dart:convert';
import 'dart:io';

import 'package:device_info/device_info.dart';
import 'package:events_flutter/model/category.dart';
import 'package:events_flutter/model/entity.dart';
import 'package:events_flutter/model/event.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;

//This class is to view the dropDown buttons and the events list view.
class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  //This is the API base URL.
  var apiURL = "http://193.188.88.148/apps/myapps/events/mobile/apis/";

  //This list to store the category objects.
  List<Category> _categories;

  //This field to store the selected category object from the category dropdown menu.
  Category _selectedCategory;
  List<Entity> _entities;
  Entity _selectedEntity;
  bool _entityVisibility;
  List<Event> _events;

  //Message notification related fields (firebase, local notification)
  FirebaseMessaging _firebaseMessaging = new FirebaseMessaging();
  FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  //This is the rtl textDirection field
  TextDirection _rtlTextDirection = TextDirection.rtl;

  //These fields store the device info (identifier, name, version), I'll use
  // them to avoid tokens duplication in the DB, And I've made the default value
  // as "unknown" in case I couldn't get them.
  String _deviceIdentifier = "unknown";

  //These 3 below instances are used to store the info that will distinguish the
  // device in the database.
  String _deviceName = "unknown";
  String _deviceModel = "unknown";

  //This var is used to store the value that determines if the device is a
  // physical one or not (simulator).
  String _deviceIsPhysical = "unknown";

  //I need the initState function to run some of the code just at the first time
  // the app runs.
  @override
  void initState() {
    super.initState();

    //I've called the function that will get the device info.
    getDeviceInfo();

    //I'll initialize some of the fields with values so the app doesn't face an
    // error for the first time it runs.
    _categories = [Category(id: 0, name: "الكل")];
    _selectedCategory = _categories[0];
    //This function will fill the category list with values from the API.
    _fillCategories();
    _entities = [Entity(id: 0, name: "جميع الجهات", categoryId: 0, rank: 0)];
    _entityVisibility = false;
    _events = [
      Event(
          id: 0,
          eventEntityName: "",
          time: "",
          eventAppointment: "",
          subject: "",
          eventDate: "",
          hallName: "",
          eventPlace: "")
    ];
    //I'll call this method to fill the listView with all the events in the
    // remote DB for all the categories and that just for the first time the
    // app runs.
    _fillEventList(categoryId: _selectedCategory.id);

    //firebase related code.
    _firebaseMessaging.configure(
      onLaunch: (Map<String, dynamic> msg) async {
        print(" onLaunch called ${(msg)}");
      },
      onResume: (Map<String, dynamic> msg) async {
        print(" onResume called ${(msg)}");
      },
      onMessage: (Map<String, dynamic> msg) async {
        _showNotification(msg);
        print(" onMessage called ${(msg)}");
      },
    );
    _firebaseMessaging.requestNotificationPermissions(
        const IosNotificationSettings(sound: true, alert: true, badge: true));
    _firebaseMessaging.onIosSettingsRegistered
        .listen((IosNotificationSettings settings) {
      print('IOS Settings Registered: $settings');
    });
    _firebaseMessaging.getToken().then((deviceToken) {
      print(deviceToken);
      print(_deviceIdentifier);

      _saveToken(deviceToken, _deviceIdentifier, _deviceName, _deviceModel,
          _deviceIsPhysical);
    });

    //local notification related code
    //For the app official launch, This notification icon should be changed.
    var android = AndroidInitializationSettings('@mipmap/ic_launcher');
    var ios = IOSInitializationSettings();
    var initializationSettings = InitializationSettings(android, ios);
    _flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  //This function will get the device info.
  void getDeviceInfo() async {
    final DeviceInfoPlugin deviceInfoPlugin = new DeviceInfoPlugin();
    try {
      if (Platform.isAndroid) {
        var build = await deviceInfoPlugin.androidInfo;
        _deviceIdentifier = build.androidId;
        _deviceName = build.device;
        _deviceModel = build.model;
        _deviceIsPhysical = build.isPhysicalDevice.toString();
      } else if (Platform.isIOS) {
        var build = await deviceInfoPlugin.iosInfo;
        _deviceIdentifier = build.identifierForVendor; //UUID for iOS
        _deviceName = build.name;
        _deviceModel = build.model;
        _deviceIsPhysical = build.isPhysicalDevice.toString();
      }
    } on PlatformException {
      print('Failed to get device info');
    }
  }

  //This method will save the device token when the app launched for the first time.
  //And also I'll include the device identifier to distinguish the token, so it
  // will not be duplicated in the DB.
  void _saveToken(String deviceToken, deviceIdentifier, deviceName, deviceModel,
      deviceIsPhysical) async {
    var url = apiURL +
        "save_device_token.php?deviceToken=$deviceToken&deviceIdentifier=$deviceIdentifier&deviceName=$deviceName&deviceModel=$deviceModel&deviceIsPhysical=$deviceIsPhysical";
    await http.get(url);
  }

  //This method will show a notification when a message received.
  //and it will be called just when the app in the foreground and the background
  // state, but when the app terminated a firebase method will be called.
  void _showNotification(Map<String, dynamic> msg) async {
    var androidPlatformChannelSpecifics = new AndroidNotificationDetails(
        'ONE', "EVENTS", "This is the event notifications channel",
        importance: Importance.Max, priority: Priority.High);
    var iOSPlatformChannelSpecifics = new IOSNotificationDetails();
    var platformChannelSpecifics = new NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
    await _flutterLocalNotificationsPlugin.show(
      0,
      msg['data']['title'],
      msg['data']['body'],
      platformChannelSpecifics,
      payload: 'Default_Sound',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          centerTitle: true,
          title: Text("نشاطات مجلس النواب"),
          backgroundColor: Color.fromRGBO(196, 0, 0, 1)),
      body: Container(
        child: Column(
          children: <Widget>[
            Center(
              child: DropdownButton<Category>(
                items: _categories.map((Category category) {
                  return DropdownMenuItem(
                    child: Text(category.name),
                    value: category,
                  );
                }).toList(),
                onChanged: (Category category) {
                  setState(() {
                    //All the below code will run each time the user chooses a
                    // new category.
                    _selectedCategory = category;
                    _showEntityMenu(categoryId: category.id);
                    _fillEventList(categoryId: _selectedCategory.id);
                  });
                },
                value: _selectedCategory,
              ),
            ),
            Visibility(
                visible: _entityVisibility,
                child: Center(
                  child: DropdownButton(
                    items: _entities.map((Entity entity) {
                      return DropdownMenuItem(
                        child: Text(entity.name),
                        value: entity,
                      );
                    }).toList(),
                    onChanged: (Entity entity) {
                      setState(() {
                        _selectedEntity = entity;
                        //Here I'll call the method that will fill the event
                        // list with the events that belong to the chosen entity,
                        // and that based on its id.
                        _fillEventList(
                            categoryId: _selectedCategory.id,
                            entityId: entity.id);
                      });
                    },
                    value: _selectedEntity,
                  ),
                )),
            Flexible(
              child: ListView.builder(
                  padding: EdgeInsets.all(11),
                  itemCount: _events.length,
                  itemBuilder: (context, position) {
                    return _eventWidget(position);
                  }),
            ),
          ],
        ),
      ),
    );
  }

  //I'll fill the category list directly from the API.
  Future _fillCategories() async {
    //This is the URL of the required API, I'll concatenate it with the base URL
    // to be valid.
    var url = apiURL + "get_categories.php";
    http.Response response = await http.get(url);
    //This list will contain the JSON list of categories as maps that fetched
    // from the API.
    List list = json.decode(response.body);
    //I'll loop over each category map in the list to create a category object
    // from it then add it to categories list.
    list.forEach((map) {
      _categories.add(Category.fromMap(map));
    });
    setState(() {});
  }

  //This method will view the entity list depending on the selected category.
  void _showEntityMenu({@required categoryId}) {
    //I'll check if the category id is not 0 "All the categories" and
    // 5: "Permanent office" 6: "Executives office", in that case,
    // I'll show the entity list and fill it otherwise I'll not,
    // because the other categories don't have entities that belong to them.
    if (categoryId != 0 && categoryId != 5 && categoryId != 6) {
      _fillEntities(categoryId: categoryId);
      _entityVisibility = true;
    } else
      _entityVisibility = false;
  }

  //I'll fill the entity list directly from the API depending on the id of the
  // selected category.
  Future _fillEntities({@required categoryId}) async {
    //This is the URL of the required API, I'll concatenate it with the base URL
    // to be valid.
    //I'll provide the category id, to know which categories to get based on the
    // id of the selected category.
    var url = apiURL + "get_committees.php?categoryId=$categoryId";
    http.Response response = await http.get(url);
    //This list will contain the JSON list of entities as maps that fetched
    // from the API.
    List list = json.decode(response.body);
    //I'll initialize the list because I want to view the default first choice
    // on the list, and that value will be based on the selected category id.
    switch (categoryId) {
      case 1: //this case when the "اللجان الدائمة" chosen
      case 3: //this case when the "لجان الاخوة" chosen
        {
          _entities = _entities = [
            //Here I'll set the categoryId and the rank to 0 to make the value
            // appears as the first one in the array
            Entity(id: 0, name: "جميع اللجان", categoryId: 0, rank: 0)
          ];
          break;
        }
      case 2: //this case when the "الكتل" chosen
        {
          _entities = _entities = [
            //Here I'll set the categoryId and the rank to 0 to make the value
            // appears as the first one in the array
            Entity(id: 0, name: "جميع الكتل", categoryId: 0, rank: 0)
          ];
          break;
        }
      case 4: //this case when the "جمعيات الصداقة" chosen
        {
          _entities = _entities = [
            //Here I'll set the categoryId and the rank to 0 to make the value
            // appears as the first one in the array
            Entity(id: 0, name: "جميع الجمعيات", categoryId: 0, rank: 0)
          ];
          break;
        }
    }
    //I'll assign the first element of the list to the _selectedEntity var
    // because I want to show the default value "جميع الجهات" as the first value
    // in the menu.
    _selectedEntity = _entities[0];
    //I'll loop over each entity map in the list to create an entity object
    // from it then add it to entities list.
    list.forEach((map) {
      _entities.add(Entity.fromMap(map));
    });
    setState(() {});
  }

  //This method will fill the events list with events from the API to viewed on
  // the events listView and that based on the id of the selected category and
  // the selected entity.
  _fillEventList({@required categoryId, entityId}) async {
    //This is the URL of the required API, I'll concatenate it with the base URL
    // to be valid.
    //I'll provide the category id, to know which events to get based on the
    // id of the selected category.
    //And also I'll provide the entityId to get the events for that entity if
    // it's chosen.
    var url =
        apiURL + "get_events.php?categoryId=$categoryId&entityId=$entityId";
    http.Response response = await http.get(url);
    //This list will contain the JSON list of events as maps that fetched
    // from the API.
    List list = json.decode(response.body);
    //I'll initialize the list with a default event object, and that for
    // reinitializing the list from the beginning, because I don't want the new
    // values to be added to the old ones, and also in case I don't get anything
    // from the API I'll view in the listView the default empty event object.
    _events = [
      Event(
          id: 0,
          eventEntityName: "",
          time: "",
          eventAppointment: "",
          subject: "",
          eventDate: "",
          hallName: "",
          eventPlace: "")
    ];
    //I'll loop over each event map in the list to create an event object
    // from it then add it to events list.
    list.forEach((map) {
      _events.add(Event.fromMap(map));
    });
    setState(() {});
  }

  //This method will return the widget that views the event details.
  //I've created it because I don't want to view the first element in the event
  // list because it has empty values because it is a default element.
  Widget _eventWidget(position) {
    //This local variable stores the event place where the event will behold,
    // and I'll make the default value of it the value stored in the event place
    // but if that value is empty I'll store in it the values stored in the hall
    // name.
    String eventPlace = _events[position].eventPlace;
    if (_events[position].hallName.isNotEmpty)
      eventPlace = _events[position].hallName;
    //Here I'll check if the position is not 0, because that position represents
    // the first element in the event list.
    //Here I'll check if the position is not 0, because that position represents
    // the first element in the event list.
    // In that case, if the condition is true I'll return a container views the
    // event list element details.
    if (position != 0) {
      return Container(
        child: Card(
          elevation: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              Wrap(
                runAlignment: WrapAlignment.spaceAround,
                textDirection: _rtlTextDirection,
                children: <Widget>[
                  Text(
                    ": جهة النشاط ",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(" "),
                  Text(
                    _events[position].eventEntityName,
                    textDirection: TextDirection.rtl,
                  ),
                ],
              ),
              Wrap(
                textDirection: _rtlTextDirection,
                children: <Widget>[
                  Text(
                    ": الـمـوضـــوع ",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(" "),
                  Text(
                    _events[position].subject,
                    textDirection: TextDirection.rtl,
                  ),
                ],
              ),
              Row(
                textDirection: _rtlTextDirection,
                children: <Widget>[
                  Text(
                    ": الـتـاريـــخ ",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(" "),
                  Text(_events[position].eventDate),
                ],
              ),
              Row(
                textDirection: _rtlTextDirection,
                children: <Widget>[
                  Text(
                    ": الــــوقـــت ",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(" "),
                  Text(_events[position].time),
                ],
              ),
              Row(
                textDirection: _rtlTextDirection,
                children: <Widget>[
                  Text(
                    ": مكان الاجتماع ",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(" "),
                  Text(eventPlace),
                ],
              ),
            ],
          ),
        ),
      );
    }
    //Here I'll return an empty container because I don't want to view the
    // default element in the event list that has an empty values.
    else
      return Container();
  }
}
