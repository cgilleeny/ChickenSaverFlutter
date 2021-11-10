import 'dart:convert';
import 'dart:io';

import 'package:device_info/device_info.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/services.dart';

import '../helpers/device_info.dart';
import '../models/http_exception.dart';

// const HOST_URL = "https://IMAT.avalancheevantage.com/ChickenSaverService/";
const HOST_URL =
    "http://chickensaver-env.eba-hxg5scrn.us-west-2.elasticbeanstalk.com/";

class Registration {
  String? deviceuid;
  String? devicetoken;
  String? pushbadge;
  String? pushalert;
  String? pushsound;
  String? pushnetwork;
  double? latitude;
  double? longitude;
  String? deviceversion;
  String? appname;
  String? devicename;
  String? devicemodel;
  String? appversion;
  String? os;

  Registration(
      {this.deviceuid,
      this.devicetoken,
      this.pushbadge,
      this.pushalert,
      this.pushsound,
      this.pushnetwork,
      this.latitude,
      this.longitude,
      this.deviceversion,
      this.appname,
      this.devicename,
      this.devicemodel,
      this.appversion,
      this.os});
}

class Register with ChangeNotifier {
  bool? _isRegistered;
  Registration? _registration;
  String? _token;

  bool? get isRegistered {
    return _isRegistered;
  }

  Registration get getExtractedRegistration {
    return _registration!;
  }

  Registration get getRegistration {
    return _registration!;
  }

  double? get latitude {
    return _registration?.latitude;
  }

  double? get longitude {
    return _registration?.longitude;
  }

  String? get deviceuid {
    return _registration?.deviceuid;
  }

  set token(token) {
    _token = token;
    print('set token');
    final isRegistered = _isRegistered;
    if (isRegistered == null) {
      return;
    }
    print('set token isRegistered: $isRegistered');
    if (isRegistered) {
      final registration = _registration;
      if (registration == null) {
        return;
      }
      print('set token registration: $registration');
      final devicetoken = registration.devicetoken;
      if (devicetoken != token) {
        final latitude = registration.latitude;
        final longitude = registration.longitude;
        if (latitude == null || longitude == null) {
          return;
        }
        insertUpdateRegistration(LatLng(latitude, longitude));
      }
    }
  }

  // void updateLatLng(LatLng latLng) {
  //   _registration?.latitude = latLng.latitude;
  //   _registration?.longitude = latLng.longitude;
  // }

