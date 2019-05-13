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

  //This function will fetch the data related to the category and inserted in
  // the local DB.
  fillCategoryDBTable() {

  }
}
