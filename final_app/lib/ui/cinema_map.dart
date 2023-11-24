import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as LatLng;
import 'package:final_app/storage/api_cinema.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:location/location.dart' as Location;
import 'package:location/location.dart';
import 'dart:io';

class CinemaMapPage extends StatefulWidget {
  @override
  _CinemaMapPageState createState() => _CinemaMapPageState();
}

class _CinemaMapPageState extends State<CinemaMapPage> {
  late MapController _mapController;
  LatLng.LatLng _userLocation = LatLng.LatLng(0, 0);

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    Location.Location location = Location.Location();
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

  Future<void> _loadUserLocation() async {
    try {
      Location.LocationData currentLocation =
          await Location.Location().getLocation();
      setState(() {
        _userLocation = LatLng.LatLng(
          currentLocation.latitude!,
          currentLocation.longitude!,
        );
      });

      _mapController.move(_userLocation, 13.0);
    } on SocketException catch (e) {
      print('SocketException: $e');
      // Implement retry logic here if needed
    } catch (e) {
      print('Error loading user location: $e');
    }
  }
  // void _getUserLocation() async {
  //   try {
  //     Location.Location location = Location.Location();
  //     bool serviceEnabled = await location.serviceEnabled();
  //     if (!serviceEnabled) {
  //       serviceEnabled = await location.requestService();
  //       if (!serviceEnabled) {
  //         return;
  //       }
  //     }
  //
  //     PermissionStatus permissionStatus = await location.hasPermission();
  //     if (permissionStatus == PermissionStatus.denied) {
  //       permissionStatus = await location.requestPermission();
  //       if (permissionStatus != PermissionStatus.granted) {
  //         return;
  //       }
  //     }
  //
  //     Location.LocationData currentLocation = await location.getLocation();
  //     setState(() {
  //       _userLocation = LatLng.LatLng(
  //           currentLocation.latitude!, currentLocation.longitude!);
  //     });
  //
  //     _mapController.move(_userLocation, 13.0);
  //   } catch (e) {
  //     print('Error getting user location: $e');
  //   }
  // }

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

          List<Marker> markers = snapshot.data!.map((cinema) {
            return Marker(
              width: 80.0,
              height: 80.0,
              point: LatLng.LatLng(cinema.latitude, cinema.longitude),
              child: Container(
                child: Icon(Icons.location_on, color: Colors.red),
              ),
            );
          }).toList();

          return FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              center: _userLocation,
              zoom: 13.0,
            ),
            children: [
              TileLayer(
                urlTemplate:
                    'https://api.mapbox.com/styles/v1/{id}/tiles/{z}/{x}/{y}?access_token={accessToken}',
                additionalOptions: {
                  'accessToken':
                      'pk.eyJ1IjoidmVkYW50Y29kZXMiLCJhIjoiY2xwYzdrYnBhMGt1ajJpcHBoMWNpeWtjdSJ9.LADgYrweIsFjr6At2oP22w',
                  'id': 'mapbox/streets-v11',
                },
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
              MarkerLayer(markers: markers),
            ],
          );
        },
      ),
    );
  }
}
