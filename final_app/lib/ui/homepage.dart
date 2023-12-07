import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:theme_provider/theme_provider.dart';
import 'movie_detail.dart';
import 'theme.dart';

class Movie {
  int? id;
  String? name;
  String? runtime;
  String? releaseDate;
  String? largePosterImageUrl;
  String? presentationType;
  String? marketLanguageCode;
  String? ratingDescription;
  String? warning;
  List<String>? formats;

  Movie({
    required this.id,
    required this.name,
    required this.runtime,
    required this.releaseDate,
    required this.largePosterImageUrl,
    required this.presentationType,
    this.marketLanguageCode,
    this.ratingDescription,
    this.warning,
    this.formats,
  });

  Movie.fromMap(Map map) {
    id = map['id'];
    name = map['name'];
    runtime = map['runtime'];
    releaseDate = map['releaseDate'];
    largePosterImageUrl = map['largePosterImageUrl'];
    presentationType = map['presentationType'];
    ratingDescription = map['ratingDescription'];
    warning = map['warning'] as String?;
    formats = List<String>.from(map['formats'] ?? []);
  }

  Map<String, Object?> toMap() {
    return {
      'id': this.id,
      'name': this.name,
      'runtime': this.runtime,
      'releaseDate': this.releaseDate,
      'largePosterImageUrl': this.largePosterImageUrl,
      'marketLanguageCode': this.marketLanguageCode,
      'ratingDescription': this.ratingDescription,
      'warning': this.warning,
      'formats': this.formats,
    };
  }

