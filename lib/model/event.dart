import 'package:meta/meta.dart';

class Event {
  int _id;
  String _eventEntityName;
  String _time;
  String _eventAppointment;
  String _subject;
  String _eventDate;
  int _hallId;
  String _eventPlace;

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

  String get eventPlace => _eventPlace;

  int get hallId => _hallId;

  String get eventDate => _eventDate;

  String get subject => _subject;

  String get eventAppointment => _eventAppointment;

  String get time => _time;

  String get eventEntityName => _eventEntityName;

  int get id => _id;

  Map<String, dynamic> toMap() {
    var map = Map<String, dynamic>();
    map['id'] = id;
    map['event_entity_name'] = eventEntityName;
    map['time'] = time;
    map['event_appointment'] = eventAppointment;
    map['subject'] = subject;
    map['event_date'] = eventDate;
    map['hall_id'] = hallId;
    map['event_place'] = eventPlace;

    return map;
  }

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
