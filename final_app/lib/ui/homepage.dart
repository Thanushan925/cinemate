import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:theme_provider/theme_provider.dart';
import 'theme.dart';

class Movie {
  int? id;
  String? name;
  String? runtime;
  String? releaseDate;
  String? largePosterImageUrl;
  String? presentationType;

  Movie({
    required this.id,
    required this.name,
    required this.runtime,
    required this.releaseDate,
    required this.largePosterImageUrl,
    required this.presentationType,
  });

  Movie.fromMap(Map map) {
    id = map['id'];
    name = map['name'];
    runtime = map['runtime'];
    releaseDate = map['releaseDate'];
    largePosterImageUrl = map['largePosterImageUrl'];
    presentationType = map['presentationType'];
  }

  Map<String, Object?> toMap() {
    return {
      'id': this.id,
      'name': this.name,
      'runtime': this.runtime,
      'releaseDate': this.releaseDate,
      'largePosterImageUrl': this.largePosterImageUrl,
    };
  }

  String toString() {
    return "Movie id: $id, name: $name, runtime: $runtime, release date: $releaseDate, presentation type: $presentationType";
  }
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
        presentationType: movie['presentationType'] as String?,
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
  late ConnectivityResult connectivityResult;

  @override
  void initState() {
    super.initState();
    futureMovies = fetchMovies();
    checkInternetConnectivity();
  }

  Future<void> checkInternetConnectivity() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      showSnackbar('No internet connection');
    }
  }

  void showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.lightbulb_outline),
            onPressed: () {
              ThemeProvider.controllerOf(context).nextTheme();
              // update theme for browsing page
              ThemeManager.setTheme(ThemeProvider.themeOf(context).data);
            },
          ),
        ],
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

                          return Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8.0),
                            child: GestureDetector(
                              onTap: () {
                                showDialog(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      title: Text(movie.name!),
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
                                            movie.largePosterImageUrl!,
                                            width: 250,
                                            height: 300,
                                          ),
                                          SizedBox(height: 20),
                                          Text('Runtime: ${movie.runtime}'),
                                          Text(
                                            'Release Date: ${movie.releaseDate}',
                                          ),
                                          Text(
                                              'Presentation Type: ${movie.presentationType}'),
                                        ],
                                      ),
                                    );
                                  },
                                );
                              },
                              child: Column(
                                children: [
                                  Image.network(
                                    movie.largePosterImageUrl!,
                                    width: 200,
                                    height: 250,
                                  ),
                                  SizedBox(height: 8.0),
                                  Text(movie.name!),
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

                        DateTime releaseDateTime =
                            DateTime.parse(movie.releaseDate!);
                        String formattedDate =
                            "${releaseDateTime.day}-${releaseDateTime.month}-${releaseDateTime.year}";

                        return Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8.0, vertical: 8.0),
                          child: ListTile(
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    title: Text(movie.name!),
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
                                          movie.largePosterImageUrl!,
                                          width: 250,
                                          height: 300,
                                        ),
                                        SizedBox(height: 20),
                                        Text('Runtime: ${movie.runtime}'),
                                        Text('Release Date: $formattedDate'),
                                        Text(
                                            'Presentation Type: ${movie.presentationType}'),
                                      ],
                                    ),
                                  );
                                },
                              );
                            },
                            leading: Image.network(movie.largePosterImageUrl!),
                            title: Text(movie.name!),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Runtime: ${movie.runtime}'),
                                Text('Release Date: $formattedDate'),
                              ],
                            ),
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
