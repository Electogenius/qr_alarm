// import 'package:alarm/alarm.dart';
import 'dart:convert';


import 'package:qr_alarm/editpage.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import 'package:file_selector/file_selector.dart';

class QRAlarm {
  int id;
  String type;
  bool enabled;
  List time;
  String qrValue;
  String payload;
  String assetAudioPath;
  QRAlarm({
    required this.id,
    required this.type,
    required this.enabled,
    required this.time,
    required this.qrValue,
    required this.payload,
    required this.assetAudioPath,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type,
      'enabled': enabled,
      'time': time,
      'qrValue': qrValue,
      'payload': payload,
      'assetAudioPath': assetAudioPath,
    };
  }

  static QRAlarm fromMap(Map<String, dynamic> map) {
    return QRAlarm(id: map['id'], type: map['type'], enabled: map['enabled'], time: map['time'], qrValue: map['qrValue'], payload: map['payload'], assetAudioPath: map['assetAudioPath']);
  }
}

List<QRAlarm> alarms = [
  // sample data
  QRAlarm(
    id: 1,
    type: 'one-time',
    enabled: true,
    time: [22, 30],
    qrValue: 'hello, mobilescanner!',
    payload: 'alammy',
    assetAudioPath: '',
  ),
  QRAlarm(
    id: 2,
    type: 'one-time',
    enabled: true,
    time: [22, 30],
    qrValue: 'hello, mobilescanner!',
    payload: 'sample text',
    assetAudioPath: '',
  ),
];

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final localStorage = await SharedPreferences.getInstance();
  // TODO: load alarm data
  if(localStorage.containsKey('qralarm-data')){
    alarms = localStorage.getStringList('qralarm-data')!.map((String str) => QRAlarm.fromMap(jsonDecode(str))).toList();
    print("reloaded data!");
  }
  runApp(const MainApp());
}

void saveAlarms() async {
  var localStorage = await SharedPreferences.getInstance();
  localStorage.setStringList('qralarm-data', alarms.map((QRAlarm alarm) => jsonEncode(alarm.toMap())).toList());
  print('saved!');
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: AlarmsPage(),
      theme: ThemeData.dark().copyWith(
        colorScheme: .fromSeed(seedColor: Colors.green),
      ),
      title: "QR Alarm",
    );
  }
}

class AlarmsPage extends StatelessWidget {
  const AlarmsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text("QR Alarm!"),
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Theme.of(context).colorScheme.onPrimary,
        ),
        body: Padding(
          padding: EdgeInsetsGeometry.all(25),
          child: Column(
            children: [
              Clock(),
              Column(
                children: List.generate(
                  alarms.length,
                  (x) => x,
                ).map<Widget>((x) => AlarmBit(x)).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class Clock extends StatefulWidget {
  const Clock({super.key});

  @override
  State<Clock> createState() => _ClockState();
}

class _ClockState extends State<Clock> {
  @override
  Widget build(BuildContext context) => StreamBuilder(
    stream: Stream.periodic(const Duration(milliseconds: 123)),
    builder: (BuildContext context, AsyncSnapshot<Object?> snapshot) =>
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey, width: 2),
            borderRadius: BorderRadius.circular(10),
          ),
          padding: EdgeInsets.all(20),
          child: Text(DateTime.now().toString()),
        ),
  );
}

class AlarmBit extends StatefulWidget {
  final int alarmIndex;
  const AlarmBit(this.alarmIndex, {super.key});

  @override
  State<AlarmBit> createState() => _AlarmBitState();
}

class _AlarmBitState extends State<AlarmBit> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsetsGeometry.all(10),
      child: ColoredBox(
        color: Colors.blue,
        child: Material(
          elevation: 10,
          child: ListTile(
            title: Text(
              alarms[widget.alarmIndex].time
                  .map((x) => x.toString().padLeft(2, '0'))
                  .join(':'),
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 40),
            ),
            tileColor: Theme.of(context).colorScheme.inversePrimary,
            trailing: Switch(
              value: alarms[widget.alarmIndex].enabled,
              onChanged: (value) {
                setState(() {
                  alarms[widget.alarmIndex].enabled = value;
                  saveAlarms();
                });
              },
            ),
            onTap: () {
              final int val = widget.alarmIndex;
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (BuildContext context) => EditPage(alarms[val]),
                ),
              ).then((_) {
                setState(() {/* state of switch may have changed after editing alarm */});
              });
            },
          ),
        ),
      ),
    );
  }
}
