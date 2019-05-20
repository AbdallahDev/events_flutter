import 'dart:convert';

import 'package:events_flutter/model/category.dart';
import 'package:events_flutter/model/entity.dart';
import 'package:events_flutter/model/event.dart';
import 'package:events_flutter/ui/event_list.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

//This class is to view the dropDown buttons and the events list view.
class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  //This list to store the category objects.
  List<Category> _categories;

  //This field to store the selected category object from the category dropdown menu.
  Category _selectedCategory;
  List<Entity> _entities;
  Entity _selectedEntity;
  bool _entityVisibility;
  List<Event> _events;

  //I need the initState function to run some of the code just at the first time
  // the app runs.
  @override
  void initState() {
    super.initState();
    //I'll initialize some of the fields with values so the app doesn't face an
    // error for the first time it runs.
    _categories = [Category(id: 0, name: "جميع الفئات")];
    //This function will fill the category list with values from the API.
    _fillCategories();
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

  //I'll fill the category list directly from the API.
  Future _fillCategories() async {
    var url =
        "http://10.152.134.193/apps/myapps/events/mobile/apis/get_categories.php";
    http.Response response = await http.get(url);
    List categories = List();
    categories = json.decode(response.body);
    categories.forEach((map) {
      _categories.add(Category.fromMap(map));
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
//    List entities = await _databaseHelper.getEntities(categoryId: categoryId);
    _entities.clear();
    _entities.add(Entity(id: 0, name: "جميع الجهات", categoryId: 0, rank: 0));
    _selectedEntity = _entities[0];
//    entities.forEach((map) {
//      _entities.add(Entity.fromMap(map));
//    });
    setState(() {});
  }

  _fillEventList(id) async {
    _events.clear();
    _events = await EventList.getEvents(categoryId: id);
  }
}
