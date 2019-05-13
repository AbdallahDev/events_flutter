import 'package:meta/meta.dart';

//This class is for the entity object model.
class Entity {
  int _id;
  String _name;
  int _categoryId;
  int _rank;

  /*I've made the parameters required so they can appear when the object created,
   it will make things easier.*/
  Entity({@required id, @required name, @required categoryId, @required rank})
      : _id = id,
        _name = name,
        _categoryId = categoryId,
        _rank = rank;

  //I'll use just getters because I'll not try to modify the objects in the database,
  // I'll just fetch them from the remote DB and I'll store them in the local DB.
  int get id => _id;

  String get name => _name;

  int get categoryId => _categoryId;

  int get rank => _rank;

  //I'll use this method when I try to save the object to the local DB.
  Map toMap() {
    //Here I'll return a map with the key names identical the column names
    // from the remote DB for the entity table.
    //Because if I don't do that I'll get errors because the keys for the maps
    // that I get from the API JSON will different from the object map keys.
    Map<String, dynamic> map = Map();
    map['committee_id'] = _id;
    map['committee_name'] = _name;
    map['event_entity_category_id'] = _categoryId;
    map['committee_rank'] = _rank;

    return map;
  }

  //This method will be used when the app creates a new entity object using
  // values from the DB.
  Entity.fromMap(Map map) {
    _id = map['committee_id'];
    _name = map['committee_name'];
    _categoryId = map['event_entity_category_id'];
    _rank = map['committee_rank'];
  }
}
