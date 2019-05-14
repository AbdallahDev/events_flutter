import 'dart:convert';

import 'package:events_flutter/util/database_helper.dart';
import 'package:http/http.dart' as http;

//This class to manage the data that have been fetched by the APIs and needed
// to be stored in the local DB.
class APIHelper {
  //This field is the singleton of the class instance.
  //Because I don't want multiple instances created for the same class,
  // so they don't occupy much space in the mobile memory.
  static final APIHelper _apiHelper = APIHelper.internal();

  //This named constructor will instantiate the class instance.
  APIHelper.internal();

  //This factory instructor will return the class instance.
  factory APIHelper() => _apiHelper;

  //This field will store the IP of the computer that hosts the xampp server,
  // and most of the time it will be my computer IP.
  static final String _ip = "10.152.160.74";

  //I've created this field just to make the URL shorter when it's used inside
  // the methods, this URL is for the events web app.
  final String appUrl = "http://$_ip/apps/myapps/events/mobile/apis";

  //This is field store an instance of the DatabaseHelper class so I can deal
  // with the local DB.
  DatabaseHelper _databaseHelper = DatabaseHelper();

  //This function will fetch the data related to the category and inserted in
  // the local DB.
  _fillCategoryDBTable() async {
    //This the URL of the API related to the category.
    String url = "$appUrl/get_categories.php";
    //Here I'll get all the data source.
    http.Response response = await http.get(url);
    //This list will contain the category data as maps from the API.
    List body = json.decode(response.body);
    //Here I'll loop over the list maps to store them in the local DB.
    body.forEach((map) async {
      await _databaseHelper.insertCategory(map: map);
    });
  }

  //This function will get the data related to the entity from the API and insert
  // it in the local DB.
  _fillEntityDBTable() async {
    //This is the URL for the entity API,
    //For now, I've appended the category id because the API need it to decide
    // which data to get, but later on I'll remove it.
    String url = "$appUrl/get_committees.php?categoryId=0";
    http.Response response = await http.get(url);
    //This list will contain the entity data as maps from the API.
    List body = json.decode(response.body);
    //Here I'll loop over the entity maps to store them in the local DB.
    body.forEach((map) async {
      await _databaseHelper.insertEntity(map: map);
    });
  }

  //This function will get the data related to the event entity from the API and insert
  // it in the local DB.
  _fillEventEntityDBTable() async {
    //This is the URL for the API,
    String url = "$appUrl/event_entity_get.php";
    http.Response response = await http.get(url);
    //This list will contain the event entity data as maps from the API.
    List body = json.decode(response.body);
    //Here I'll loop over the event entity maps to store them in the local DB.
    body.forEach((map) async {
      await _databaseHelper.insertEventEntity(map: map);
    });
  }
}
