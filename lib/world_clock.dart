import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';

import 'package:intl/intl.dart';
import 'package:http/http.dart';

import 'package:analog_clock/analog_clock.dart';
import 'package:concentric_transition/concentric_transition.dart';

import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

class WorldClock extends StatefulWidget {
  WorldClock({required this.title});

  final String title;

  @override
  _WorldClockState createState() => _WorldClockState();
}

class _WorldClockState extends State<WorldClock> {
  bool isDigital = true;

  DateTime chosenTime = DateTime.now();
  String chosenTimezone = '';
  List availableTimezones = [];
  String offset = '';

  List currentList = [];

  @override
  void initState() {
    initTimeZones();
    Timer.periodic(
      const Duration(
        seconds: 1,
      ),
      (Timer t) {
        timeCalcByLocation(chosenTimezone);
      },
    );
    super.initState();
  }

  void initTimeZones() async {
    Response response =
        await get(Uri.parse('http://worldtimeapi.org/api/timezone'));
    setState(() {
      availableTimezones = jsonDecode(response.body);
      availableTimezones.sort();
    });
    response = await get(Uri.parse('http://worldtimeapi.org/api/ip'));
    Map data = jsonDecode(response.body);
    setState(() {
      chosenTimezone = data["timezone"];
      chosenTime = DateTime.parse(data["datetime"]);
      offset = data["utc_offset"];
      if (offset[0] == '+') {
        chosenTime.add(Duration(seconds: data["raw_offset"]));
      } else if (offset[0] == '-') {
        chosenTime.subtract(Duration(seconds: data["raw_offset"]));
      }
    });
    // printDetails();
  }

  List filterList(String searchTerm) {
    return availableTimezones
        .where((element) => element.toLowerCase().contains(searchTerm))
        .toList();
  }

  Future chooseLocationSheet() {
    var search_controller = TextEditingController();
    currentList = availableTimezones;
    return showBarModalBottomSheet(
      context: context,
      builder: (c) => ListView.builder(
        itemCount: currentList.length + 1,
        itemBuilder: (context, index) => index == 0
            ? Container(
                margin: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: search_controller,
                  textInputAction: TextInputAction.search,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.search),
                    hintText: "Search",
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: search_controller.clear,
                    ),
                  ),
                  onChanged: (input) =>
                      setState(() => currentList = filterList(input)),
                  showCursor: true,
                ),
              )
            : Card(
                child: ListTile(
                  title: Text(
                    currentList[index - 1],
                    style: TextStyle(
                      fontWeight: chosenTimezone == currentList[index - 1]
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                  onTap: () {
                    // print("User chose ${availableTimezones[index]}");
                    timeCalcByLocation(currentList[index - 1]);
                    Navigator.pop(context);
                    // (context as Element).reassemble();
                  },
                ),
              ),
      ),
      enableDrag: true,
    );
  }

  Widget myAnalogClock(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Text(
            DateFormat('EEE, MMM d').format(chosenTime),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: MediaQuery.of(context).size.height / 30,
            ),
          ),
          AnalogClock(
            decoration: BoxDecoration(
              border: Border.all(
                width: 0.0,
                color: Colors.black,
              ),
              boxShadow: [
                BoxShadow(
                    blurRadius: 15,
                    spreadRadius: 2,
                    blurStyle: BlurStyle.outer,
                    color: Colors.black.withAlpha(80)),
              ],
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
        ],
      ),
    );
  }

  Widget myDigitalClock(BuildContext context) {
    return Center(
      child: Container(
        color: Colors.transparent,
        margin: const EdgeInsets.symmetric(horizontal: 10),
        width: MediaQuery.of(context).size.width / 1.5,
        height: MediaQuery.of(context).size.height / 2,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    DateFormat('h:mm').format(chosenTime),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: MediaQuery.of(context).size.height / 15,
                    ),
                  ),
                  Text(
                    DateFormat('ss').format(chosenTime),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: MediaQuery.of(context).size.height / 50,
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Text(
                    DateFormat('a').format(chosenTime),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: MediaQuery.of(context).size.height / 32,
                    ),
                  ),
                ],
              ),
              Text(
                DateFormat('EEE, MMM d').format(chosenTime),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: MediaQuery.of(context).size.height / 50,
                ),
              ),
            ],
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

  void timeCalcByLocation(String location) async {
    Response response =
        await get(Uri.parse('http://worldtimeapi.org/api/timezone/$location'));
    Map data = jsonDecode(response.body);
    setState(() {
      chosenTimezone = data["timezone"];
      chosenTime = DateTime.parse(data["datetime"]);
      offset = data["utc_offset"];
      if (offset[0] == '+') {
        chosenTime = chosenTime.add(Duration(seconds: data["raw_offset"]));
      } else if (offset[0] == '-') {
        chosenTime = chosenTime.subtract(Duration(seconds: data["raw_offset"]));
      }
    });
    // printDetails();
  }

  void printDetails() {
    print("DIGITAL CLOCK: $isDigital");
    print("TIME: $chosenTime");
    print("TIMEZONE: $chosenTimezone");
    print("OFFSET: $offset");
    print("====================");
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
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton.icon(
                icon: const Icon(
                  Icons.location_on,
                  color: Colors.black,
                ),
                onPressed: chooseLocationSheet,
                label: const Text(
                  "Choose Location",
                  style: TextStyle(
                    color: Colors.black,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                    primary: Colors.grey, onPrimary: Colors.black),
              ),
              Text(
                "Current Timezone: $chosenTimezone",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: MediaQuery.of(context).size.height / 47,
                ),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height / 47,
              ),
              Container(
                child: index % 2 == 0
                    ? myAnalogClock(context)
                    : myDigitalClock(context),
              ),
            ],
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
