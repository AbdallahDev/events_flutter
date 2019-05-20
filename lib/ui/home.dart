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
  //This is the API base URL.
  var apiURL = "http://10.152.134.193/apps/myapps/events/mobile/apis/";

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
    _selectedCategory = _categories[0];
    //This function will fill the category list with values from the API.
    _fillCategories();
    _entities = [Entity(id: 0, name: "جميع الجهات", categoryId: 0, rank: 0)];
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
                    _showEntityMenu(categoryId: category.id);
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
    //This is the URL of the required API, I'll concatenate it with the base URL
    // to be valid.
    var url = apiURL + "get_categories.php";
    http.Response response = await http.get(url);
    List categories = List();
    categories = json.decode(response.body);
    categories.forEach((map) {
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
    List entities = List();
    entities = json.decode(response.body);
    //I'll initialize the list because I want to view the default first choice
    // on the list.
    _entities = _entities = [
      Entity(id: 0, name: "جميع الجهات", categoryId: 0, rank: 0)
    ];
    //I'll assign the first element of the list to the _selectedEntity var
    // because I want to show the default value "جميع الجهات" as the first value
    // in the menu.
    _selectedEntity = _entities[0];
    entities.forEach((map) {
      _entities.add(Entity.fromMap(map));
    });
    setState(() {});
  }

  _fillEventList(id) async {
    _events.clear();
    _events = await EventList.getEvents(categoryId: id);
  }
}
