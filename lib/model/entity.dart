import 'package:meta/meta.dart';

class Entity {
  int _id;
  String _name;
  int _categoryId;
  int _rank;

  Entity({@required id, @required name, @required categoryId, @required rank})
      : _id = id,
        _name = name,
        _categoryId = categoryId,
        _rank = rank;

  int get id => _id;

  String get name => _name;

  int get categoryId => _categoryId;

  int get rank => _rank;

  Map toMap() {
    Map<String, dynamic> map = Map();
    map['committee_id'] = _id;
    map['committee_name'] = _name;
    map['event_entity_category_id'] = _categoryId;
    map['committee_rank'] = _rank;

    return map;
  }

  Entity.fromMap(Map map) {
    _id = map['committee_id'];
    _name = map['committee_name'];
    _categoryId = map['event_entity_category_id'];
    _rank = map['committee_rank'];
  }
}
