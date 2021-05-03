import 'dart:async';

import 'package:drink_app/database.dart';
import 'package:drink_app/home.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage>
    with AutomaticKeepAliveClientMixin {
  double _value = 1;
  int v = 1;
  int _counter = 0, _minutes = 0, _seconds = 0, _circularValue = 0;
  Timer _timer;
  bool _stopTimer = true;
  String startText = "Start";
  FlutterLocalNotificationsPlugin fltNotification;

  @override
  void initState() {
    super.initState();
    var androidInitialize = AndroidInitializationSettings('bb');
    var iOSInitialize = IOSInitializationSettings();
    var macInitialize = MacOSInitializationSettings();
    final InitializationSettings initializationSettings =
        InitializationSettings(
            android: androidInitialize,
            iOS: iOSInitialize,
            macOS: macInitialize);
    fltNotification = new FlutterLocalNotificationsPlugin();
    fltNotification.initialize(initializationSettings,
        onSelectNotification: notificationSelected);
    // CurrentUser _currentUser = Provider.of<CurrentUser>(context, listen: false);
    // await _currentUser.onStartUp();
  }

  Future notificationSelected(String payload) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: Text("Cool Cool Cool Cool Cool Cool..."),
      ),
    );
  }

  Future _showNotification() async {
    var androidDetails = AndroidNotificationDetails(
        'channelId', 'channelName', 'channelDescription',
        importance: Importance.max,
        playSound: true,
        sound: RawResourceAndroidNotificationSound('notsound'),
        enableVibration: true);
    var iOSDetails = IOSNotificationDetails();
    var generalNotificationDetails =
        NotificationDetails(android: androidDetails, iOS: iOSDetails);
    await fltNotification.show(
        0, "DO NOT TEXT!!!", "DO NOT TEXTTT!!!", generalNotificationDetails);
  }

  void _startTimer() {
    _counter = v * 60;
    _circularValue = v * 60;
    _seconds = _counter % 60;
    _minutes = _counter ~/ 60;
    _timer = Timer.periodic(Duration(seconds: 1), (_timer) {
      setState(() {
        if (_counter > 0 && _stopTimer == false) {
          _counter--;
          _minutes = _counter ~/ 60;
          _seconds = (_counter % 60);
          // print(_counter);
        } else if (_counter <= 0 && _stopTimer == false) {
          _showNotification();
          //TODO : Trigger Notification
          _counter = v * 60;
          _counter--;
          _minutes = _counter ~/ 60;
          _seconds = (_counter % 60);
        } else {
          _minutes = 0;
          _seconds = 0;
          _timer.cancel();
        }
      });
    });
  }

  double circularPercent() {
    if (_stopTimer == true) {
      return 0.0;
    } else {
      //print(_circularValue);
      return _counter / (_circularValue);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff231b10),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          timerWidget(),
          SizedBox(
            height: 60,
          ),
          Center(
            child: Container(
              child: Text(
                "Remind me not to text every",
                style: TextStyle(color: Colors.white, fontSize: 25),
              ),
            ),
          ),
          SizedBox(
            height: 30,
          ),
          //Slider Widget
          Container(
            child: SliderTheme(
              data: SliderTheme.of(context).copyWith(
                activeTrackColor: Colors.orange,
                inactiveTrackColor: Color(0xfff0c459),
                trackShape: RoundedRectSliderTrackShape(),
                trackHeight: 10,
                thumbColor: Color(0xff975711),
                overlayColor: Colors.amber.withAlpha(70),
                thumbShape:
                    RoundSliderThumbShape(enabledThumbRadius: 12, elevation: 5),
                tickMarkShape: RoundSliderTickMarkShape(),
                activeTickMarkColor: Colors.white,
                inactiveTickMarkColor: Color(0xfff0c459),
                valueIndicatorShape: PaddleSliderValueIndicatorShape(),
                valueIndicatorColor: Colors.orange,
                valueIndicatorTextStyle:
                    TextStyle(color: Colors.white, fontSize: 20),
              ),
              child: Slider(
                min: 1,
                max: 20,
                value: _value,
                divisions: 19,
                label: "$_value",
                onChanged: (value) {
                  setState(() {
                    _value = value;
                    v = value.ceil();
                  });
                },
              ),
            ),
          ),
          SizedBox(
            height: 20,
          ),
          Center(
            child: Container(
              child: Text(
                v == 1 ? "$v minute" : "$v minutes",
                style: TextStyle(color: Colors.white, fontSize: 25),
              ),
            ),
          ),
          SizedBox(
            height: 30,
          ),
          //Start - Stop Button
          Container(
            height: 50,
            width: 200,
            child: RaisedButton(
              onPressed: () async {
                if (_stopTimer == true) {
                  _stopTimer = false;
                  startText = "Stop";
                } else {
                  _stopTimer = true;
                  startText = "Start";
                }

                _startTimer();
                if (_stopTimer == false) {
                  // OurDatabase().getContext(context);
                  // await CurrentUser().upGraph();
                  await Database().updateGraph();
                }
              },
              child: Text(
                "$startText",
                style: TextStyle(color: Colors.white, fontSize: 25),
              ),
              color: Color(0xff975711),
              elevation: 5,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30)),
            ),
          ),
          SizedBox(
            height: 60,
          ),
        ],
      ),
    );
  }

  Container timerWidget() {
    return Container(
      height: 220,
      width: 220,
      child: Center(
        child: Stack(
          children: [
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  TimerText(value: _minutes.toString().padLeft(2, "0")),
                  Text(
                    " : ",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 40,
                        fontWeight: FontWeight.bold),
                  ),
                  TimerText(value: _seconds.toString().padLeft(2, "0")),
                ],
              ),
            ),
            Center(
              child: CircularPercentIndicator(
                animation: true,
                animateFromLastPercent: true,
                animationDuration: 1000,
                radius: 200,
                percent: circularPercent(),
                lineWidth: 18,
                backgroundColor: Colors.white,
                linearGradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.orange,
                    Colors.red,
                    // Color(0xfff0c459),
                    // Color(0xff975711),
                  ],
                ),
                circularStrokeCap: CircularStrokeCap.round,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class TimerText extends StatelessWidget {
  TimerText({this.value});

  final String value;
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Text(
        "$value",
        style: TextStyle(
            color: Colors.white, fontSize: 40, fontWeight: FontWeight.bold),
      ),
    );
  }
}
