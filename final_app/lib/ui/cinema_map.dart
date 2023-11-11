import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:final_app/storage/api_cinema.dart';
import 'package:geolocator/geolocator.dart';

class CinemaMapPage extends StatefulWidget {
  @override
  _CinemaMapPageState createState() => _CinemaMapPageState();
}

class _CinemaMapPageState extends State<CinemaMapPage> {
  late Future<List<Cinema>> _cinemasFuture;
  List<Marker> _markers = [];
  List<CircleMarker> _circleMarkers = [];
  MapController _mapController = MapController();
  LatLng? _userLocation;

  @override
  void initState() {
    super.initState();
    _cinemasFuture = ApiService().fetchCinemas();
    _getUserLocation();
  }

  void _getUserLocation() async {
    var serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return;
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return;
      }
    }

    if (permission == LocationPermission.whileInUse || permission == LocationPermission.always) {
      try {
        var position = await Geolocator.getCurrentPosition();
        setState(() {
          _userLocation = LatLng(position.latitude, position.longitude);
          _circleMarkers.add(CircleMarker(
            point: _userLocation!,
            color: Colors.blue.withOpacity(0.3),
            borderStrokeWidth: 2,
            borderColor: Colors.blue,
            radius: 10, // Adjust radius size as needed
          ));
        });
         _mapController.move(_userLocation!, 13);
      } catch (e) {
        print('Error getting user location: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<Cinema>>(
        future: _cinemasFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No cinemas found.'));
          }

          //Clear existing markers when new data is available
          if (snapshot.hasData) {
            _markers = snapshot.data!.map((cinema) {
              return Marker(
                width: 80.0,
                height: 80.0,
                point: LatLng(cinema.latitude, cinema.longitude),
                child: Container(
                  child: Icon(Icons.location_on, color: Colors.red),
                ),
              );
            }).toList();
          }

          LatLng center = _userLocation ?? LatLng(0, 0); // Use user location if available

          return FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              center: center,
              zoom: 13.0,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                subdomains: ['a', 'b', 'c'],
              ),
              MarkerLayer(markers: _markers),
              CircleLayer(circles: (_circleMarkers)),
            ],
          );

        },
      ),
    );
  }
}
