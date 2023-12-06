import 'package:flutter/material.dart';
import 'package:final_app/storage/api_cinema.dart';
import 'cinema_detail.dart';
import 'cinema_map.dart';
import 'package:latlong2/latlong.dart' as LatLng;
import 'dart:math';
// import 'package:location/location.dart' as Location;
import 'package:geolocator/geolocator.dart';

class CinemaPage extends StatefulWidget {
  @override
  _CinemaPageState createState() => _CinemaPageState();
}

class _CinemaPageState extends State<CinemaPage>
    with SingleTickerProviderStateMixin {
  late Future<List<Cinema>> cinemas;
  late TabController _tabController;
  TextEditingController searchController = TextEditingController();
  List<Cinema> filteredCinemas = [];
  bool isSearching = false;
  LatLng.LatLng? _userLocation; // Define _userLocation here

  @override
  void initState() {
    super.initState();
    cinemas = ApiService().fetchCinemas();
    _tabController = TabController(length: 2, vsync: this);
    _getUserLocation(); // Call the function to get user location
  }

  void _getUserLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _userLocation = LatLng.LatLng(
          position.latitude,
          position.longitude,
        );
      });
    } catch (e) {
      print('Error getting user location: $e');
    }
  }

  void filterCinemas(String query) {
    if (query.isEmpty) {
      setState(() {
        filteredCinemas = [];
        isSearching = false;
      });
    } else {
      final lowercaseQuery = query.toLowerCase();
      cinemas.then((cinemaList) {
        setState(() {
          isSearching = true;
          filteredCinemas = cinemaList.where((cinema) {
            return cinema.name.toLowerCase().contains(lowercaseQuery);
          }).toList();
        });
      });
    }
  }

  @override
  void dispose() {
    searchController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void navigateToCinemaDetail(Cinema cinema) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CinemaDetailPage(cinema: cinema),
      ),
    );
  }

  Widget _buildListView() {
    return FutureBuilder<List<Cinema>>(
      future: cinemas,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('No cinemas found.'));
        }

        final cinemasToShow = isSearching ? filteredCinemas : snapshot.data!;

        // Sort cinemas by distance
        cinemasToShow.sort((cinema1, cinema2) {
          double distance1 = _userLocation != null
              ? calculateDistance(
                  LatLng.LatLng(cinema1.latitude, cinema1.longitude),
                  _userLocation!,
                )
              : double.infinity;

          double distance2 = _userLocation != null
              ? calculateDistance(
                  LatLng.LatLng(cinema2.latitude, cinema2.longitude),
                  _userLocation!,
                )
              : double.infinity;
          return distance1.compareTo(distance2);
        });

        return ListView.builder(
          itemCount: cinemasToShow.length,
          itemBuilder: (context, index) {
            var cinema = cinemasToShow[index];
            double distance = _userLocation != null
                ? calculateDistance(
                    LatLng.LatLng(cinema.latitude, cinema.longitude),
                    _userLocation!,
                  )
                : 0.0;
            //double distance = calculateDistance(LatLng(cinema.latitude, cinema.longitude), _userLocation);
            return ListTile(
              leading: Icon(Icons.movie, color: Colors.yellow[700]),
              title: Text(cinema.name),
              subtitle: Text(
                distance > 0
                    ? '${distance.toStringAsFixed(1)} km away'
                    : 'Distance not available',
              ),
              onTap: () => navigateToCinemaDetail(cinema),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: !isSearching
            ? Text('Cinemas')
            : TextField(
                controller: searchController,
                onChanged: (value) {
                  setState(() {
                    filterCinemas(value);
                  });
                },
                decoration: InputDecoration(
                  icon: Icon(Icons.search, color: Colors.white),
                  hintText: "Search Cinema Name",
                  hintStyle: TextStyle(color: Colors.white),
                ),
                style: TextStyle(color: Colors.white),
              ),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(icon: Icon(Icons.list), text: 'List'),
            Tab(icon: Icon(Icons.map), text: 'Map'),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(isSearching ? Icons.cancel : Icons.search),
            onPressed: () {
              setState(() {
                isSearching = !isSearching;
                if (!isSearching) {
                  searchController.clear();
                  filterCinemas('');
                }
              });
            },
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildListView(),
          CinemaMapPage(), // Map view tab
        ],
      ),
    );
  }
}

double calculateDistance(LatLng.LatLng point1, LatLng.LatLng point2) {
  const double earthRadius = 6371.0; // Radius of the Earth in kilometers

  double radians(double degree) {
    return degree * (pi / 180.0);
  }

  double dLat = radians(point2.latitude - point1.latitude);
  double dLon = radians(point2.longitude - point1.longitude);

  double a = sin(dLat / 2) * sin(dLat / 2) +
      cos(radians(point1.latitude)) *
          cos(radians(point2.latitude)) *
          sin(dLon / 2) *
          sin(dLon / 2);

  double c = 2 * atan2(sqrt(a), sqrt(1 - a));

  double distance = earthRadius * c;

  return distance;
}
