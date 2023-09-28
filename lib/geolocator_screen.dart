import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:lottie/lottie.dart';

// ignore: must_be_immutable
class GeoLocatorScreen extends StatefulWidget {
  GeoLocatorScreen({super.key});

  @override
  State<GeoLocatorScreen> createState() => _GeoLocatorScreenState();
}

class _GeoLocatorScreenState extends State<GeoLocatorScreen> {
  String currentAddress = "My Address";

  Position? currentPosition;

  Future<Position> determinePosition() async {
    bool serviceEnabled;
    LocationPermission locationPermission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      Fluttertoast.showToast(msg: "Please Keep your location on.");
    }

    locationPermission = await Geolocator.checkPermission();
    if (locationPermission == LocationPermission.denied) {
      locationPermission = await Geolocator.requestPermission();

      if (locationPermission == LocationPermission.denied) {
        Fluttertoast.showToast(msg: "Location Permission is denied.");
      }
    }

    if (locationPermission == LocationPermission.deniedForever) {
      Fluttertoast.showToast(msg: "Permission is denied Forever");
    }

    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    try {
      List<Placemark> placeMarks =
          await placemarkFromCoordinates(position.latitude, position.longitude);
      Placemark place = placeMarks[0];
      setState(() {
        currentPosition = position;
        currentAddress =
            "${place.locality},${place.postalCode},${place.country} ";
      });
    } catch (e) {
      log("$e");
    }
    return position;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("GeoLocation"),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          children: [
            Lottie.asset("assets/lottie/location_animation.json"),
            const SizedBox(height: 30),
            Card(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 44, vertical: 34),
                child: Column(
                  children: [
                    Text(
                      currentAddress,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    currentPosition != null
                        ? Text("Latitude : ${currentPosition!.latitude}")
                        : const SizedBox(),
                    const SizedBox(height: 10),
                    currentPosition != null
                        ? Text("Longitude : ${currentPosition!.longitude}")
                        : const SizedBox(),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                determinePosition();
              },
              child: const Text("Locate Me"),
            ),
          ],
        ),
      ),
    );
  }
}
