import 'package:flutter/material.dart';

import 'package:final_app/storage/api_cinema.dart'; // Make sure this import points to the correct file

class CinemaPage extends StatefulWidget {
  @override
  _CinemaPageState createState() => _CinemaPageState();
}

class _CinemaPageState extends State<CinemaPage> {
  late Future<List<Cinema>> cinemas;

  @override
  void initState() {
    super.initState();
    cinemas = ApiService().fetchCinemas();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Search Cinemas'),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              // Implement search functionality
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
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                Cinema cinema = snapshot.data![index];
                return ListTile(
                  leading: Icon(Icons.movie, color: Colors.yellow[700]),
                  title: Text(cinema.name),
                  subtitle: Text('${cinema.address} - ${cinema.distance.toStringAsFixed(1)} km away'),
                );
              },
            );
          }
        },
      ),
    );
  }
}
