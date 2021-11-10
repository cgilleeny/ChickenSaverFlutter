import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import '../helpers/custom_material_color.dart';

import '../providers/alarms.dart';
import '../providers/register.dart';
import '../widgets/sound_selector.dart';
import '../widgets/sunset_offset_selector.dart';
import '../widgets/coop_location_selector.dart';

class SunsetAlertScreen extends StatefulWidget {
  SunsetAlertScreen();

  @override
  _SunsetAlertScreenState createState() => _SunsetAlertScreenState();
}

class _SunsetAlertScreenState extends State<SunsetAlertScreen> {
  final customMaterialColor = CustomMaterialColor();
  late FirebaseMessaging messaging;
  LatLng? _latLng;
  Alarm? _alarm;

  // late AlertSound _alertSound;
  // late int _offset;

  coopLocationCallback(latLng) {
    _latLng = latLng;
  }

  offsetSelectorCallback(offset) {
    _alarm?.offset = offset;
  }

  soundSelectorCallback(alertSound) {
    _alarm?.alertSound = alertSound;
  }

  void initAlarm() async {
    var register = Provider.of<Register>(context, listen: false);
    final alarms = Provider.of<Alarms>(context, listen: false);
    final isRegistered = register.isRegistered;

    if (isRegistered == null) {
      _alarm = new Alarm();
      return;
    }

    if (!isRegistered) {
      _alarm = new Alarm();
      return;
    }

    final deviceuid = register.deviceuid;
    if (deviceuid == null) {
      _alarm = new Alarm();
      return;
    }

    final newAlarm = await alarms.getAlarm(deviceuid);

    setState(() {
      _alarm = Alarm(
        alertSound: newAlarm.alertSound,
        offset: newAlarm.offset,
        id: newAlarm.id,
      );
    });
  }

