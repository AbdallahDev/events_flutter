import 'dart:convert';
import 'dart:io';

import 'package:device_info/device_info.dart';
import 'package:events_flutter/model/category.dart';
import 'package:events_flutter/model/entity.dart';
import 'package:events_flutter/model/event.dart';
import 'package:events_flutter/static/staticVars.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:date_range_picker/date_range_picker.dart' as DateRangePicker;

//This import is for the library that deals with dates and their format and
// I've declared it as intl because I don't want it to conflict with other
// libraries.
import 'package:intl/intl.dart' as intl;

//This class is to view the dropDown buttons and the events list view.
class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  //This is the API base URL.
  var apiURL = StaticVars.apiUrl;

  //This list to store the category objects.
  List<Category> _categories;

  //This field to store the selected category object from the category dropdown
  // menu.
  Category _selectedCategory;
  List<Entity> _entities;
  Entity _selectedEntity;
  bool _entityVisibility;
  List<Event> _events;

  //This variable will store the status that based on it will be decided to
  // view all the events of all the dates or for a specific date like the
  // current date.
  bool _showAllEvents;

  //This variable will store the selected date from the date picker, and I've
  // made its default value the current date, because the default state will be
  // to show the events for the current date.
  //And this instance will be used by date picker to decide which date to select
  // when it's opened.
  var _selectedDate;

  //This variable will store the date formatting.
  static var _dateFormatter = intl.DateFormat('yyyy-MM-dd');

  //This variable will store the date that I want to show the events for.
  // And I'll make the default value the format of the current date.
  String _eventsDate;

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
    //I've initialized the _selectedEntity instance with the entry from the
    // _entities list because I want to the _selectedEntity.id to have a value
    // the first time the apps run, because if I don't do that its value will
    // be null, and in that case, if the user presses the checkbox the app will
    // not show all the events and an error will occur.
    _selectedEntity = _entities[0];
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
    //Here I've initialized the instance with the value "false" because the
    // default state will be to show the events of the current date, not all the
    // dates.
    _showAllEvents = false;

    //I've made the default value the current date for the variable
    // _selectedDate that will store the chosen date from the date picker.
    _selectedDate = DateTime.now();

    //I've made the default value the formatting of the current date.
    _eventsDate = _dateFormatter.format(DateTime.now());

    //I'll call this method to fill the listView with all the events in the
    // remote DB for all the categories and that just for the first time the
    // app runs.
    _fillEventList(
        categoryId: _selectedCategory.id, showAllEvents: _showAllEvents);

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
            Row(
              textDirection: _rtlTextDirection,
              children: <Widget>[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    DropdownButton<Category>(
                      items: _categories.map((Category category) {
                        return DropdownMenuItem(
                          child: Container(
                            child: Text(category.name),
                            alignment: Alignment.center,
                          ),
                          value: category,
                        );
                      }).toList(),
                      onChanged: (Category category) {
                        setState(() {
                          //All the below code will run each time the user chooses a
                          // new category.
                          _selectedCategory = category;
                          _showEntityMenu(categoryId: category.id);
                          _fillEventList(
                              categoryId: _selectedCategory.id,
                              showAllEvents: _showAllEvents);
                        });
                      },
                      value: _selectedCategory,
                    ),
                    Visibility(
                      visible: _entityVisibility,
                      child: DropdownButton(
                        items: _entities.map((Entity entity) {
                          return DropdownMenuItem(
                            child: Container(
                              child: Text(entity.name),
                              alignment: Alignment.center,
                            ),
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
                                entityId: entity.id,
                                showAllEvents: _showAllEvents);
                          });
                        },
                        value: _selectedEntity,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            Center(
              child: Container(
                width: 240,
                child: CheckboxListTile(
                  activeColor: Color.fromRGBO(196, 0, 0, 1),
                  title: const Text('اظهار نشاطات جميع الايام'),
                  value: _showAllEvents,
                  onChanged: (bool value) {
                    setState(() {
                      if (_showAllEvents == false)
                        _showAllEvents = true;
                      else
                        _showAllEvents = false;

                      _fillEventList(
                          categoryId: _selectedCategory.id,
                          entityId: _selectedEntity.id,
                          showAllEvents: _showAllEvents);
                    });
                  },
                ),
              ),
            ),
            MaterialButton(
                color: Color.fromRGBO(196, 0, 0, 1),
                onPressed: () async {
                  final List<DateTime> picked =
                      await DateRangePicker.showDatePicker(
                          context: context,
                          initialFirstDate: _selectedDate,
                          initialLastDate: _selectedDate,
                          firstDate: new DateTime(2019),
                          lastDate: new DateTime(2025));
                  if (picked != null) {
                    setState(() {
                      //I've assigned the date picked from the date picker in the
                      // _selectedDate instance. And I've got the first value
                      // because the pick variable is a list of dates.
                      _selectedDate = picked[0];

                      //Here I'll format the date selected from the date picker
                      // and assign it to the instance _eventsDate to send it
                      // with the URL to get the events.
                      _eventsDate = _dateFormatter.format(_selectedDate);

                      //Here I'll call the function that fills the list with
                      // the events for the date selected form the picker.
                      _fillEventList(
                          categoryId: _selectedCategory.id,
                          entityId: _selectedEntity.id,
                          showAllEvents: _showAllEvents);
                    });
                  }
                },
                child: new Text(
                  "اختر يوم محدد لعرض النشاطات",
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
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
      case 2: //this case when the "الكتل النيابية" chosen
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

  //This method will fill the events list with the events from the API to be
  // viewed on the events listView, and that based on the id of the selected
  // category and the selected entity.
  _fillEventList(
      {@required categoryId,
      entityId,
      //This parameter will be used to decide to fetch the events of the
      // current date or all the dates, and I've specified it as a required
      // because it's needed at all the times because I can't fetch the events
      // without knowing if that is for the current date or all the dates.
      @required showAllEvents}) async {
    //This is the URL of the required API, I'll concatenate it with the base URL
    // to be valid.
    //I'll provide the category id, to know which events to get based on the
    // id of the selected category.
    //And also I'll provide the entityId to get the events for that entity if
    // it's chosen.
    //And I've concatenated the eventsDateStatus value to decide to fetch the
    // events of the current date or for all the dates.
    var url = apiURL +
        "get_events.php?categoryId=$categoryId&entityId=$entityId&showAllEvents=$showAllEvents&eventsDate=$_eventsDate";
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
    //Here I'll check for the events list length and that to decide to view the
    // events list or the message that notify the user that there are no events
    // for today.
    //The events length should be greater than 1 to view the events, and not 0
    // because the list will always have at least one element and that is the
    // default element.
    if (_events.length > 1) {
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
            margin: EdgeInsets.only(top: 7, bottom: 7),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    textDirection: _rtlTextDirection,
                    children: <Widget>[
                      Text(
                        "التاريخ - الوقت : ",
                        style: TextStyle(fontWeight: FontWeight.bold),
                        textDirection: _rtlTextDirection,
                      ),
                      //I've wrapped the text in a Flexible widget because I want
                      // the text to flow on multi-lines.
                      Flexible(
                        child: Text(
                          "${_events[position].eventDate} - ${_events[position].time}",
                          textDirection: _rtlTextDirection,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    height: 10,
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    textDirection: _rtlTextDirection,
                    children: <Widget>[
                      Text(
                        "جـهــة الــنشــاط : ",
                        textDirection: _rtlTextDirection,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      //I've wrapped the text in a Flexible widget because I want
                      // the text to flow on multi-lines.
                      Flexible(
                        child: Text(
                          _events[position].eventEntityName,
                          textDirection: _rtlTextDirection,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    textDirection: _rtlTextDirection,
                    children: <Widget>[
                      Text(
                        "الــمــــوضــــــوع : ",
                        textDirection: _rtlTextDirection,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      //I've wrapped the text in a Flexible widget because I want
                      // the text to flow on multi-lines.
                      Flexible(
                        child: Text(
                          _events[position].subject,
                          textDirection: _rtlTextDirection,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    textDirection: _rtlTextDirection,
                    children: <Widget>[
                      Text(
                        "مكـان الاجتمـاع : ",
                        textDirection: _rtlTextDirection,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      //I've wrapped the text in a Flexible widget because I want
                      // the text to flow on multi-lines.
                      Flexible(
                        child: Text(
                          eventPlace,
                          textDirection: _rtlTextDirection,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      }
      //Here I'll return an empty container because I don't want to view the
      // default element in the event list that has an empty values.
      else
        return Container();
    } else {
      return Card(
        child: Text(
          "لا يوجد نشاطات لليوم \n لاظهار النشاطات \nاختر \" اظهار نشاطات جميع الايام \" \n او اختر فئة معينة من القائمة",
          textDirection: _rtlTextDirection,
          textAlign: TextAlign.center,
          style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              fontStyle: FontStyle.italic),
        ),
      );
    }
  }
}
