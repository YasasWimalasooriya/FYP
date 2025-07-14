import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class GoogleMapScreen extends StatefulWidget {
  const GoogleMapScreen({super.key});

  @override
  State<GoogleMapScreen> createState() => _GoogleMapScreenState();
}

class _GoogleMapScreenState extends State<GoogleMapScreen> {
  late GoogleMapController _mapController;
  LatLng _initialPosition = const LatLng(6.9271, 79.8612); // Colombo
  Set<Marker> _evOwnerMarkers = {};

  @override
  void initState() {
    super.initState();
    _listenToEVOwnerLocations();
  }

  void _listenToEVOwnerLocations() {
    FirebaseFirestore.instance.collection('ev_owners').snapshots().listen((snapshot) {
      Set<Marker> newMarkers = {};
      for (var doc in snapshot.docs) {
        var data = doc.data();
        if (data.containsKey('latitude') && data.containsKey('longitude')) {
          final marker = Marker(
            markerId: MarkerId(doc.id),
            position: LatLng(data['latitude'], data['longitude']),
            infoWindow: InfoWindow(
              title: data['name'] ?? 'EV Owner',
              snippet: 'ID: ${doc.id}',
            ),
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
          );
          newMarkers.add(marker);
        }
      }
      setState(() {
        _evOwnerMarkers = newMarkers;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("EV Owner Locations"),
        backgroundColor: Colors.green[900],
      ),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(target: _initialPosition, zoom: 12),
        onMapCreated: (controller) => _mapController = controller,
        markers: _evOwnerMarkers,
        myLocationButtonEnabled: true,
      ),
    );
  }
}