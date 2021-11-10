import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:provider/provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../helpers/custom_material_color.dart';
import '../providers/register.dart';

class CoopLocationSelector extends StatefulWidget {
  // Registration registration;
  Function(LatLng) callback;
  CoopLocationSelector(this.callback);

  @override
  _CoopLocationSelectorState createState() => _CoopLocationSelectorState();
}

class _CoopLocationSelectorState extends State<CoopLocationSelector> {
  LatLng? _latLng;
  // bool _gettingCurrentUserLocation = true;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    final register = Provider.of<Register>(context, listen: false);
    final registration = register.getRegistration;
    final latitude = registration.latitude;
    final longitude = registration.longitude;
    if (latitude == null || longitude == null) {
      _getCurrentUserLocation();
      return;
    }

    _latLng = new LatLng(latitude, longitude);
    widget.callback(_latLng!);
  }

  Future<void> _getCurrentUserLocation() async {
    LocationData locationData = await Location().getLocation();
    final latitude = locationData.latitude;
    final longitude = locationData.longitude;
    if (latitude == null || longitude == null) {
      return;
    }
    setState(() {
      // widget.registration.latitude = latitude;
      // widget.registration.longitude = longitude;

      _latLng = new LatLng(latitude, longitude);
      widget.callback(_latLng!);
    });
  }

  void _selectLocation(LatLng position) {
    setState(() {
      // widget.registration.latitude = position.latitude;
      // widget.registration.longitude = position.longitude;

      _latLng = new LatLng(position.latitude, position.longitude);
      widget.callback(_latLng!);
    });
  }

  @override
  Widget build(BuildContext context) {
    final customMaterialColor = CustomMaterialColor();

    return Expanded(
      child: Container(
        child: _latLng == null
            // _gettingCurrentUserLocation
            ? Center(
                child: Text('Loading...'),
              )
            : Stack(alignment: AlignmentDirectional.topCenter, children: [
                GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: _latLng!,
                    zoom: 16,
                  ),
                  onTap: _selectLocation,
                  markers: {
                    Marker(
                      markerId: MarkerId('m1'),
                      position: _latLng!,
                    ),
                  },
                ),
                Container(
                  margin: EdgeInsets.all(10),
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                      color: customMaterialColor.create(
                    Color(0xFFB9E4F6),
                  )),
                  child: Text(
                    'Coop Location',
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
                ),
              ]),
        // height: constraints.maxHeight / 2,
        width: double.infinity,
        color: customMaterialColor.create(
          Color(0xFFB9E4F6),
        ),
      ),
    );
  }
}
