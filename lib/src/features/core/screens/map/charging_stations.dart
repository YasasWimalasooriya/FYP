import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../profile/profile.dart';

class ChargingStations extends StatefulWidget {
  const ChargingStations({super.key});

  @override
  State<ChargingStations> createState() => _ChargingStationsState();
}

class _ChargingStationsState extends State<ChargingStations> {
  late GoogleMapController _mapController;
  Marker? _userMarker;
  LatLng _initialPosition = const LatLng(6.8484, 79.9488);

  @override
  void initState() {
    super.initState();
    _determinePosition();
  }

  Future<void> _determinePosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.deniedForever) return;

    Geolocator.getPositionStream(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
    ).listen((Position position) {
      LatLng newPos = LatLng(position.latitude, position.longitude);

      _updateLocationInFirestore(position.latitude, position.longitude);

      setState(() {
        _userMarker = Marker(
          markerId: const MarkerId('user'),
          position: newPos,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
        );
        _mapController.animateCamera(CameraUpdate.newLatLng(newPos));
      });
    });
  }

  Future<void> _updateLocationInFirestore(double latitude, double longitude) async {
    const userId = 'ev_owner_1'; // Replace with Firebase Auth UID if needed

    await FirebaseFirestore.instance.collection('ev_owners').doc(userId).set({
      'latitude': latitude,
      'longitude': longitude,
      'name': 'EV Owner 1',
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[200],
      appBar: AppBar(
        title: const Text("Charging Stations", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.green[900],
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const Profile()));
            },
          ),
        ],
      ),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(target: _initialPosition, zoom: 15),
        onMapCreated: (controller) => _mapController = controller,
        markers: {
          Marker(
            markerId: const MarkerId("station1"),
            position: const LatLng(6.8484, 79.9488),
            infoWindow: const InfoWindow(title: "Charging Station - Pannipitiya"),
          ),
          if (_userMarker != null) _userMarker!,
        },
        myLocationEnabled: true,
        myLocationButtonEnabled: true,
      ),
    );
  }
}