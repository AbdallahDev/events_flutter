//This class will get the events and return them as a list.
//I've made it separate because I don't want all the code to be in the home file.

import 'package:events_flutter/model/event.dart';
import 'package:events_flutter/util/database_helper.dart';
import 'package:meta/meta.dart';

class EventList {
  //This field holds an instance of the databaseHelper class that deals with the
  // database.
  static DatabaseHelper _databaseHelper = DatabaseHelper();

  //This function will get the event ids that belong to a specific entity from
  // the table event entity.
  //Then it will fill the events list with the event objects that contain the
  // details of the event.
  //I made it separate to make the code more concise.
  static Future getEvents({@required int categoryId}) async {
    //This list will contain the events objects to be returned to the home page.
    List<Event> events = List();
    //This list will store the entity ids that I got from the function _getEntityIds.
    List entityIds = await _getEntityIds(categoryId: categoryId);
    //Next, I'll loop over those entities to get the events that belong to each
    // one of them.
    entityIds.forEach((entityId) async {
      //This list contains the event ids that belong to a specific entity.
      List eventIds = await _databaseHelper.getEventIds(entityId: entityId);
      //I'll make sure that the list is not empty.
      if (eventIds.length != 0) {
        //I'll loop over the event ids list to get the details for each event.
        eventIds.forEach((map) async {
          //This list will store the event details from the local DB.
          List event = await _databaseHelper.getEvent(eventId: map['event_id']);
          //Here I'll create for each event an object, by getting the first
          // values in the list that represent the event map, then I'll add it
          // to the events list.
          events.add(Event.fromMap(event.first));
        });
      }
    });

    return events;
  }

  //This function will get the entity ids that belong to a specific category.
  //And I've made this function separate to make the code more organized.
  static Future<List<int>> _getEntityIds({@required int categoryId}) async {
    //First I should get the entity ids that belong to the specified category.
    List result = await _databaseHelper.getEntityIds(categoryId: categoryId);
    //This list will hold the entity ids.
    List<int> entityIds = List();
    //I'll loop over the result list to store the ids as integers in the entityIds list.
    result.forEach((map) {
      entityIds.add(map['committee_id']);
    });
    return entityIds;
  }
}