  Future<void> tryStoredRegistration() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('userData')) {
      _isRegistered = false;
      final _deviceuid = await DeviceInfo.getId();
      _registration = Registration(deviceuid: _deviceuid, devicetoken: _token);
      // notifyListeners();
      return;
    }
    final extractedUserData =
        json.decode(prefs.getString('userData')!) as Map<String, dynamic>;
    final deviceuid = extractedUserData['deviceuid'];
    if (deviceuid == null) {
      _isRegistered = false;
      final _deviceuid = await DeviceInfo.getId();
      _registration = Registration(deviceuid: _deviceuid, devicetoken: _token);
      return;
    }
    final devicetoken = extractedUserData['devicetoken'];
    final pushbadge = extractedUserData['pushbadge'];
    final pushalert = extractedUserData['pushalert'];
    final pushsound = extractedUserData['pushsound'];
    final pushnetwork = extractedUserData['pushnetwork'];
    final latitude = extractedUserData['latitude'];
    final longitude = extractedUserData['longitude'];

    if (devicetoken == null ||
        pushbadge == null ||
        pushalert == null ||
        pushsound == null ||
        pushnetwork == null ||
        latitude == null ||
        longitude == null) {
      _isRegistered = false;
      // final _deviceuid = await DeviceInfo.getId();
      _registration = Registration(deviceuid: deviceuid, devicetoken: _token);
      return;
    }
    final token = _token;
    _registration = Registration(
      deviceuid: deviceuid,
      devicetoken: _token != null ? _token : devicetoken,
      pushbadge: pushbadge,
      pushalert: pushalert,
      pushsound: pushsound,
      pushnetwork: pushnetwork,
      latitude: latitude,
      longitude: longitude,
      os: Platform.isIOS ? 'ios' : 'android',
    );

    _isRegistered = true;
    if (token == null) {
      return;
    }

    if (devicetoken != token) {
      print('devicetoken ($devicetoken) != _token ($_token)');
      final latitude = _registration?.latitude;
      final longitude = _registration?.longitude;
      if (latitude == null || longitude == null) {
        return;
      }
      await insertUpdateRegistration(LatLng(latitude, longitude));
      // await storeRegistration();
    }
    return;
  }

  Future<bool> storeRegistration() async {
    final prefs = await SharedPreferences.getInstance();
    final registration = _registration;
    if (registration == null) {
      return false;
    }

    final userData = json.encode({
      'deviceuid': registration.deviceuid,
      'devicetoken': registration.devicetoken,
      'pushbadge': registration.pushbadge,
      'pushalert': registration.pushalert,
      'pushsound': registration.pushsound,
      'pushnetwork': registration.pushnetwork,
      'latitude': registration.latitude,
      'longitude': registration.longitude,
    });
    return await prefs.setString('userData', userData);
  }

  // Future<bool> updateRegistration() async {
  //   final registration = _registration;
  //   if (registration == null) {
  //     return false;
  //   }
  //   final parameters =
  //       'appname=${registration.appname}&appversion=${registration.appversion}&deviceuid=${registration.deviceuid}&devicename=${registration.devicename}&devicetoken=${registration.devicetoken}&devicemodel=${registration.devicemodel}&deviceversion=${registration.deviceversion}&pushbadge=${registration.pushbadge}&pushalert=${registration.pushalert}&pushsound=${registration.pushsound}&pushnetwork=${registration.pushnetwork}&latitude=${registration.latitude}&longitude=${registration.longitude}&os=${registration.os}';
  //   print(parameters);
  //   final url = Uri.parse('${HOST_URL}Register?$parameters');
  //   print(url);
  //   try {
  //     final response = await http.post(
  //       url,
  //     );
  //     if (response.statusCode >= 400) {
  //       throw HttpException(
  //           'Could not update the APNS device: ${response.statusCode}.');
  //     }
  //     final responseData = json.decode(response.body);
  //     if (responseData['status'] == null) {
  //       throw HttpException(
  //         'Unexpected response',
  //       );
  //     }
  //     if (responseData['status'] != 'OK') {
  //       throw HttpException(
  //         responseData['status'],
  //       );
  //     }
  //     final storedOk = await storeRegistration();
  //     if (!storedOk) {
  //       throw HttpException(
  //         'Error storing the device info to local storage',
  //       );
  //     }
  //     return true;
  //   } catch (error) {
  //     print(error);
  //     throw error;
  //   }
  // }

  Future<Registration> insertUpdateRegistration(LatLng latLng) async {
    final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();

    try {
      final packageInfo = await PackageInfo.fromPlatform();
      if (Platform.isAndroid) {
        AndroidDeviceInfo androidDeviceInfo =
            await deviceInfoPlugin.androidInfo;
        _registration = Registration(
          devicetoken: _token,
          deviceuid: androidDeviceInfo.androidId,
          deviceversion:
              '${androidDeviceInfo.version.release} (SDK ${androidDeviceInfo.version.sdkInt})',
          devicemodel:
              '${androidDeviceInfo.manufacturer} ${androidDeviceInfo.model}',
          pushnetwork: 'sandbox',
          pushbadge: 'enabled',
          pushsound: 'enabled',
          pushalert: 'enabled',
          appversion:
              '${packageInfo.version} (build ${packageInfo.buildNumber})',
          appname: packageInfo.appName,
          latitude: latLng.latitude,
          longitude: latLng.longitude,
          os: 'android',
        );
      } else if (Platform.isIOS) {
        IosDeviceInfo iosDeviceInfo = await deviceInfoPlugin.iosInfo;
        _registration = Registration(
          devicetoken: _token,
          deviceuid: iosDeviceInfo.identifierForVendor,
          deviceversion: iosDeviceInfo.systemVersion,
          devicemodel: iosDeviceInfo.name,
          pushnetwork: 'sandbox',
          pushbadge: 'enabled',
          pushsound: 'enabled',
          pushalert: 'enabled',
          appversion:
              '${packageInfo.version} (build ${packageInfo.buildNumber})',
          appname: packageInfo.appName,
          latitude: latLng.latitude,
          longitude: latLng.longitude,
          os: 'ios',
        );
      }
    } on PlatformException {
      throw HttpException(
        'Platform exception',
      );
    }
    final registration = _registration;
    if (registration == null) {
      throw HttpException(
        'Failed to initialize registration object',
      );
    }
    final parameters =
        'appname=${registration.appname}&appversion=${registration.appversion}&deviceuid=${registration.deviceuid}&devicename=${registration.devicename}&devicetoken=${registration.devicetoken}&devicemodel=${registration.devicemodel}&deviceversion=${registration.deviceversion}&pushbadge=${registration.pushbadge}&pushalert=${registration.pushalert}&pushsound=${registration.pushsound}&pushnetwork=${registration.pushnetwork}&latitude=${registration.latitude}&longitude=${registration.longitude}&os=${registration.os}';
    print(parameters);
    final url = Uri.parse('${HOST_URL}Register?$parameters');
    print(url);
    try {
      final response = await http.post(
        url,
      );
      if (response.statusCode >= 400) {
        throw HttpException(
            'Could not insert the APNS device: ${response.statusCode}.');
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
      final storedOk = await storeRegistration();
      if (!storedOk) {
        throw HttpException(
          'Error storing the device info to local storage',
        );
      }
      return _registration!;
    } catch (error) {
      print(error);
      throw error;
    }
  }

//   Future<void> getRegistration() async {
//     final url = Uri.parse('${HOST_URL}Register?deviceid=$_deviceId');
//     try {
//       final response = await http.get(
//         url,
//       );
//       final responseData = json.decode(response.body);
//       if (responseData['status'] == null) {
//         throw HttpException(
//           'Unexpected response',
//         );
//       }
//       if (responseData['status'] != 'OK') {
//         throw HttpException(
//           responseData['status'],
//         );
//       }
//       if (responseData['deviceInfo'] == null) {
//         throw HttpException(
//           'Error: Response did not include device information',
//         );
//       }
//       _registration = Registration(
//         deviceuid: responseData['deviceInfo']['deviceuid'],
//         devicetoken: responseData['deviceInfo']['devicetoken'],
//         pushbadge: responseData['deviceInfo']['pushbadge'],
//         pushalert: responseData['deviceInfo']['pushalert'],
//         pushsound: responseData['deviceInfo']['pushsound'],
//         pushnetwork: responseData['deviceInfo']['pushnetwork'],
//         latitude: responseData['deviceInfo']['latitude'],
//         longitude: responseData['deviceInfo']['longitude'],
//       );
//       // _deviceId = responseData['idToken'];
//       // _token = responseData['idToken'];
//       // _userId = responseData['localId'];

//       notifyListeners();
//       final prefs = await SharedPreferences.getInstance();
//       final userData = json.encode({
//         'deviceid': _deviceId,
//       });
//       await prefs.setString('userData', userData);
//     } catch (error) {
//       throw (error);
//     }
//   }

}
