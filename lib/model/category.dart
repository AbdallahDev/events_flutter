import 'package:meta/meta.dart';

//This class is for the category object model.
class Category {
  int _id;
  String _name;

  /*I've made the parameters required so they can appear when the object created,
   it will make things easier.*/
  Category({@required id, @required name})
      : _id = id,
        _name = name;

  int get id => _id;

  String get name => _name;

  Map<String, dynamic> toMap() {
    return {
      "event_entity_category_id": _id,
      "event_entity_category_name": _name
    };
  }

  Category.fromMap(Map<String, dynamic> map) {
    _id = map['event_entity_category_id'];
    _name = map['event_entity_category_name'];
  }
}
