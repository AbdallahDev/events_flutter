import 'dart:async';
import 'dart:io';

import 'package:events_flutter/model/category.dart';
import 'package:events_flutter/model/entity.dart';
import 'package:events_flutter/model/event.dart';
import 'package:meta/meta.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  //The purpose of this field to be a singleton, so can't be two objects of the
  // database_helper created.
  static final DatabaseHelper _databaseHelper = DatabaseHelper.internal();

  DatabaseHelper.internal();

  factory DatabaseHelper() => _databaseHelper;

  //These are the fields that related to the category table.
  //And I made the column names identical to the ones in the remote DB.
  var categoryTable = 'category';
  var categoryIdColumn = 'event_entity_category_id';
  var categoryNameColumn = 'event_entity_category_name';

  //These are the fields that related to the entity (eg. committees) table.
  //And I made the column names identical to the ones in the remote DB.
  var entityTable = 'entity';
  var entityIdColumn = 'committee_id';
  var entityNameColumn = 'committee_name';
  var entityCategoryId = "event_entity_category_id";
  var committeeRank = "committee_rank";

  //Event_entity table related fields.
  //And I made the column names identical to the ones in the remote DB.
  var eventEntityTable = "event_event_entity";
  var eventEntityEventId = "event_id";
  var eventEntityId = "event_entity_id";

  //Those are the fields related to the event table
  //And I made the column names identical to the ones in the remote DB.
  var eventTable = "event";
  var eventIdColumn = "id";
  var eventEntityNameColumn = "event_entity_name";
  var eventTimeColumn = "time";
  var eventAppointmentColumn = "event_appointment";
  var eventSubjectColumn = "subject";
  var eventDateColumn = "event_date";
  var eventHallIdColumn = "hall_id";
  var eventPlaceColumn = "event_place";

  Database _database;

  //I used the get method for the database field to make sure that it can't be
  // created twice in the memory.
  Future<Database> get database async {
    if (_database != null) return _database;
    return await initDb();
  }

  //This method will initialize the DB.
  Future<Database> initDb() async {
    Directory directory = await getApplicationDocumentsDirectory();
    String path = join(directory.path, "events.db");
    Database database =
        await openDatabase(path, version: 1, onCreate: onCreate);
    return database;
  }

  //Bellow are the crud methods related to the category table.
  //This method will create all the local DB tables.
  void onCreate(Database db, int version) {
    //Creating the category table
    String sql =
        "CREATE TABLE $categoryTable ($categoryIdColumn INTEGER PRIMARY KEY, "
        "$categoryNameColumn TEXT)";
    db.execute(sql);

    //Creating the entity table
    sql = "CREATE TABLE $entityTable ($entityIdColumn INTEGER PRIMARY KEY, "
        "$entityNameColumn TEXT, $entityCategoryId INTEGER, $committeeRank INTEGER)";
    db.execute(sql);

    //creating the event_entity table.
    sql = "CREATE TABLE $eventEntityTable ("
        "$eventEntityEventId INTEGER, "
        "$eventEntityId INTEGER)";
    db.execute(sql);

    //creating the event table.
    sql = "CREATE TABLE $eventTable ("
        "$eventIdColumn INTEGER PRIMARY KEY, "
        "$eventEntityNameColumn TEXT, "
        "$eventTimeColumn TEXT, "
        "$eventAppointmentColumn TEXT, "
        "$eventSubjectColumn TEXT, "
        "$eventDateColumn TEXT, "
        "$eventHallIdColumn INTEGER, "
        "$eventPlaceColumn TEXT)";
    db.execute(sql);
  }

  //the bellow are the methods related to the category table
  Future<int> insertCategory(Category category) async {
    Database database = await this.database;
    int id = await database.insert(categoryTable, category.toMap());
    return id;
  }

  Future<List> getCategories() async {
    Database database = await this.database;
    List categories = await database.query(categoryTable);
    return categories;
  }

  //Bellow are the methods related to the entity table
  Future<int> insertEntity(Entity entity) async {
    Database database = await this.database;
    int id = await database.insert(entityTable, entity.toMap());
    return id;
  }

  //this method gets all the entities belong to a specific category.
  Future<List> getEntities({@required categoryId}) async {
    Database database = await this.database;
    List result = await database.query(entityTable,
        where: "$entityCategoryId = ?", whereArgs: [categoryId]);
    return result;
  }

  //Bellow are the methods related to the event table.
  Future<int> insertEvent({@required Event event}) async {
    Database database = await this.database;
    var id = await database.insert(eventTable, event.toMap());
    return id;
  }

  Future<List> getEvent({@required eventId}) async {
    Database database = await this.database;
    List result =
        await database.query(eventTable, where: "id = ?", whereArgs: [eventId]);
    return result;
  }

  //Below are the methods related to the event entity table.
  Future<int> insertEventEntity({@required Map values}) async {
    Database database = await this.database;
    int id = await database.insert(eventEntityTable, values);
    return id;
  }

  //I'll get the event ids that belong to a specific entity.
  Future<List> getEventIds({@required int entityId}) async {
    Database database = await this.database;
    List ids = await database.query(eventEntityTable,
        columns: [eventEntityEventId],
        where: "$eventEntityId = ?",
        whereArgs: [entityId]);
    return ids;
  }
}
