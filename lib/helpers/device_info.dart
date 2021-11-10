import 'dart:convert';
import 'dart:io';
// import 'package:flutter/material.dart';

import 'package:device_info/device_info.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';

// import '../models/registration.dart';
import '../providers/register.dart';

class DeviceInfo {


  static Future<String?> getId() async {
    final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
    try {
      if (Platform.isAndroid) {
        AndroidDeviceInfo androidDeviceInfo =
            await deviceInfoPlugin.androidInfo;
        return androidDeviceInfo.androidId;
      } else if (Platform.isIOS) {
        IosDeviceInfo iosDeviceInfo = await deviceInfoPlugin.iosInfo;
        return iosDeviceInfo.identifierForVendor;
      }
      return null;
    } on PlatformException {
      return null;
    }
  }

  static Future<String?> getStoredId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('userData')) {
      return null;
    }
    final extractedUserData =
        json.decode(prefs.getString('userData')!) as Map<String, dynamic>;
    return extractedUserData['deviceId'];
  }

  static Future<Registration?> getStoredRegistration() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('userData')) {
      return null;
    }
    final extractedUserData =
        json.decode(prefs.getString('userData')!) as Map<String, dynamic>;
    if (extractedUserData['deviceuid'] == null ||
        extractedUserData['devicetoken'] == null ||
        extractedUserData['pushbadge'] == null ||
        extractedUserData['pushalert'] == null ||
        extractedUserData['pushsound'] == null ||
        extractedUserData['pushnetwork'] == null ||
        extractedUserData['latitude'] == null ||
        extractedUserData['longitude'] == null) {
      return null;
    }
    return Registration(
      deviceuid: extractedUserData['deviceuid'],
      devicetoken: extractedUserData['devicetoken'],
      pushbadge: extractedUserData['pushbadge'],
      pushalert: extractedUserData['pushalert'],
      pushsound: extractedUserData['pushsound'],
      pushnetwork: extractedUserData['pushnetwork'],
      latitude: extractedUserData['latitude'],
      longitude: extractedUserData['longitude'],
    );
  }

  Future<bool> storeId(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final userData = json.encode({
      'deviceId': id,
    });
    return await prefs.setString('usrData', userData);
  }
}
