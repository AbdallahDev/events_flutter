import 'package:meta/meta.dart';

//This class is for the event object model.
class Event {
  int _id;
  String _eventEntityName;
  String _time;
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
    _id = map['id'];
    _eventEntityName = map['eventEntityName'];
    _time = map['time'];
    _eventAppointment = map['eventAppointment'];
    _subject = map['subject'];
    _eventDate = map['eventDate'];
    _hallId = map['hallId'];
    _eventPlace = map['eventPlace'];
  }
}
