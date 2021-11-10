import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../models/http_exception.dart';
import './register.dart';

enum AlertSound {
  clucking,
  crowing,
  system,
}

class Alarm {
  int? id;
  AlertSound alertSound;
  int offset;

  Alarm({
    this.alertSound = AlertSound.clucking,
    this.offset = 0,
    this.id,
  });
}

class Alarms with ChangeNotifier {
  // Alarm _alarm = Alarm();
  Alarm? _alarm;

  Alarm? get alarm {
    return _alarm;
  }

  // bool get isInitialized {
  //   return _isInitialized;
  // }

  set alarm(newAlarm) {
    _alarm = newAlarm;
  }

  // set isInitialized(value) {
  //   _isInitialized = value;
  // }

  String toSound(AlertSound alertSound) {
    switch (alertSound) {
      case AlertSound.clucking:
        return 'Clucking.wav';
      case AlertSound.crowing:
        return 'Crowing.wav';
      case AlertSound.system:
        return 'Default';
    }
  }

  AlertSound toAlertSound(String sound) {
    switch (sound) {
      case 'Clucking.wav':
        return AlertSound.clucking;
      case 'Crowing.wav':
        return AlertSound.crowing;
      case 'Default':
        return AlertSound.system;
      default:
        return AlertSound.clucking;
    }
  }

  Future<Alarm> getAlarm(String deviceuid) async {
    final url = Uri.parse('${HOST_URL}Alarms?deviceuid=$deviceuid');

    try {
      final response = await http.get(url);
      final extractedData = json.decode(response.body) as Map<String, dynamic>;

      final alarmsData = extractedData['alarms'] as List;
      final alarmData = alarmsData.first;
      _alarm = Alarm(
        id: alarmData['id'],
        offset: alarmData['offset'],
        alertSound: toAlertSound(
          alarmData['sound'],
        ),
      );
      notifyListeners();
      return _alarm!;
    } catch (error) {
      print(error);
      throw error;
    }
  }

  Future<Alarm> updateAlarm(
      int id, String deviceuid, int offset, AlertSound alertSound) async {
    // notifyListeners();
    final url = Uri.parse(
        '${HOST_URL}Alarms?id=$id&status=active&sound=${toSound(alertSound)}&offset=$offset&deviceuid=$deviceuid');
    print(url);
    try {
      final response = await http.post(
        url,
      );
      if (response.statusCode >= 400) {
        throw HttpException(
            'Could not insert the alarm: ${response.statusCode}.');
      }
      final responseData = json.decode(response.body);
      if (responseData['status'] == null) {
        throw HttpException(
          'Unexpected response',
        );
      }
      if (responseData['status'] != 'OK') {
        throw HttpException(
          responseData['status'],
        );
      }
      _alarm = Alarm(
        alertSound: alertSound,
        offset: offset,
        id: id,
      );
      return _alarm!;
    } catch (error) {
      print(error);
      throw error;
    }
  }

  Future<Alarm> insertAlarm(
      String deviceuid, int offset, AlertSound alertSound) async {
    // notifyListeners();
    final url = Uri.parse(
        '${HOST_URL}Alarms?status=active&sound=${toSound(alertSound)}&offset=$offset&deviceuid=$deviceuid');
    print(url);
    try {
      final response = await http.post(
        url,
      );
      if (response.statusCode >= 400) {
        throw HttpException(
            'Could not insert the alarm: ${response.statusCode}.');
      }
      final responseData = json.decode(response.body);
      if (responseData['status'] == null) {
        throw HttpException(
          'Unexpected response',
        );
      }
      if (responseData['status'] != 'OK') {
        throw HttpException(
          responseData['status'],
        );
      }
      if (responseData['result'] == null) {
        throw HttpException(
          'Expected alarm id but none received',
        );
      }
      // print(responseData['result']);
      _alarm = Alarm(
          id: responseData['result'], offset: offset, alertSound: alertSound);
      return _alarm!;
    } catch (error) {
      print(error);
      throw error;
    }
  }
}
