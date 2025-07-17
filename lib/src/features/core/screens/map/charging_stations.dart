import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:http/http.dart' as http;
import '../profile/profile.dart';

class ChargingStations extends StatefulWidget {
  const ChargingStations({super.key});

  @override
  State<ChargingStations> createState() => _ChargingStationsState();
}

class _ChargingStationsState extends State<ChargingStations> {
  late GoogleMapController _mapController;
  List<Marker> markers = [

  ];
  Marker? _userMarker;
  Marker? destinationMarker;
  LatLng _initialPosition = const LatLng(6.8484, 79.9488); // Station position
  Set<Polyline> _polylines = {};
  Set<Polyline> _polylinesDes = {};

  final LatLng _stationPosition = const LatLng(6.8484, 79.9488);

  @override
  void initState() {
    super.initState();
    _determinePosition();
  }

  @override
  void dispose() {
    destinationController.dispose();
    _mapController.dispose();
    super.dispose();
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

      _drawRoute(newPos, _stationPosition,"user");
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

  Future<void> _drawRoute(LatLng origin, LatLng destination , String id) async {
    const String apiKey = 'AIzaSyArzhMPgyer1wC_H9j9fIEGpdAbrq3ELY4'; // Replace with your key

    final url =
        'https://maps.googleapis.com/maps/api/directions/json?origin=${origin.latitude},${origin.longitude}&destination=${destination.latitude},${destination.longitude}&key=$apiKey';

    final response = await http.get(Uri.parse(url));
    final data = jsonDecode(response.body);

    if (data['status'] == 'OK') {
      final points = PolylinePoints().decodePolyline(
        data['routes'][0]['overview_polyline']['points'],
      );

      final polylineCoordinates = points.map((e) => LatLng(e.latitude, e.longitude)).toList();

      setState(() {
        _polylines.removeWhere((polyline) => polyline.polylineId.value == id);
        _polylines.add(Polyline(
          polylineId:  PolylineId(id),
          color: Colors.blue,
          width: 5,
          points: polylineCoordinates,
        ));
      });
    } else {
      print("❌ Directions API error: ${data['status']}");
    }
  }
  // Future<void> _drawRouteDestination(LatLng origin, LatLng destination) async {
  //   const String apiKey = 'AIzaSyArzhMPgyer1wC_H9j9fIEGpdAbrq3ELY4'; // Replace with your key
  //
  //   final url =
  //       'https://maps.googleapis.com/maps/api/directions/json?origin=${origin.latitude},${origin.longitude}&destination=${destination.latitude},${destination.longitude}&key=$apiKey';
  //
  //   final response = await http.get(Uri.parse(url));
  //   final data = jsonDecode(response.body);
  //
  //   if (data['status'] == 'OK') {
  //     final points = PolylinePoints().decodePolyline(
  //       data['routes'][0]['overview_polyline']['points'],
  //     );
  //
  //     final polylineCoordinates = points.map((e) => LatLng(e.latitude, e.longitude)).toList();
  //
  //     setState(() {
  //       _polylinesDes.clear();
  //       _polylinesDes.add(Polyline(
  //         polylineId: const PolylineId("route"),
  //         color: Colors.blue,
  //         width: 5,
  //         points: polylineCoordinates,
  //       ));
  //     });
  //   } else {
  //     print("❌ Directions API error: ${data['status']}");
  //   }
  // }
  TextEditingController destinationController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

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
      body: Stack(
        children: [

          GoogleMap(
            initialCameraPosition: CameraPosition(target: _initialPosition, zoom: 15),
            onMapCreated: (controller) => _mapController = controller,
            markers: {
              Marker(
                markerId: const MarkerId("station1"),
                position: _stationPosition,
                infoWindow: const InfoWindow(title: "Charging Station - Pannipitiya"),
              ),

              if (_userMarker != null) _userMarker!,
              if (destinationMarker != null) destinationMarker!,
            },
            polylines: _polylines,
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
          ),
          Container(
            color: Colors.white,
            width: width,
            height: height * 0.1,
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: TypeAheadField(
              textFieldConfiguration: TextFieldConfiguration(
                controller: destinationController,
                decoration: const InputDecoration(
                  hintText: "Search next destination",
                  border: OutlineInputBorder(),
                ),
              ),
              suggestionsCallback: (pattern) async {
                if (pattern.isEmpty) return [];

                final apiKey = 'AIzaSyArzhMPgyer1wC_H9j9fIEGpdAbrq3ELY4';
                final url =
                    'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$pattern&types=geocode&key=$apiKey';
                final response = await http.get(Uri.parse(url));
                final predictions = jsonDecode(response.body)['predictions'];

                return predictions;
              },
              itemBuilder: (context, suggestion) {
                final suggestionMap = suggestion as Map<String, dynamic>;
                return ListTile(


                  title: Text(suggestionMap['description'] ?? 'Unknown'),
                );
              },
              onSuggestionSelected: (suggestion) async {
                final suggestionMap = suggestion as Map<String, dynamic>;
                destinationController.text = suggestionMap['description']??"unknown";

                // Get place details (coordinates)
                final placeId = suggestion['place_id'];
                final apiKey = 'AIzaSyArzhMPgyer1wC_H9j9fIEGpdAbrq3ELY4';
                final detailsUrl =
                    'https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=$apiKey';

                final detailsResponse = await http.get(Uri.parse(detailsUrl));
                final location = jsonDecode(detailsResponse.body)['result']['geometry']['location'];

                final lat = location['lat'];
                final lng = location['lng'];
                LatLng newPos = LatLng(lat, lng);
                setState(() {

                  destinationMarker = Marker(
                    markerId: const MarkerId('user'),
                    position: LatLng(lat, lng) ,
                    icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
                  );
                  _mapController.animateCamera(CameraUpdate.newLatLng(newPos));
                });
                _drawRoute(newPos, _stationPosition,"dest");

                print('📍 Selected place coordinates: $lat, $lng');

                // You can now use LatLng(lat, lng) to show marker or draw route
              },
            ),
          )
        ],
      ),
    );
  }
}
