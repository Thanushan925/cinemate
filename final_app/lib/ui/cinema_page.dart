import 'package:flutter/material.dart';
import 'package:final_app/storage/api_cinema.dart';
import 'cinema_detail.dart';
import 'cinema_map.dart';

class CinemaPage extends StatefulWidget {
  @override
  _CinemaPageState createState() => _CinemaPageState();
}

class _CinemaPageState extends State<CinemaPage> with SingleTickerProviderStateMixin {
  late Future<List<Cinema>> cinemas;
  late TabController _tabController;
  TextEditingController searchController = TextEditingController();
  List<Cinema> filteredCinemas = [];
  bool isSearching = false;

  @override
  void initState() {
    super.initState();
    cinemas = ApiService().fetchCinemas();
    _tabController = TabController(length: 2, vsync: this);
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
        return ListView.builder(
          itemCount: cinemasToShow.length,
          itemBuilder: (context, index) {
            var cinema = cinemasToShow[index];
            //double distance = calculateDistance(LatLng(cinema.latitude, cinema.longitude), _userLocation);
            return ListTile(
              leading: Icon(Icons.movie, color: Colors.yellow[700]),
              title: Text(cinema.name),
              // Updated to show only the name and distance
              subtitle: Text('${cinema.distance.toStringAsFixed(1)} km away'),
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