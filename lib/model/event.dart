import 'package:meta/meta.dart';

//This class is for the event object model.
class Event {
  int _id;
  //This is the name of the entity when it's typed as a text in the entity name
  // textField in the web app.
  String _eventEntityName;
  //This is the name of the entity when it's chosen from the entity drop down
  // menu in the web app.
  String _entityName;
  String _time;
  //This represents when the event will behold as it's typed as a text in the
  // event appointment textField in the web app.
  String _eventAppointment;
  String _subject;
  String _eventDate;
  int _hallId;
  String _eventPlace;

  /*I've made the parameters required so they can appear when the object created,
   it will make things easier.*/
  Event({
    @required id,
    @required eventEntityName,
    @required time,
    @required eventAppointment,
    @required subject,
    @required eventDate,
    @required hallId,
    @required eventPlace,
  })  : _id = id,
        _eventEntityName = eventEntityName,
        _time = time,
        _eventAppointment = eventAppointment,
        _subject = subject,
        _eventDate = eventDate,
        _hallId = hallId,
        _eventPlace = eventPlace;

  //I'll use just getters because I'll not try to modify the objects in the database,
  // I'll just fetch them from the remote DB and I'll store them in the local DB.
  String get eventPlace => _eventPlace;

  int get hallId => _hallId;

  String get eventDate => _eventDate;

  String get subject => _subject;

  String get eventAppointment => _eventAppointment;

  String get time => _time;

  String get eventEntityName => _eventEntityName;

  int get id => _id;

  //This method will be used when the app creates a new event object using
  // values from the DB.
  Event.fromMap(Map map) {
    //Here the map keys should be the same as the one in the fetched JSON from
    // the API.
    _id = map['id'];
    _eventEntityName = map['event_entity_name'];
    _time = map['time'];
    _eventAppointment = map['eventAppointment'];
    _subject = map['subject'];
    _eventDate = map['event_date'];
    _hallId = map['hallId'];
    _eventPlace = map['eventPlace'];
  }
}
