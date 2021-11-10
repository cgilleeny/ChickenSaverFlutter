import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../helpers/custom_material_color.dart';
// import '../models/alarm.dart';
import '../providers/alarms.dart';
import './sunset_offset_dialog.dart';

class SunsetOffsetSelector extends StatefulWidget {
  // final Alarm alarm;
  Function(int) callback;
  SunsetOffsetSelector(this.callback);

  @override
  _SunsetOffsetSelectorState createState() => _SunsetOffsetSelectorState();
}

class _SunsetOffsetSelectorState extends State<SunsetOffsetSelector> {
  final customMaterialColor = CustomMaterialColor();
  int? _offset;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    final alarms = Provider.of<Alarms>(context, listen: false);
    _offset = alarms.alarm?.offset;
  }

  String get offsetString {
    final offset = _offset;
    if (offset == null) {
      return '';
    }
    switch (offset) {
      case -60:
        return '1 hour before sunset';
      case -30:
        return '30 minutes before sunset';
      case 0:
        return 'Sunset';
      case 30:
        return '30 minutes after sunset';
      case 60:
        return '1 hour after sunset';
      default:
        return 'Sunset';
    }
  }

  Future<void> getOffset() async {
    final offset = _offset;
    if (offset == null) {
      return;
    }
    int result = await showDialog(
        context: context, builder: (ctx) => SunsetOffsetDialog(offset));
    setState(() {
      _offset = result;
    });
    widget.callback(result);
  }

  @override
  Widget build(BuildContext context) {
    final alarms = Provider.of<Alarms>(context, listen: true);
    if (_offset == null && alarms.alarm?.offset != null) {
      setState(() {
        _offset = alarms.alarm?.offset;
      });
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        children: [
          Text(
            'Alert Time',
            style: TextStyle(
              color: customMaterialColor.create(
                Color(0xFF0c3040),
              ),
              fontSize: 18,
              fontFamily: 'Noteworthy',
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          ListTile(
            title: Text(
              offsetString,
              style: TextStyle(
                color: customMaterialColor.create(
                  Color(0xFF0c3040),
                ),
                fontFamily: 'Noteworthy',
                fontWeight: FontWeight.bold,
              ),
            ),
            onTap: _offset == null ? null : getOffset,
            trailing: Icon(Icons.expand_more),
          ),
        ],
      ),
    );
  }
}
