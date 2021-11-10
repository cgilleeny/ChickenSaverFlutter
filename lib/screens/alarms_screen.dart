import 'package:flutter/material.dart';
import 'package:flutter_picker/flutter_picker.dart';

import '../helpers/custom_material_color.dart';
// import '../models/registration.dart';
import '../providers/register.dart';
import '../providers/alarms.dart';

// ignore: must_be_immutable
class AlarmsScreen extends StatefulWidget {
  Registration registration;
  Alarm? alarm;

  AlarmsScreen({required this.registration, this.alarm});

  @override
  State<AlarmsScreen> createState() => _AlarmsScreenState();
}

class _AlarmsScreenState extends State<AlarmsScreen> {
  final customMaterialColor = CustomMaterialColor();
  Future<void> _saveAlarm() async {}

  final appBar = AppBar(
    title: Text(
      'Sunset Alert',
    ),
    actions: <Widget>[
      TextButton(
        onPressed: () {},
        child: Text('Save'),
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    // final deviceSize = MediaQuery.of(context).size;
    return Scaffold(
      appBar: appBar,
      body: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          return Column(
            children: [
              Container(
                height: constraints.maxHeight / 2,
                width: double.infinity,
                color: customMaterialColor.create(
                  Color(0xFFB9E4F6),
                ),
              ),
              Container(
                height: constraints.maxHeight / 2,
                width: double.infinity,
                color: customMaterialColor.create(
                  Color(0xFFFFEDA3),
                ),
              )
            ],
          );
        },
      ),
    );
  }
}
