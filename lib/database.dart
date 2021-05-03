import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:drink_app/home.dart';
import 'package:drink_app/screens/graph_page.dart';
import 'package:fl_chart/fl_chart.dart';

List<FlSpot> dataList = List<FlSpot>();
List<DateTime> offlineDatabase = List<DateTime>();
int highestValue = 4;

class Database {
  final String currentUserId = currentUser.id;

  List<FlSpot> get data =>
      List.unmodifiable(dataList..sort((a, b) => a.x.compareTo(b.x)));

  void addPoint(FlSpot spot) {
    dataList.add(spot);
    value = highestValue.toDouble();
  }

  Future<void> updateGraph() async {
    try {
      bool ifGraphExists = checkIfGraphExists();
      List<Timestamp> today = List<Timestamp>();
      today.add(Timestamp.now());

      if (ifGraphExists) {
        bool ifTodayExists = checkIfTodayExists();
        if (ifTodayExists) {
          //do nothing
        } else {
          await graphsRef
              .document(currentUserId)
              .updateData({"dates": FieldValue.arrayUnion(today)});
          DateTime thisDay = DateTime.now();
          offlineDatabase.add(thisDay);
          buildGraph(offlineDatabase);
        }
      } else {
        await graphsRef
            .document(currentUserId)
            .setData({"dates": FieldValue.arrayUnion(today)});
        DateTime thisDay = DateTime.now();
        offlineDatabase.add(thisDay);
        buildGraph(offlineDatabase);
      }
    } catch (e) {
      print(e);
    }
  }

  //checks if graph exists
  bool checkIfGraphExists() {
    bool retVal = false;

    if (offlineDatabase.isNotEmpty) {
      retVal = true;
    }
    return retVal;
  }

  bool checkIfTodayExists() {
    bool retVal = false;
    DateTime thisDay = DateTime.now();
    if (offlineDatabase[offlineDatabase.length - 1].year == thisDay.year &&
        offlineDatabase[offlineDatabase.length - 1].month == thisDay.month &&
        offlineDatabase[offlineDatabase.length - 1].day == thisDay.day) {
      retVal = true;
    }
    return retVal;
  }

//Fetches data from firestore and puts it in offline database
  Future<void> updateOfflineGraph() async {
    List<dynamic> today = List<dynamic>();

    try {
      DocumentSnapshot _docSnapshot =
          await graphsRef.document(currentUserId).get();
      today.addAll(_docSnapshot.data()["dates"]);
      offlineDatabase.clear();
      for (int i = 0; i < today.length; i++) {
        offlineDatabase.add(DateTime.fromMicrosecondsSinceEpoch(
            today[i].microsecondsSinceEpoch));
      }
      buildGraph(offlineDatabase);
    } catch (e) {
      print(e);
    }
  }

  //Adds data in form of spots
  void buildGraph(List<DateTime> dateTime) {
    removeAllPoints();
    DateTime now = new DateTime.now();
    int days = 0;
    int month = dateTime[0].month;

    for (int i = 0; i < dateTime.length; i++) {
      if (dateTime[i].year == now.year) {
        if (dateTime[i].month == month) {
          days++;
        } else {
          addMonth(days, month);
          days = 0;
          month = dateTime[i].month;
          i--;
        }
      } else {
        if ((i + 1) <= dateTime.length) {
          month = dateTime[i + 1].month;
        }
      }
    }
    addMonth(days, month);
  }

  void addMonth(int days, int month) {
    if (highestValue <= days) {
      highestValue = days;
      highestValue++;
      if (highestValue % 2 != 0) {
        highestValue++;
      }
    }
    addPoint(FlSpot(month.toDouble(), days.toDouble()));
  }

  void removeAllPoints() {
    dataList.clear();
  }
}
