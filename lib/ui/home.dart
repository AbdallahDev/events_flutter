import 'package:events_flutter/model/category.dart';
import 'package:events_flutter/model/entity.dart';
import 'package:events_flutter/model/event.dart';
import 'package:events_flutter/util/api_helper.dart';
import 'package:events_flutter/util/database_helper.dart';
import 'package:flutter/material.dart';

//This class is to view the dropDown buttons and the events list view.
class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  //This field is for the APIHelper class that deals with the APIs.
  APIHelper _apiHelper;
  DatabaseHelper _databaseHelper;
  List<Category> _categories;
  Category _selectedCategory;
  List<Entity> _entities;
  Entity _selectedEntity;
  bool _entityVisibility;
  List<Event> _events;

  //I need the initState function to run some of the code just the first time
  // the app runs.
  @override
  void initState() {
    super.initState();
    _apiHelper = APIHelper();
    //This function will call the function that deals with the API data and fills
    // it in the local DB.
    _apiHelper.fillDBTables();
    _databaseHelper = DatabaseHelper();
    _categories = [Category(id: 0, name: "جميع الفئات")];
    _fillCategoryList();
    _selectedCategory = _categories[0];
    _entities = List();
    _entityVisibility = false;
    _events = [
      Event(
          id: 0,
          eventEntityName: "",
          time: "",
          eventAppointment: "",
          subject: "",
          eventDate: "",
          hallId: 0,
          eventPlace: "")
    ];
    _fillEventsList(categoryId: 0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Events"),
      ),
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
                    _selectedCategory = category;
                    _handleEntityMenu(category.id);
                    _fillEventsList(categoryId: category.id);
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
                      });
                    },
                    value: _selectedEntity,
                  ),
                )),
            Flexible(
              child: ListView.builder(
                  itemCount: _events.length,
                  itemBuilder: (context, position) {
                    return ListTile(
                      title: Text(_events[position].subject),
                    );
                  }),
            ),
          ],
        ),
      ),
    );
  }

  //bellow are the methods related to the category object data
  //i'll get the categories data from the local db.
  //and fill the required data in the needed lists
  Future _fillCategoryList() async {
    List categories = await _databaseHelper.getCategories();
    categories.forEach((category) {
      this._categories.add(Category.fromMap(category));
    });
    setState(() {});
  }

  //bellow are the methods related to the entity object data
  void _handleEntityMenu(categoryId) {
    if (categoryId != 0 && categoryId != 5 && categoryId != 6) {
      _fillEntityList(categoryId: categoryId);
      _entityVisibility = true;
    } else
      _entityVisibility = false;
  }

  //i'll fill the entities list from entities local db table.
  Future _fillEntityList({@required categoryId}) async {
    List entities = await _databaseHelper.getEntities(categoryId: categoryId);
    _entities.clear();
    _entities.add(Entity(id: 0, name: "جميع الجهات", categoryId: 0, rank: 0));
    _selectedEntity = _entities[0];
    entities.forEach((map) {
      _entities.add(Entity.fromMap(map));
    });
    setState(() {});
  }

  //bellow are the methods related to the event data.
  Future _fillEventsList({@required categoryId}) async {
    //First I should get the entities that belong to the specified category.
    //here i should get just the ids of the entities not all the data.
    //i should change it next time.
    List entities = await _databaseHelper.getEntities(categoryId: categoryId);
    //here i'll empty the _events list so it dose not stack the new result over the old ones
//    _events.clear();
    //Next, I'll loop over those entities to get the events that belong to each one of them.
    entities.forEach((map) async {
      List<Map> eventIds =
          await _databaseHelper.getEventIds(entityId: map["committee_id"]);
      if (eventIds.length != 0) {
        eventIds.forEach((value) async {
          List event =
              await _databaseHelper.getEvent(eventId: value['event_id']);
          _events.add(Event.fromMap(event.first));
        });
      }
    });
  }
}
