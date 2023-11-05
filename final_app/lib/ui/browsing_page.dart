import 'package:flutter/material.dart';

class BrowsingPage extends StatefulWidget {
  @override
  _BrowsingPageState createState() => _BrowsingPageState();
}

class _BrowsingPageState extends State<BrowsingPage> {
  bool _showSearchBar = false;
  bool _sortAscending = true; // Added for sorting order

  // Sample movie names
  List<String> movieNames = [
    'Movie 1',
    'Movie 2',
    'Movie 3',
  ];

  @override
  Widget build(BuildContext context) {
    // Sort the movie names based on the current sorting order
    movieNames.sort((a, b) {
      if (_sortAscending) {
        return a.compareTo(b);
      } else {
        return b.compareTo(a);
      }
    });
    return Scaffold(
      appBar: AppBar(
        title: _showSearchBar
            ? TextField(
                decoration: InputDecoration(
                  hintText: 'Search Movies',
                  border: InputBorder.none,
                ),
                style: TextStyle(color: Colors.white),
                autofocus: true,
                onChanged: (query) {
                  // Handle search logic as the user types
                },
              )
            : Text('Movies'),
        actions: [
          IconButton(
            icon: Icon(_showSearchBar ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                _showSearchBar = !_showSearchBar;
              });
            },
          ),
          IconButton(
            icon: Icon(Icons.sort),
            onPressed: () {
              setState(() {
                _sortAscending = !_sortAscending;
              });
            },
          ),
        ],
      ),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Popular Movies',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          for (String movieName in movieNames)
            ListTile(
              title: Text(movieName),
            ),
          // Add widgets for popular movies here
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Now Playing',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          // Add widgets for now playing movies here
          for (String movieName in movieNames)
            ListTile(
              title: Text(movieName),
            ),
        ],
      ),
    );
  }
}
