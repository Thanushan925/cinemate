import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Movie {
  final int id;
  final String name;
  final String runtime;
  final String releaseDate;
  final String smallPosterImageUrl;

  Movie({
    required this.id,
    required this.name,
    required this.runtime,
    required this.releaseDate,
    required this.smallPosterImageUrl,
  });
}

Future<List<Movie>> fetchMovies() async {
  final response = await http.get(Uri.parse('https://www.cineplex.com/api/v1/movies?language=en-us&marketLanguageCodeFq'));

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
      );
    }).toList();

    return movies;
  } else {
    throw Exception('Failed to load movies');
  }
}

void main() => runApp(const BrowsingPage());

class BrowsingPage extends StatefulWidget {
  const BrowsingPage({Key? key});

  @override
  _BrowsingPageState createState() => _BrowsingPageState();
}

class _BrowsingPageState extends State<BrowsingPage> {
  late Future<List<Movie>> futureMovies;

  @override
  void initState() {
    super.initState();
    futureMovies = fetchMovies();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Movie List',
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Movies'),
        ),
        body: Center(
          child: FutureBuilder<List<Movie>>(
            future: futureMovies,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                final movies = snapshot.data!;

                return ListView.builder(
                  itemCount: movies.length,
                  itemBuilder: (context, index) {
                    final movie = movies[index];

                    return ListTile(
                      leading: Image.network(movie.smallPosterImageUrl),
                      title: Text(movie.name),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Runtime: ${movie.runtime}'),
                          Text('Release Date: ${movie.releaseDate}'),
                        ],
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
