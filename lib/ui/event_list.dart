//This class will get the events and return them as a list.
//I've made it separate because I don't want all the code to be in the home file.

import 'package:events_flutter/util/database_helper.dart';
import 'package:meta/meta.dart';

class EventList {
  //This method will get the events for a specific category.
  //I made it static so it can be accessed without the need for a new object.
  static Future<List> fillEventList({@required int categoryId}) async {
    //This list will store the entity ids that I got from the function _getEntityIds.
    List entityIds = await _getEntityIds(categoryId: categoryId);

    //I'll loop over the entity ids to get the events that belong to each one.
    entityIds.forEach((id) {});
  }

  //This function will get the entity ids that belong to a specific category.
  //And I've made this function separate to make the code more organized.
  static Future<List<int>> _getEntityIds({@required int categoryId}) async {
    DatabaseHelper databaseHelper = DatabaseHelper();
    //First I should get the entity ids that belong to the specified category.
    List result = await databaseHelper.getEntityIds(categoryId: categoryId);
    //This list will hold the entity ids.
    List<int> entityIds = List();
    //I'll loop over the result list to store the ids as integers in the entityIds list.
    result.forEach((map) {
      entityIds.add(map['committee_id']);
    });
    return entityIds;
  }
}
