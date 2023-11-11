
import 'package:http/http.dart' as http;
import 'dart:convert';

// A service class for fetching cinema data from an API.
class ApiService {
  final String _baseUrl = 'https://www.cineplex.com/api/v1/theatres?language=en-us&range=100000&skip=0&take=1000';

  //Fetches cinema information from the API
  Future<List<Cinema>> fetchCinemas() async {
    final response = await http.get(Uri.parse(_baseUrl), headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Language': 'en-us'
    });

    if (response.statusCode == 200) {
      final Map<String, dynamic> decodedJson = jsonDecode(response.body);
      List<dynamic> theatresList = decodedJson['data'] as List<dynamic>? ?? [];
      return theatresList.map((theatreJson) => Cinema.fromJson(theatreJson)).toList();
    } else {
      throw Exception('Failed to load cinemas');
    }
  }
}

//A cinema class representation
class Cinema {
  final int id;
  final String name;
  final String address;
  final double latitude;
  final double longitude;
  final double distance;
  final List<Experience> experiences;

  Cinema({
    required this.id,
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.distance,
    required this.experiences,
  });

  factory Cinema.fromJson(Map<String, dynamic> json) {
    return Cinema(
      id: json['id'] as int? ?? 0, // Provide a default value of 0 if null
      name: json['name'] as String? ?? 'Unknown', // Provide a default value if null
      address: _buildAddress(json), // Call a separate function to build the address
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0, // Provide a default value if null
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0, // Provide a default value if null
      distance: (json['distance'] as num?)?.toDouble() ?? 0.0, // Provide a default value if null
      experiences: (json['experiences'] as List?)
          ?.map((e) => Experience.fromJson(e as Map<String, dynamic>))
          .toList() ?? [], // Provide an empty list if null
    );
  }

  //a function to build the address from a map
  static String _buildAddress(Map<String, dynamic> json) {
    return [
      json['address1'],
      json['city'],
      json['provinceCode'],
      json['postalCode']
    ].where((element) => element != null && element.isNotEmpty).join(', ');
  }
}

//an experience class that seperate a long list of experiences for each cinema for easier access
class Experience {
  final String title;
  final String description;

  Experience({
    required this.title,
    required this.description,
  });

  factory Experience.fromJson(Map<String, dynamic> json) {
    return Experience(
      title: json['title'] as String? ?? 'Unknown Experience', // Provide a default value if null
      description: json['description'] as String? ?? 'No description available', // Provide a default value if null
    );
  }
}




