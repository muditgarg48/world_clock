import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:analog_clock/analog_clock.dart';


class MyHomePage extends StatefulWidget {
  MyHomePage({required this.title});

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String _timeString = "";
  DateTime chosenTime = DateTime.now();

  @override
  void initState() {
    _timeString = _formatDateTime(DateTime.now());
    Timer.periodic(
      const Duration(
        seconds: 1,
      ),
      (Timer t) {
        _getTime();
      },
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Container(
        //Theme.of(context).backgroundColor
        color: Colors.white,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              AnalogClock(
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
                width: MediaQuery.of(context).size.width / 2,
                height: MediaQuery.of(context).size.height / 2,
                isLive: true,
                hourHandColor: Colors.black,
                minuteHandColor: Colors.black,
                showSecondHand: true,
                numberColor: Colors.black87,
                showNumbers: true,
                textScaleFactor: 1.4,
                showTicks: true,
                showDigitalClock: true,
                datetime: chosenTime,
              ),
              Text(_timeString),
            ],
          ),
        ),
      ),
    );
  }

  void _getTime() {
    setState(() {
      chosenTime = DateTime.now();
    });
    final String formattedDateTime = _formatDateTime(chosenTime);
    setState(() {
      _timeString = formattedDateTime;
    });
  }

  String _formatDateTime(DateTime dateTime) {
    return DateFormat('MM/dd/yyyy hh:mm:ss').format(dateTime);
  }
}