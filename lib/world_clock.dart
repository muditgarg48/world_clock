import 'dart:async';
import 'package:flutter/material.dart';

import 'package:intl/intl.dart';

import 'package:analog_clock/analog_clock.dart';
import 'package:concentric_transition/concentric_transition.dart';

class WorldClock extends StatefulWidget {
  WorldClock({required this.title});

  final String title;

  @override
  _WorldClockState createState() => _WorldClockState();
}

class _WorldClockState extends State<WorldClock> {
  String timeString = "";
  DateTime chosenTime = DateTime.now();
  bool isDigital = true;

  @override
  void initState() {
    timeString = formatDateTime(DateTime.now());
    Timer.periodic(
      const Duration(
        seconds: 1,
      ),
      (Timer t) {
        setTime();
      },
    );
    super.initState();
  }

  Widget myAnalogClock(BuildContext context) {
    return Center(
      child: AnalogClock(
        decoration: const BoxDecoration(
          // border: Border.all(
          //   width: 0.0,
          //   color: Colors.black,
          // ),
          // boxShadow: [
          //   BoxShadow(
          //     blurRadius: 5,
          //     spreadRadius: 2,
          //     blurStyle: BlurStyle.normal,
          //   ),
          // ],
          color: Colors.white,
          shape: BoxShape.circle,
        ),
        width: MediaQuery.of(context).size.width / 1.5,
        height: MediaQuery.of(context).size.height / 2,
        isLive: true,
        hourHandColor: Colors.black,
        minuteHandColor: Colors.black,
        showSecondHand: true,
        numberColor: Colors.black87,
        showNumbers: true,
        showDigitalClock: false,
        textScaleFactor: 1.5,
        showTicks: true,
        datetime: chosenTime,
      ),
    );
  }

  Widget myDigitalClock(BuildContext context) {
    return Center(
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            width: 0.0,
            color: Colors.black,
          ),
          boxShadow: const [
            BoxShadow(
              blurRadius: 5,
              spreadRadius: 2,
              blurStyle: BlurStyle.normal,
            ),
          ],
          color: Colors.white,
          shape: BoxShape.circle,
        ),
        margin: const EdgeInsets.symmetric(horizontal: 10),
        width: MediaQuery.of(context).size.width / 1.5,
        height: MediaQuery.of(context).size.height / 2,
        child: Center(
          child: Text(
            timeString,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: MediaQuery.of(context).size.height / 25,
            ),
          ),
          // child: QudsDigitalClockViewer(
          //   showSeconds: true,
          //   format24: false,
          //   showTimePeriod: true,
          //   timePeriodStyle: TextStyle(
          //     fontSize: MediaQuery.of(context).size.height / 15,
          //   ),
          //   showMilliSeconds: false,
          // ),
        ),
      ),
    );
  }

  DateTime timeCalc(String location) {
    return DateTime.now();
  }

  void setTime() => setState(() {
        chosenTime = timeCalc("dummy_location");
        timeString = formatDateTime(chosenTime);
      });

  String formatDateTime(DateTime dateTime) {
    return DateFormat('dd/MM/yyyy\nhh:mm:ss').format(dateTime);
  }

  dynamic clockFormatSwitcher() {
    return ConcentricPageView(
      colors: const [
        Colors.white,
        Colors.blue,
      ],
      radius: MediaQuery.of(context).size.width,
      itemCount: null, // null = infinity
      physics: const AlwaysScrollableScrollPhysics(),
      duration: const Duration(milliseconds: 900),
      itemBuilder: (int index) {
        index %= 2;
        return Center(
          child: Container(
            child: index % 2 == 0
                ? myAnalogClock(context)
                : myDigitalClock(context),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        centerTitle: true,
      ),
      body: Container(
        //Theme.of(context).backgroundColor
        color: Colors.white,
        child: clockFormatSwitcher(),
      ),
    );
  }
}
