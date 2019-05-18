import 'package:events_flutter/model/category.dart';
import 'package:events_flutter/model/entity.dart';
import 'package:events_flutter/model/event.dart';
import 'package:events_flutter/ui/event_list.dart';
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

  //This field to store the databaseHelper class instance.
  DatabaseHelper _databaseHelper;

  //This list to store the category objects.
  List<Category> _categories;

  //This field to store the selected category object from the dropdown menu.
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
    _fillEventList(_selectedCategory.id);
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
                    _fillEventList(_selectedCategory.id);
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
            /*Flexible(
              child: ListView.builder(
                  itemCount: _events.length,
                  itemBuilder: (context, position) {
                    return ListTile(
                      title: Text(_events[position].subject),
                    );
                  }),
            ),*/
            //This is a test container.
            Container(
              child: Text(_events.length.toString()),
            )
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

  _fillEventList(id) async {
    _events.clear();
    print("10 = ${await EventList.getEvents(categoryId: id)}");
    _events= await EventList.getEvents(categoryId: id);
  }
}
