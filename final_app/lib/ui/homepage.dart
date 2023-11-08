import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Movie {
  final int id;
  final String name;
  final String runtime;
  final String releaseDate;
  final String largePosterImageUrl;

  Movie({
    required this.id,
    required this.name,
    required this.runtime,
    required this.releaseDate,
    required this.largePosterImageUrl,
  });

  ///////////////
  Movie.fromMap(Map map){
    id = map['id'];
    name = map['name'];
    runtime = map['runtime'];
    releaseDate = map['releaseDate'];
    largePosterImageUrl = map['largePosterImageUrl'];
  }

  Map<String, Object?> toMap(){
    return {
      'id': this.id,
      'name': this.name,
      'runtime': this.runtime,
      'releaseDate': this.releaseDate,
      'largePosterImageUrl': this.largePosterImageUrl
    };
  }

  String toString(){
    return "Movie id: $id, name: $name, runtime: $runtime, releas date: $releaseDate";
  }

  ///////////////////// Don't delete yet until I confirmed if needed here or another place
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
        largePosterImageUrl: movie['largePosterImageUrl'] as String,
      );
    }).toList();

    return movies;
  } else {
    throw Exception('Failed to load movies');
  }
}

void main() => runApp(const MaterialApp(
      home: Home(),
    ));

class Home extends StatefulWidget {
  const Home({Key? key});

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late Future<List<Movie>> futureMovies;

  @override
  void initState() {
    super.initState();
    futureMovies = fetchMovies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
      ),
      body: Center(
        child: FutureBuilder<List<Movie>>(
          future: futureMovies,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              final movies = snapshot.data!;

              return SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    SizedBox(height: 10),
                    Text(
                      'Popular',
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    Container(
                      height: 300,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: movies.length,
                        itemBuilder: (context, index) {
                          final movie = movies[index];
                          return GestureDetector(
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    title: Text(movie.name),
                                    actions: [
                                      IconButton(
                                        icon: Icon(Icons.close),
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                      ),
                                    ],
                                    content: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Image.network(
                                          movie.largePosterImageUrl,
                                          width: 250,
                                          height: 300,
                                        ),
                                        SizedBox(height: 20),
                                        Text('Runtime: ${movie.runtime}'),
                                        Text(
                                          'Release Date: ${movie.releaseDate}',
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                children: [
                                  Image.network(
                                    movie.largePosterImageUrl,
                                    width: 200,
                                    height: 250,
                                  ),
                                  Text(movie.name),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    Text(
                      'All Movies',
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: movies.length,
                      itemBuilder: (context, index) {
                        final movie = movies[index];
                        return ListTile(
                          leading: Image.network(movie.largePosterImageUrl),
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
                    ),
                  ],
                ),
              );
            } else if (snapshot.hasError) {
              return Text('${snapshot.error}');
            }

            return const CircularProgressIndicator();
          },
        ),
      ),
    );
  }
}
