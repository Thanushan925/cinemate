
import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiService {
  final String _baseUrl = 'https://www.cineplex.com/api/v1/theatres?language=en-us&range=100000&skip=0&take=1000';

  Future<List<Cinema>> fetchCinemas() async {
    final response = await http.get(Uri.parse(_baseUrl), headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Language': 'en-us'
    });

    if (response.statusCode == 200) {
      final Map<String, dynamic> decodedJson = jsonDecode(response.body);
      List<Cinema> cinemas = [];

      List<dynamic> theatresList = decodedJson['data'] ?? [];
      for (var theatreJson in theatresList) {
        var cinema = Cinema.fromJson(theatreJson);
        cinemas.add(cinema);
      }
      return cinemas;
    } else {
      throw Exception('Failed to load cinemas');
    }
  }
}

class Cinema {
  final String name;
  final String address;
  final double distance;

  Cinema({required this.name, required this.address, required this.distance});

  factory Cinema.fromJson(Map<String, dynamic> json) {
    String address = "${json['address1']} ${json['city']}, ${json['provinceCode']}, ${json['postalCode']}".trim();
    double distance = json['distance']; // Assume the distance is provided in the format you wish to display
    return Cinema(
      name: json['name'],
      address: address,
      distance: distance,
    );
  }
}


