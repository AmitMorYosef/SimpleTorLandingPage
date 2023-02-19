import 'package:flutter/material.dart';

/// This file is saving the const of worker scedule
/// Example: save the holidays of the different religions

enum Religion { muslim, christian, jewish }

Map<Religion, String> religionToStr = {
  Religion.muslim: "muslim",
  Religion.christian: "christian",
  Religion.jewish: "jewish",
};

Map<String, Religion> religionFromStr = {
  "muslim": Religion.muslim,
  "christian": Religion.christian,
  "jewish": Religion.jewish,
};

/// Save the holidays here -
/// `jewish` - doesnt have fixed date - need every year declaration
/// `muslim` - doesnt have fixed date - need every year declaration
/// `christian` - are on the fixed date every year.
const Map<Religion, Map<String, String>> holidays = {
  Religion.christian: {
    "01-01-0000": "New Year's Day",
    "16-01-0000": "Martin Luther King Jr. Day",
    "20-02-0000": "Presidents' Day",
    "29-05-0000": "Memorial Day",
    "19-06-0000": "Juneteenth",
    "04-07-0000": "Independence Day",
    "04-09-0000": "Labor Day",
    "09-10-0000": "Columbus Day",
    "11-11-0000": "Veterans Day",
    "23-11-0000": "Thanksgiving Day",
    "25-12-0000": "Christmas Day"
  },
  Religion.jewish: {
    "06-04-2023": "Passover (Day 1)",
    "12-04-2023": "Passover (Day 7)",
    "26-04-2023": "Yom HaAtzmaut",
    "26-05-2023": "Shavuot",
    "16-09-2023": "Rosh Hashana",
    "17-09-2023": "Rosh Hashana (Day 2)",
    "25-09-2023": "Yom Kippur",
    "30-09-2023": "Sukkot",
    "07-10-2023": "Simchat Torah",
  },
  Religion.muslim: {
    //   [2023, 2, 22]: "Founding Day",
    //   [2023, 4, 22]: "Eid al-Fitr",
    //   [2023, 4, 23]: "Eid al-Fitr",
    //   [2023, 4, 24]: "Eid al-Fitr",
    //   [2023, 4, 25]: "Eid al-Fitr",
    //   [2023, 4, 11]: "Arafat Day",
    //   [2023, 4, 12]: "Eid al-Adha",
    //   [2023, 4, 26]: "Eid al-Adha Holiday",
    //   [2023, 5, 26]: "Eid al-Adha Holiday",
    //   [2023, 9, 16]: "Rosh Hashana",
    //   [2023, 6, 17]: "Rosh Hashana (Day 2)",
    //   [2023, 9, 24]: "Yom Kippur Eve",
    //   [2023, 9, 25]: "Yom Kippur",
    //   [2023, 9, 30]: "Sukkot (Day 1)",
    //   [2023, 10, 1]: "Sukkot (Day 2)",
    //   [2023, 10, 2]: "Sukkot (Day 3)",
    //   [2023, 10, 3]: "Sukkot (Day 4)",
    //   [2023, 10, 4]: "Sukkot (Day 5)",
    //   [2023, 10, 5]: "Sukkot (Day 6)",
    //   [2023, 10, 6]: "Sukkot (Day 7)",
    //   [2023, 10, 7]: "Simchat Torah",
  }
};

/// The optionals colors for the scedule split bookings
const sceduleColors = [
  Colors.pink,
  Colors.purple,
  Colors.yellow,
  Colors.brown,
  Colors.blueGrey,
  Colors.cyanAccent,
  Colors.deepOrange,
  Colors.lightGreen,
  Colors.blue,
];
// the days of the week
const weekDays = [
  '',
  'monday',
  'tuesday',
  'wednesday',
  'thursday',
  'friday',
  'saturday',
  'sunday'
];

enum EventTyps { block, freeTime }
