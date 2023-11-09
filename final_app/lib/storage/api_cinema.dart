
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
      List<dynamic> theatresList = decodedJson['data'] as List<dynamic>? ?? [];
      return theatresList.map((theatreJson) => Cinema.fromJson(theatreJson)).toList();
    } else {
      throw Exception('Failed to load cinemas');
    }
  }
}

class Cinema {
  final int id;
  final String name;
  final String address;
  final double distance;
  final List<Experience> experiences;

  Cinema({
    required this.id,
    required this.name,
    required this.address,
    required this.distance,
    required this.experiences,
  });

  factory Cinema.fromJson(Map<String, dynamic> json) {
    return Cinema(
      id: json['id'] ?? 0, // Default value if null
      name: json['name'] ?? 'Unknown', // Default value if null
      address: "${json['address1'] ?? ''} ${json['city'] ?? ''}, ${json['provinceCode'] ?? ''}, ${json['postalCode'] ?? ''}".trim(),
      distance: json['distance']?.toDouble() ?? 0.0, // Default value if null
      experiences: (json['experiences'] as List<dynamic>?)
          ?.map((e) => Experience.fromJson(e as Map<String, dynamic>))
          .toList() ?? [], // Default value if null
    );
  }
}

class Experience {
  final String title;
  final String description;

  Experience({
    required this.title,
    required this.description,
  });

  factory Experience.fromJson(Map<String, dynamic> json) {
    return Experience(
      title: json['title'] ?? 'Unknown Experience', // Default value if null
      description: json['description'] ?? 'Description not available', // Default value if null
    );
  }
}




