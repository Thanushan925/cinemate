import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as LatLng;
import 'package:final_app/storage/api_cinema.dart';
import 'package:location/location.dart' as Location;
import 'package:location/location.dart';
import 'dart:io';
import 'package:http/http.dart' as http;

class CinemaMapPage extends StatefulWidget {
  @override
  _CinemaMapPageState createState() => _CinemaMapPageState();
}

class _CinemaMapPageState extends State<CinemaMapPage> {
  late MapController _mapController;
  LatLng.LatLng _userLocation = LatLng.LatLng(0, 0);
  double _currentZoom = 12.0;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _getUserLocation();
  }

  void _getUserLocation() async {
    try {
      Location.Location location = Location.Location();
      bool serviceEnabled = await location.serviceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await location.requestService();
        if (!serviceEnabled) {
          return;
        }
      }

      PermissionStatus permissionStatus = await location.hasPermission();
      if (permissionStatus == PermissionStatus.denied) {
        permissionStatus = await location.requestPermission();
        if (permissionStatus != PermissionStatus.granted) {
          return;
        }
      }

      await _loadUserLocation();
    } catch (e) {
      print('Error getting user location: $e');
      // Implement retry logic here if needed
    }
  }

  int retryCount = 0;
  static const int maxRetries = 3;

  Future<void> _loadUserLocation() async {
    while (retryCount < maxRetries) {
      try {
        Location.LocationData currentLocation =
            await Location.Location().getLocation();
        setState(() {
          _userLocation = LatLng.LatLng(
            currentLocation.latitude!,
            currentLocation.longitude!,
          );
        });

        _mapController.move(_userLocation, _currentZoom);
        retryCount = 0;
        break;
      } on SocketException catch (e) {
        print('SocketException: $e');
        // Implement retry logic here
        retryCount++;
        print('Retrying... Attempt $retryCount');
      } catch (e) {
        print('Error loading user location: $e');
        // Handle other exceptions if needed
        break;
      }
    }
  }

  Future<http.Response> _delayedTileRequest(String url) async {
    await Future.delayed(
        Duration(milliseconds: 100)); // Adjust the delay as needed
    return http.get(Uri.parse(url));
  }

  // Adjust this radius based on how close you want the cinemas to be considered "near"
  static const double nearRadius = 15.0; // in kilometers
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<Cinema>>(
        future: ApiService().fetchCinemas(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No cinemas found.'));
          }

          // Filter cinemas within the specified radius
          List<Cinema> nearbyCinemas = snapshot.data!
              .where((cinema) =>
                  _calculateDistance(cinema.latitude, cinema.longitude,
                      _userLocation.latitude, _userLocation.longitude) <
                  nearRadius)
              .toList();

          return FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              center: _userLocation,
              zoom: _currentZoom,
              maxZoom: 18.0,
              minZoom: 5.0,
            ),
            children: [
              TileLayer(
                urlTemplate:
                    'https://api.mapbox.com/styles/v1/mapbox/streets-v12/tiles/256/{z}/{x}/{y}@2x?access_token=pk.eyJ1IjoiZ2FiYnktdiIsImEiOiJjbHBiZjM3ajYwZXI4Mmpwa2hpNGk1dG9hIn0.kqoF2-KAvZA5HNm7xoYXGw',
                subdomains: ['a', 'b', 'c'],
              ),
              CircleLayer(
                circles: [
                  CircleMarker(
                    point: _userLocation,
                    color: Colors.blue.withOpacity(0.3),
                    borderStrokeWidth: 2,
                    borderColor: Colors.blue,
                    radius: 10,
                  ),
                ],
              ),
              MarkerLayer(
                markers: nearbyCinemas.map((cinema) {
                  return Marker(
                    width: 200.0,
                    height: 150.0,
                    point: LatLng.LatLng(cinema.latitude, cinema.longitude),
                    child: Column(
                      children: [
                        Container(
                          width: 200,
                          padding: EdgeInsets.all(8.0),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: Text(
                            cinema.name,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Container(
                          width: 80,
                          height: 50,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Distance:',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                '${_calculateDistance(cinema.latitude, cinema.longitude, _userLocation.latitude, _userLocation.longitude).toStringAsFixed(2)} km',
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: 50,
                          height: 50,
                          child: Image.network(
                            'https://cdn4.iconfinder.com/data/icons/evil-icons-user-interface/64/location-512.png', // Replace with your marker icon URL
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ],
          );
        },
      ),
    );
  }

  // Function to calculate the distance between two sets of coordinates using Haversine formula
  double _calculateDistance(
      double lat1, double lon1, double lat2, double lon2) {
    const R = 6371.0; // Radius of the earth in km
    final dLat = _toRadians(lat2 - lat1);
    final dLon = _toRadians(lon2 - lon1);
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRadians(lat1)) *
            cos(_toRadians(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    final distance = R * c;
    return distance;
  }

  double _toRadians(double degrees) {
    return degrees * (pi / 180);
  }
}
