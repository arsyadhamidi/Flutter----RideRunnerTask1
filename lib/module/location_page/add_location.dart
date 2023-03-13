import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';

class AddLocationPage extends StatefulWidget {
  const AddLocationPage({Key? key}) : super(key: key);

  @override
  State<AddLocationPage> createState() => _AddLocationPageState();
}

class _AddLocationPageState extends State<AddLocationPage> {
  File? _imgFile;
  final picker = ImagePicker();
  TextEditingController _nameLocation = TextEditingController();
  TextEditingController _latitude = TextEditingController();
  TextEditingController _longitude = TextEditingController();

  Future<void> pilihGambar() async {
    try {
      var image = await picker.pickImage(source: ImageSource.gallery);
      setState(() {
        _imgFile = File(image!.path);
      });
    } catch (exp) {
      print(exp);
    }
  }

  Future<void> pilihKamera() async {
    try {
      var image = await picker.pickImage(source: ImageSource.camera);
      setState(() {
        _imgFile = File(image!.path);
      });
    } catch (exp) {
      print(exp);
    }
  }

  Future<void> pilihJalur() async {
    try {
      var jalur = showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Upload Gambar"),
            content: Container(
              height: 100,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextButton(
                      onPressed: () {
                        pilihKamera();
                      },
                      child: Row(
                        children: [
                          Icon(
                            Icons.camera,
                            color: Colors.black,
                          ),
                          SizedBox(width: 10),
                          Text(
                            "Camera",
                            style: TextStyle(color: Colors.black),
                          ),
                        ],
                      )),
                  TextButton(
                      onPressed: () {
                        pilihGambar();
                      },
                      child: Row(
                        children: [
                          Icon(
                            Icons.photo,
                            color: Colors.black,
                          ),
                          SizedBox(width: 10),
                          Text(
                            "Gallery",
                            style: TextStyle(color: Colors.black),
                          ),
                        ],
                      )),
                ],
              ),
            ),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text("Kembali")),
            ],
          );
        },
      );
    } catch (e) {}
  }

  Position _currentPosition = Position(
      longitude: 0,
      latitude: 0,
      timestamp: null,
      accuracy: 0,
      altitude: 0,
      heading: 0,
      speed: 0,
      speedAccuracy: 0);

  Future<Position> _getGeolocationPosition() async {
    bool serviceEnable;
    LocationPermission permission;

    serviceEnable = await Geolocator.isLocationServiceEnabled();

    if (serviceEnable) {
      await Geolocator.openLocationSettings();
      return Future.error("Location service not enable");
    }

    permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error("Location permission denied");
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          "Location permission denied forever, we cannot access");
    }

    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    try {
      List<Placemark> placemarks =
          await placemarkFromCoordinates(position.latitude, position.longitude);
      print(placemarks);
      Placemark place = placemarks[0];
      setState(() {
        _currentPosition = position;
        _nameLocation.text = "${place.street} "
            "${place.subLocality} "
            "${place.locality} "
            "${place.administrativeArea} "
            "${place.country} "
            "${place.postalCode}";
        _latitude.text = _currentPosition.latitude.toString();
        _longitude.text = _currentPosition.longitude.toString();
      });
    } catch (exp) {
      print(exp);
    }

    return position;
  }

  @override
  void initState() {
    _getGeolocationPosition();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var placeholder = DottedBorder(
        color: Colors.grey,
        borderType: BorderType.RRect,
        radius: Radius.circular(20),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.grey.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          height: 250,
          child: Center(
            child: Image.asset("assets/images/upload-gambar.png"),
          ),
        ));

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: Text("Add Location"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [
            Container(
              child: InkWell(
                onTap: pilihJalur,
                child: _imgFile == null
                    ? placeholder
                    : Image.file(
                        _imgFile!,
                        width: 200,
                        height: 200,
                      ),
              ),
            ),
            SizedBox(height: 20),
            TextFormField(
              controller: _nameLocation,
              decoration: InputDecoration(
                  hintText: "Location Name",
                  border: OutlineInputBorder(borderSide: BorderSide())),
              maxLines: 6,
            ),
            SizedBox(height: 20),
            TextFormField(
              controller: _latitude,
              decoration: InputDecoration(
                  hintText: "Latitude",
                  prefixIcon: Icon(Icons.gps_fixed),
                  border: OutlineInputBorder(borderSide: BorderSide())),
            ),
            SizedBox(height: 20),
            TextFormField(
              controller: _longitude,
              decoration: InputDecoration(
                  hintText: "Longitude",
                  prefixIcon: Icon(Icons.gps_not_fixed),
                  border: OutlineInputBorder(borderSide: BorderSide())),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            MaterialButton(
              color: Colors.green,
              minWidth: 150,
              height: 50,
              onPressed: () async {
                FirebaseStorage storage = FirebaseStorage.instance;
                Reference ref =
                    storage.ref().child(DateTime.now().toString() + ".jpg");

                UploadTask uploadTask = ref.putFile(_imgFile!);
                TaskSnapshot taskSnapshot =
                    await uploadTask.whenComplete(() => null);

                String _imageUrl = await taskSnapshot.ref.getDownloadURL();

                FirebaseFirestore firestore = FirebaseFirestore.instance;

                CollectionReference addRideRunner =
                    firestore.collection("riderunner");

                await addRideRunner.add({
                  "lokasi": _nameLocation.text,
                  "latitude": _latitude.text,
                  "longitude": _longitude.text,
                  "imgUrl": _imageUrl,
                });

                Navigator.pop(context);

                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    backgroundColor: Colors.green,
                    content: Text("Lokasi Terbaru Berhasil Di Tambahkan!")
                ));
              },
              child: Text(
                "Save",
                style: TextStyle(color: Colors.white),
              ),
            ),
            SizedBox(width: 10),
            MaterialButton(
              color: Colors.amber,
              onPressed: () {
                _getGeolocationPosition();
              },
              minWidth: 150,
              height: 50,
              child: Text("Check Location"),
            ),
          ],
        ),
      ),
    );
  }
}
