import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_alarm/main.dart';

int dealWith(String value, int lower, int upper) {
  /// Converts inputted text value into integer in useless creative ways
  int? attempt = int.tryParse(value) ?? 0;
  return attempt >= lower && attempt < upper ? attempt : attempt % upper;
}

class EditPage extends StatefulWidget {
  final QRAlarm alarm;
  const EditPage(this.alarm, {super.key});

  @override
  State<StatefulWidget> createState() => _EditPageState();
}

class _EditPageState extends State<EditPage> {
  @override
  Widget build(BuildContext context) {
    QRAlarm alarm = widget.alarm;
    return Scaffold(
      body: Padding(
        padding: EdgeInsetsGeometry.all(30),
        child: ListView(
          children: [
            const Text("Alarm Time (24h):"),
            Row(
              spacing: 30,
              children: [
                Expanded(
                  child: TextFormField(
                    initialValue: alarm.time[0].toString(),
                    style: const TextStyle(fontSize: 70),
                    textAlign: .center,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    onChanged: (value) => setState(() {
                      alarm.time[0] = dealWith(value, 0, 24);
                    }),
                    selectAllOnFocus: true,
                  ),
                ),
                Text(":", style: TextStyle(fontSize: 70)),
                Expanded(
                  child: TextFormField(
                    initialValue: alarm.time[1].toString(),
                    style: const TextStyle(fontSize: 70),
                    textAlign: .center,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    onChanged: (value) => setState(() {
                      alarm.time[1] = dealWith(value, 0, 60);
                    }),
                    selectAllOnFocus: true,
                  ),
                ),
              ],
            ),
            Switch(
              value: alarm.enabled,
              onChanged: (bool value) {
                setState(() {
                  alarm.enabled = value;
                });
              },
            ),
            TextFormField(
              initialValue: alarm.qrValue,
              decoration: InputDecoration(
                label: const Text("QR Value"),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) => setState(() {
                alarm.qrValue = value;
              }),
            ),
            Padding(
              padding: EdgeInsetsGeometry.all(30),
              child: ElevatedButton(
              onPressed: () {
                saveAlarms();
                Navigator.pop(context);
              },
              child: Text("Save and Exit"),
            )),
          ],
        ),
      ),
    );
  }
}
