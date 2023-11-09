
import 'package:flutter/material.dart';
import 'package:final_app/storage/api_cinema.dart';
import 'cinema_detail.dart';

class CinemaPage extends StatefulWidget {
  @override
  _CinemaPageState createState() => _CinemaPageState();
}

class _CinemaPageState extends State<CinemaPage> {
  late Future<List<Cinema>> cinemas;
  TextEditingController searchController = TextEditingController();
  List<Cinema> filteredCinemas = [];
  bool isSearching = false;

  @override
  void initState() {
    super.initState();
    cinemas = ApiService().fetchCinemas();
  }

  void filterCinemas(String query) async {
    final lowercaseQuery = query.toLowerCase();
    final cinemaList = await cinemas; // Await the future
    setState(() {
      filteredCinemas = cinemaList.where((cinema) {
        return cinema.name.toLowerCase().contains(lowercaseQuery);
      }).toList();
    });
  }

  @override
  void dispose() {
    searchController.dispose();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: !isSearching
            ? Text('Search Cinemas')
            : TextField(
          controller: searchController,
          onChanged: filterCinemas,
          decoration: InputDecoration(
            icon: Icon(Icons.search, color: Colors.white),
            hintText: "Search Cinema Name",
            hintStyle: TextStyle(color: Colors.white),
          ),
          style: TextStyle(color: Colors.white),
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
      body: FutureBuilder<List<Cinema>>(
        future: cinemas,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No cinemas found.'));
          } else {
            // Update to use filteredCinemas if searching, otherwise snapshot data
            final cinemasToShow = isSearching ? filteredCinemas : snapshot.data!;
            return ListView.builder(
              itemCount: cinemasToShow.length,
              itemBuilder: (context, index) {
                Cinema cinema = cinemasToShow[index];
                return ListTile(
                  leading: Icon(Icons.movie, color: Colors.yellow[700]),
                  title: Text(cinema.name),
                  subtitle: Text('${cinema.address} - ${cinema.distance.toStringAsFixed(1)} km away'),
                  onTap: () => navigateToCinemaDetail(cinema),
                );
              },
            );
          }
        },
      ),
    );
  }
}