  String toString() {
    return "Movie id: $id, name: $name, runtime: $runtime, release date: $releaseDate, presentation type: $presentationType, MarketLanguageCode: $marketLanguageCode, Rating Description: $ratingDescription, warning: $warning, Formats: $formats";
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

  // Define a helper function to check if a movie is an IMAX experience
  bool isIMAXExperience(Movie movie) {
    return movie.name!.toLowerCase().contains('imax');
  }

  // Define a helper function to check if a movie is in a language other than English
  bool isOtherLanguage(Movie movie) {
    return movie.marketLanguageCode != 'EN';
  }

  // Define a helper function to check if a movie is new this month
  bool isNewThisMonth(Movie movie) {
    DateTime releaseDateTime = DateTime.parse(movie.releaseDate!);
    DateTime today = DateTime.now();
    return releaseDateTime.isAfter(DateTime(today.year, today.month, 1));
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
              List<Movie> movies = snapshot.data!;

              // Filter movies running in the last three weeks
              movies = movies.where((movie) {
                DateTime releaseDateTime = DateTime.parse(movie.releaseDate!);
                DateTime today = DateTime.now();
                Duration difference = today.difference(releaseDateTime);
                return difference.inDays <= 21 && difference.inDays >= 0;
              }).toList();

              // Separate movies into English and non-English categories
              List<Movie> englishMovies = movies
                  .where((movie) => movie.marketLanguageCode == 'EN')
                  .toList();
              List<Movie> nonEnglishMovies = movies
                  .where((movie) => movie.marketLanguageCode != 'EN')
                  .toList();

              // Sort English movies by popularity (based on available formats)
              englishMovies.sort((a, b) => b.formats!.length.compareTo(a.formats!.length));

              return SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    SizedBox(height: 12),
                    Text(
                      'Popular Movies',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 20), // Add some space here
                    Container(
                      height: 300,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: englishMovies.length,
                        itemBuilder: (context, index) {
                          final movie = englishMovies[index];
                          DateTime releaseDateTime = DateTime.parse(movie.releaseDate!);
                          String formattedDate = "${releaseDateTime.day}-${releaseDateTime.month}-${releaseDateTime.year}";

                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0),
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
                                          Text('Release Date: $formattedDate'),
                                          Text(
                                            'Presentation Type: ${movie.presentationType}',
                                          ),
                                          Text(
                                            'Market Language: ${movie.marketLanguageCode}',
                                          ),
                                          Text(
                                            'Rating Description: ${movie.ratingDescription ?? 'N/A'}',
                                          ),
                                          Text(
                                            'Warning: ${movie.warning ?? 'N/A'}',
                                          ),
                                          Text(
                                            'Formats: ${movie.formats?.join(', ') ?? 'N/A'}',
                                          ),
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

                    const ListTile(
                      title: Text('New This Month', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                    ),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: englishMovies.length,
                      itemBuilder: (context, index) {
                        final movie = englishMovies[index];

                        // Check if the movie is new this month
                        bool isNewMonth = isNewThisMonth(movie);

                        if (isNewMonth) {
                          DateTime releaseDateTime = DateTime.parse(movie.releaseDate!);
                          String formattedDate =
                              "${releaseDateTime.day}-${releaseDateTime.month}-${releaseDateTime.year}";

                          return Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8.0,
                              vertical: 8.0,
                            ),
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
                                            'Presentation Type: ${movie.presentationType}',
                                          ),
                                          Text(
                                            'Market Language: ${movie.marketLanguageCode}',
                                          ),
                                          Text(
                                            'Rating Description: ${movie.ratingDescription ?? 'N/A'}',
                                          ),
                                          Text(
                                            'Warning: ${movie.warning ?? 'N/A'}',
                                          ),
                                          Text(
                                              'Formats: ${movie.formats?.join(', ') ?? 'N/A'}'),
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
                        } else {
                          return SizedBox.shrink(); // Skip this item if it's not new this month
                        }
                      },
                    ),

                    const ListTile(
                      title: Text('IMAX Experiences', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                    ),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: englishMovies.length,
                      itemBuilder: (context, index) {
                        final movie = englishMovies[index];

                        // Check if the movie is an IMAX experience
                        bool isIMAX = isIMAXExperience(movie);

                        if (isIMAX) {
                          DateTime releaseDateTime = DateTime.parse(movie.releaseDate!);
                          String formattedDate =
                              "${releaseDateTime.day}-${releaseDateTime.month}-${releaseDateTime.year}";

                          return Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8.0,
                              vertical: 8.0,
                            ),
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
                                            'Presentation Type: ${movie.presentationType}',
                                          ),
                                          Text(
                                            'Market Language: ${movie.marketLanguageCode}',
                                          ),
                                          Text(
                                            'Rating Description: ${movie.ratingDescription ?? 'N/A'}',
                                          ),
                                          Text(
                                            'Warning: ${movie.warning ?? 'N/A'}',
                                          ),
                                          Text(
                                              'Formats: ${movie.formats?.join(', ') ?? 'N/A'}'),
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
                        } else {
                          return SizedBox.shrink(); // Skip this item if it's not an IMAX experience
                        }
                      },
                    ),

                    const ListTile(
                      title: Text('Tired of English?', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                    ),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: nonEnglishMovies.length,
                      itemBuilder: (context, index) {
                        final movie = nonEnglishMovies[index];

                        // Check if the movie is in a language other than English
                        bool isOtherLang = isOtherLanguage(movie);

                        if (isOtherLang) {
                          DateTime releaseDateTime = DateTime.parse(movie.releaseDate!);
                          String formattedDate =
                              "${releaseDateTime.day}-${releaseDateTime.month}-${releaseDateTime.year}";
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8.0,
                              vertical: 8.0,
                            ),
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
                                            'Presentation Type: ${movie.presentationType}',
                                          ),
                                          Text(
                                            'Market Language: ${movie.marketLanguageCode}',
                                          ),
                                          Text(
                                            'Rating Description: ${movie.ratingDescription ?? 'N/A'}',
                                          ),
                                          Text(
                                            'Warning: ${movie.warning ?? 'N/A'}',
                                          ),
                                          Text(
                                              'Formats: ${movie.formats?.join(', ') ?? 'N/A'}'),
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
                        } else {
                          return SizedBox.shrink(); // Skip this item if it's not in another language
                        }
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
