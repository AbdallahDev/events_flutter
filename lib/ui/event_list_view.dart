//This class will create the event ListView.
//I've made it separate because I don't want all the code to be in the home file.

import 'package:flutter/material.dart';

class EventListView extends StatelessWidget {
  //The constructor will take the category id to view the events that belong to it.
  EventListView({@required int categoryId});

  @override
  Widget build(BuildContext context) {
    return Text("data");
  }
}