  @override
  void initState() {
    super.initState();
    messaging = FirebaseMessaging.instance;
    if (Platform.isIOS) {
      messaging
          .requestPermission(
            alert: true,
            badge: true,
            sound: true,
            announcement: true,
            carPlay: true,
            criticalAlert: true,
            provisional: false,
          )
          .then((settings) => {
                if (settings.authorizationStatus ==
                    AuthorizationStatus.authorized)
                  {
                    messaging.getAPNSToken().then((value) {
                      print("ios token recieved");
                      print(value);
                      var register =
                          Provider.of<Register>(context, listen: false);
                      register.token = value;
                    })
                  }
              });
    } else {
      messaging.getToken().then((value) {
        print("android token recieved");
        print(value);
        // _token = value;
        var register = Provider.of<Register>(context, listen: false);
        register.token = value;
      });
    }

    FirebaseMessaging.onMessage.listen((RemoteMessage event) {
      print("message recieved");
      print(event.notification!.body);
    });
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      print('Message clicked!');
    });
    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
      print("newToken: $newToken");
      var register = Provider.of<Register>(context, listen: false);
      register.token = newToken;
    });

    initAlarm();
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          'An Error Occured!',
        ),
        content: Text(
          message,
        ),
        actions: <Widget>[
          FlatButton(
            onPressed: () {
              Navigator.of(ctx).pop();
            },
            child: Text('Okay'),
          )
        ],
      ),
    );
  }

  Future<void> onPressed(BuildContext console) async {
    final alarms = Provider.of<Alarms>(context, listen: false);
    final register = Provider.of<Register>(context, listen: false);
    try {
      final isRegistered = register.isRegistered;
      if (isRegistered == null) {
        _showErrorDialog('Error: expected isRegisred to have non null value');
        return;
      }

      if (isRegistered) {
        print('update if here');
        // final registration = register.getRegistration;

        final deviceuid = register.deviceuid;
        if (deviceuid == null) {
          _showErrorDialog('Error: expected deviceuid to have non null value');
          return;
        }

        final offset = _alarm?.offset;
        final alertSound = _alarm?.alertSound;
        if (offset == null || alertSound == null) {
          _showErrorDialog(
              'Error: expected alarm offset & sound to have non null value');
          return;
        }

        final id = _alarm?.id;
        // final alarm = alarms.alarm;
        if (id == null) {
          final newAlarm =
              await alarms.insertAlarm(deviceuid, offset, alertSound);
          setState(() {
            _alarm = newAlarm;
          });
        } else {
          final oldOffset = alarms.alarm?.offset;
          final oldAlertSound = alarms.alarm?.alertSound;

          if (oldOffset == null || oldAlertSound == null) {
            final newAlarm =
                await alarms.updateAlarm(id, deviceuid, offset, alertSound);
            setState(() {
              _alarm = newAlarm;
            });
          } else if (oldOffset != offset || oldAlertSound != alertSound) {
            final newAlarm =
                await alarms.updateAlarm(id, deviceuid, offset, alertSound);
            setState(() {
              _alarm = newAlarm;
            });
          }
        }

        final latLng = _latLng;
        if (latLng == null) {
          return;
        }
        final devicelatitude = register.latitude;
        final devicelongitude = register.longitude;
        if (devicelongitude == null || devicelatitude == null) {
          register.insertUpdateRegistration(latLng);
        }
        if (devicelongitude == latLng.longitude &&
            devicelatitude == latLng.latitude) {
          return;
        }
        register.insertUpdateRegistration(latLng);
      } else {
        final latLng = _latLng;
        if (latLng == null) {
          _showErrorDialog(
              'Error: expected latitude & longitude to have non null value');
          return;
        }
        await register.insertUpdateRegistration(latLng);
        final deviceuid = register.deviceuid;
        if (deviceuid == null) {
          _showErrorDialog('Error: expected deviceuid to have non null value');
          return;
        }
        final offset = _alarm?.offset;
        final alertSound = _alarm?.alertSound;
        if (offset == null || alertSound == null) {
          _showErrorDialog(
              'Error: expected alarm offset & sound to have non null value');
          return;
        }
        final newAlarm =
            await alarms.insertAlarm(deviceuid, offset, alertSound);
        setState(() {
          _alarm = newAlarm;
        });
      }
      final storedOk = await register.storeRegistration();
      if (!storedOk) {
        _showErrorDialog(
            'Error: unable to store registration data in app memory');
        return;
      }
    } catch (error) {
      _showErrorDialog(error.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    print('Build');
    // final alarms = Provider.of<Alarms>(context, listen: true);
    // final register = Provider.of<Register>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Sunset Alert',
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () async {
              // ignore: unnecessary_statements
              _alarm == null ? null : await onPressed(context);
            },
            //   try {
            //     bool? isRegistered = register.isRegistered;
            //     if (isRegistered == null) {
            //       _showErrorDialog(
            //           'Error: expected isRegisred to have non null value');
            //       return;
            //     }
            //     var registration = register.getRegistration;
            //     if (isRegistered) {
            //       print('update if here');
            //       // final registration = register.getRegistration;
            //       final id = _alarm.id;
            //       final deviceuid = registration.deviceuid;
            //       if (deviceuid == null || id == null) {
            //         _showErrorDialog(
            //             'Error: expected deviceuid and alarm id to have non null value');
            //         return;
            //       }
            //       final alarm = alarms.alarm;
            //       if (alarm.offset != _alarm.offset ||
            //           alarm.alertSound != _alarm.alertSound) {
            //         await alarms.updateAlarm(
            //             id, deviceuid, _alarm.offset, _alarm.alertSound);
            //       }

            //       final latLng = _latLng;
            //       if (latLng == null) {
            //         return;
            //       }
            //       final devicelatitude = register.latitude;
            //       final devicelongitude = register.longitude;
            //       if (devicelongitude != null &&
            //           devicelatitude != null &&
            //           devicelongitude == latLng.longitude &&
            //           devicelatitude == latLng.latitude) {
            //         return;
            //       }
            //       // register.updateLatLng(latLng);
            //       register.insertUpdateRegistration(latLng);
            //     } else {
            //       final latLng = _latLng;
            //       if (latLng == null) {
            //         _showErrorDialog(
            //             'Error: expected latitude & longitude to have non null value');
            //         return;
            //       }
            //       await register.insertUpdateRegistration(latLng);
            //       final deviceuid = register.deviceuid;
            //       if (deviceuid == null) {
            //         _showErrorDialog(
            //             'Error: expected deviceuid to have non null value');
            //         return;
            //       }
            //       final alarm = await alarms.insertAlarm(
            //           deviceuid, _alarm.offset, _alarm.alertSound);
            //       setState(() {
            //         _alarm = alarm;
            //       });
            //     }
            //     final storedOk = await register.storeRegistration();
            //     if (!storedOk) {
            //       _showErrorDialog(
            //           'Error: unable to store registration data in app memory');
            //       return;
            //     }
            //   } catch (error) {
            //     _showErrorDialog(error.toString());
            //   }
            // },
            child: _alarm?.id == null ? Text('Save') : Text('Update'),
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          return Container(
            height: constraints.maxHeight,
            width: double.infinity,
            child: Column(
              children: [
                CoopLocationSelector(coopLocationCallback),
                Container(
                  child: SoundSelector(soundSelectorCallback),
                  // height: constraints.maxHeight * 1 / 3,
                  width: double.infinity,
                  color: customMaterialColor.create(
                    Color(0xFFFFEDA3),
                  ),
                ),
                // Divider(),
                Container(
                  child: SunsetOffsetSelector(offsetSelectorCallback),
                  width: double.infinity,
                  color: customMaterialColor.create(
                    Color(0xFFB9E4F6),
                  ),
                )
              ],
            ),
          );
        },
      ),
    );
  }
}
