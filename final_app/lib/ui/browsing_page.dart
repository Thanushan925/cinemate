import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'movie_detail.dart';
import 'theme.dart';

class Movie {
  final int id;
  final String name;
  final String runtime;
  final String releaseDate;
  final String smallPosterImageUrl;
  final String? presentationType;
  final String? marketLanguageCode;
  final String? ratingDescription;
  final String? warning;
  final List<String>? formats;

  Movie({
    required this.id,
    required this.name,
    required this.runtime,
    required this.releaseDate,
    required this.smallPosterImageUrl,
    this.presentationType,
    this.marketLanguageCode,
    this.ratingDescription,
    this.warning,
    this.formats,
  });
}

Future<List<Movie>> fetchMovies() async {
  final response = await http.get(Uri.parse(
      'https://www.cineplex.com/api/v1/movies?language=en-us&marketLanguageCodeFq'));

  if (response.statusCode == 200) {
    final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
    final List<dynamic> moviesData = jsonResponse['data'];
    final List<Movie> movies = moviesData.map((movie) {
      return Movie(
        id: movie['id'] as int,
        name: movie['name'] as String,
        runtime: movie['duration'] as String,
        releaseDate: movie['releaseDate'] as String,
        smallPosterImageUrl: movie['smallPosterImageUrl'] as String,
        presentationType: movie['presentationType'] as String?,
        marketLanguageCode: movie['marketLanguageCode'] as String?,
        ratingDescription: movie['ratingDescription'] as String?,
        warning: movie['warning'] as String?,
        formats: List<String>.from(movie['formats'] ?? []),
      );
    }).toList();

    return movies;
  } else {
    throw Exception('Failed to load movies');
  }
}

class BrowsingPage extends StatefulWidget {
  const BrowsingPage({Key? key});

  @override
  _BrowsingPageState createState() => _BrowsingPageState();
}

class _BrowsingPageState extends State<BrowsingPage> {
  late Future<List<Movie>> futureMovies;
  TextEditingController searchController = TextEditingController();
  List<Movie> filteredMovies = [];
  bool isSearching = false;

  @override
  void initState() {
    super.initState();
    futureMovies = fetchMovies();
  }

  void filterMovies(String query) {
    if (query.isEmpty) {
      setState(() {
        filteredMovies = [];
        isSearching = false;
      });
    } else {
      final lowercaseQuery = query.toLowerCase();
      futureMovies.then((moviesList) {
        setState(() {
          isSearching = true;
          filteredMovies = moviesList.where((movie) {
            return movie.name.toLowerCase().contains(lowercaseQuery);
          }).toList();
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Movie List',
      // set theme according to ThemeManager
      theme: ThemeManager.currentTheme,
      home: Scaffold(
        appBar: AppBar(
          title: !isSearching
              ? const Text('Movies')
              : TextField(
                  controller: searchController,
                  onChanged: (value) {
                    setState(() {
                      filterMovies(value);
                    });
                  },
                  decoration: InputDecoration(
                    icon: Icon(Icons.search, color: Colors.white),
                    hintText: "Search Movie Name",
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
                    filterMovies('');
                  }
                });
              },
            ),
          ],
        ),
        body: Center(
          child: FutureBuilder<List<Movie>>(
            future: futureMovies,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                final movies = isSearching ? filteredMovies : snapshot.data!;

                return ListView.builder(
                  itemCount: movies.length,
                  itemBuilder: (context, index) {
                    final movie = movies[index];

                    DateTime releaseDateTime =
                        DateTime.parse(movie.releaseDate);
                    String formattedDate =
                        "${releaseDateTime.day}-${releaseDateTime.month}-${releaseDateTime.year}";

                    return Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: ListTile(
                        leading: Image.network(movie.smallPosterImageUrl),
                        title: Text(movie.name),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Runtime: ${movie.runtime}'),
                            Text('Release Date: $formattedDate'),
                          ],
                        ),
                        onTap: () {
                          // Navigate to the movie details page
                          showDialog(
                            context: context,
                            builder: (context) {
                              return MovieDetailPage(movie: movie);
                            },
                          );
                        },
                      ),
                    );
                  },
                );
              } else if (snapshot.hasError) {
                return Text('${snapshot.error}');
              }

              return const CircularProgressIndicator();
            },
          ),
        ),
      ),
    );
  }
}
