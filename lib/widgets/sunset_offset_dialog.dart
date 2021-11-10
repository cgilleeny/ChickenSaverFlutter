import 'package:flutter/material.dart';

import '../helpers/custom_material_color.dart';
// import '../widgets/offset_selector.dart';

class SunsetOffsetDialog extends StatefulWidget {
  final int offset;

  SunsetOffsetDialog(this.offset);

  @override
  _SunsetOffsetDialogState createState() => _SunsetOffsetDialogState();
}

class _SunsetOffsetDialogState extends State<SunsetOffsetDialog> {
  int _offset = 0;

  int offsetIndex(offset) {
    switch (offset) {
      case -60:
        return 0;
      case -30:
        return 1;
      case 0:
        return 2;
      case 30:
        return 3;
      case 60:
        return 4;
      default:
        return 5;
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _offset = widget.offset;
  }

  @override
  Widget build(BuildContext context) {
    final customMaterialColor = CustomMaterialColor();

    return Dialog(
      child: Container(
        padding: EdgeInsets.only(top: 8, bottom: 8),
        color: customMaterialColor.create(
          Color(0xFFFFEDA3),
        ),
        // alignment: Alignment.center,
        child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              onPressed: () {
                Navigator.pop(context, widget.offset);
              },
              icon: Icon(Icons.close),
            ),
            Text(
              'Select Alert Time',
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
            IconButton(
              onPressed: () {
                Navigator.pop(context, _offset);
              },
              icon: Icon(Icons.check),
            ),
          ],
        ),
        RadioListTile(
          value: offsetIndex(-60),
          groupValue: offsetIndex(_offset),
          onChanged: (_) {
            setState(() {
              _offset = -60;
            });
          },
          title: Text(
            '1 hour before sunset',
            style: TextStyle(
              color: customMaterialColor.create(
                Color(0xFF0c3040),
              ),
              fontFamily: 'Noteworthy',
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        RadioListTile(
          value: offsetIndex(-30),
          groupValue: offsetIndex(_offset),
          onChanged: (_) {
            setState(() {
              _offset = -30;
            });
          },
          title: Text(
            '30 minutes before sunset',
            style: TextStyle(
              color: customMaterialColor.create(
                Color(0xFF0c3040),
              ),
              fontFamily: 'Noteworthy',
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        RadioListTile(
          value: offsetIndex(0),
          groupValue: offsetIndex(_offset),
          onChanged: (_) {
            setState(() {
              _offset = 0;
            });
          },
          title: Text(
            'Sunset',
            style: TextStyle(
              color: customMaterialColor.create(
                Color(0xFF0c3040),
              ),
              fontFamily: 'Noteworthy',
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        RadioListTile(
          value: offsetIndex(30),
          groupValue: offsetIndex(_offset),
          onChanged: (_) {
            setState(() {
              _offset = 30;
            });
          },
          title: Text(
            '30 minutes after sunset',
            style: TextStyle(
              color: customMaterialColor.create(
                Color(0xFF0c3040),
              ),
              fontFamily: 'Noteworthy',
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        RadioListTile(
          value: offsetIndex(60),
          groupValue: offsetIndex(_offset),
          onChanged: (_) {
            setState(() {
              _offset = 60;
            });
          },
          title: Text(
            '1 hour after sunset',
            style: TextStyle(
              color: customMaterialColor.create(
                Color(0xFF0c3040),
              ),
              fontFamily: 'Noteworthy',
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    ),
      ),
    );
  }
}
