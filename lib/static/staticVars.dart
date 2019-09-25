//this file contains the static variable for the web system url.

class StaticVars{
  //I've made the API URL variable as static because I want to access it
  // globally and I don't want to change it every time in the home file.
  static final apiUrl = url;

  //I've created these two variables to make it easy for me to switch between
  // the API URL of the working web system and the testing one.
 static var url = "http://193.188.88.148/events/mobile/apis/";
 static var url0 = "http://193.188.88.148/apps/myapps/events/mobile/apis/";
}