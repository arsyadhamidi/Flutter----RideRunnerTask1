import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

class MapBoxPage extends StatefulWidget {
  const MapBoxPage({Key? key}) : super(key: key);

  @override
  State<MapBoxPage> createState() => _MapBoxPageState();
}

class _MapBoxPageState extends State<MapBoxPage> {

  late LatLng myPosition = LatLng(-0.914231, 100.466137);
  final MapController mapController = MapController();

  void getCurrentLocation() async{
    Position position = await Geolocator.getCurrentPosition();
    myPosition = LatLng(position.latitude, position.longitude);
  }

  String strLatlong = "Belum mendapatkan lat dan long";
  String currentAddress = 'Search lokasi Anda';
  Position _currentPosition = Position(
      longitude: 0,
      latitude: 0,
      timestamp: null,
      accuracy: 0,
      altitude: 0,
      heading: 0,
      speed: 0,
      speedAccuracy: 0);

  //getLatLong
  Future<Position> _getGeolocationPosition() async{
    bool serviceEnable;
    LocationPermission permission;

    serviceEnable = await Geolocator.isLocationServiceEnabled();

    if(serviceEnable){
      await Geolocator.openLocationSettings();
      return Future.error("Location service not enable");
    }

    permission = await Geolocator.checkPermission();

    if(permission == LocationPermission.denied){
      permission = await Geolocator.requestPermission();
      if(permission == LocationPermission.denied){
        return Future.error("Location permission denied");
      }
    }

    if(permission == LocationPermission.deniedForever){
      return Future.error(
          "Location permission denied forever, we cannot access"
      );
    }

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy:  LocationAccuracy.high
    );
    try{
      List<Placemark> placemarks =
      await placemarkFromCoordinates(position.latitude, position.longitude);
      print(placemarks);
      Placemark place = placemarks[0];
      setState(() {
        _currentPosition = position;
        strLatlong = "${place.locality}, ${place.country}";
        currentAddress = '${place.street}, ${place.subLocality}, ${place.locality}, '
            '${place.postalCode}, ${place.country}';
      });
    }catch(exp){
      print(exp);
    }

    return position;

}

@override
  void initState() {
    getCurrentLocation();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          FlutterMap(
            mapController: mapController,
            options: MapOptions(
              center: LatLng(-0.914231, 100.466137),
              zoom: 9.2,
            ),
            nonRotatedChildren: [
              AttributionWidget.defaultWidget(
                source: 'OpenStreetMap contributors',
                onSourceTapped: null,
              ),
            ],
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.app',
                additionalOptions: {
                  'id': 'mapbox/streets-v12',
                  'accessToken': 'pk.eyJ1IjoiZHppa3J1bDE2MTYiLCJhIjoiY2xleWJ6aTdlMGc0ODQxcXZsaDZlaDhwciJ9.Nz95V3UL1b8AfExigWUllA'
                },
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(30),
            child: TextFormField(
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.location_on_outlined),
                suffixIcon: IconButton(
                    onPressed: (){
                      _getGeolocationPosition();
                    },
                    icon: Icon(Icons.gps_fixed)
                ),
                filled: true,
                fillColor: Colors.white
              ),
            ),
          ),
          Padding(
              padding: EdgeInsets.only(top: 80, left: 25, right: 25),
            child: Container(
              height: MediaQuery.of(context).size.height / 6,
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(5),
                  child: ListTile(
                    leading: Icon(Icons.location_on),
                    title: Text(currentAddress),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _currentPosition != null
                            ? Text('latitude: ' + _currentPosition.latitude.toString())
                            : Text(''),
                        _currentPosition != null
                            ? Text("longitude :" + _currentPosition.longitude.toString())
                            : Text(''),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          )
        ]
      ),
    );
  }
}
