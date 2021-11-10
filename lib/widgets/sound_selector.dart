import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:provider/provider.dart';

import '../helpers/custom_material_color.dart';
// import '../models/alarm.dart';
import '../providers/alarms.dart';

class SoundSelector extends StatefulWidget {
  // final Alarm alarm;
  Function(AlertSound) callback;
  SoundSelector(this.callback);

  @override
  _SoundSelectorState createState() => _SoundSelectorState();
}

class _SoundSelectorState extends State<SoundSelector> {
  final customMaterialColor = CustomMaterialColor();
  AlertSound? _alertSound;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    final alarms = Provider.of<Alarms>(context, listen: false);

    _alertSound = alarms.alarm?.alertSound;
  }

  Future<AudioPlayer> playLocalAsset(String sound) async {
    AudioCache cache = new AudioCache();
    //At the next line, DO NOT pass the entire reference such as assets/yes.mp3. This will not work.
    print('playing: $sound');
    return await cache.play('$sound');
  }

  @override
  Widget build(BuildContext context) {
    final alarms = Provider.of<Alarms>(context, listen: true);
    if (_alertSound == null && alarms.alarm?.alertSound != null) {
      setState(() {
        _alertSound = alarms.alarm?.alertSound;
      });
    }
    return Column(
      children: [
        Text(
          'Alert Sound',
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
        RadioListTile(
          value: AlertSound.clucking.index,
          groupValue: _alertSound?.index,
          onChanged: (_) {
            widget.callback(AlertSound.clucking);
            setState(() {
              _alertSound = AlertSound.clucking;
            });
            // _value = true;
          },
          title: Text(
            'Clucking',
            style: TextStyle(
              color: customMaterialColor.create(
                Color(0xFF0c3040),
              ),
              fontFamily: 'Noteworthy',
              fontWeight: FontWeight.bold,
            ),
          ),
          secondary: IconButton(
            icon: Icon(Icons.play_arrow_outlined),
            onPressed: () async {
              AudioPlayer audioPlayer = await playLocalAsset('Clucking.wav');
              print(audioPlayer);
            },
          ),
        ),
        RadioListTile(
          value: AlertSound.crowing.index,
          groupValue: _alertSound?.index,
          onChanged: (_) {
            widget.callback(AlertSound.crowing);
            setState(() {
              _alertSound = AlertSound.crowing;
            });
            // _value = true;
          },
          title: Text(
            'Crowing',
            style: TextStyle(
              color: customMaterialColor.create(
                Color(0xFF0c3040),
              ),
              fontFamily: 'Noteworthy',
              fontWeight: FontWeight.bold,
            ),
          ),
          secondary: IconButton(
            icon: Icon(Icons.play_arrow_outlined),
            onPressed: () {
              playLocalAsset('Crowing.wav');
            },
          ),
        ),
        RadioListTile(
          value: AlertSound.system.index,
          groupValue: _alertSound?.index,
          onChanged: (_) {
            widget.callback(AlertSound.system);
            setState(() {
              _alertSound = AlertSound.system;
            });
          },
          title: Text(
            'Default Notification Sound',
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
    );
  }
}
