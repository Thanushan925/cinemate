// movie_details.dart
import 'package:flutter/material.dart';
import 'browsing_page.dart';

String getLanguageDescription(String? languageCode) {
  if (languageCode == 'FR') {
    return 'French';
  } else if (languageCode == 'EN') {
    return 'English';
  } else {
    return 'Unknown';
  }
}

class MovieDetailPage extends StatelessWidget {
  final Movie movie;

  MovieDetailPage({required this.movie});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(movie.name),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(movie.smallPosterImageUrl),
            _buildDetailRow("Runtime", movie.runtime),
            _buildDetailRow("Release Date", movie.releaseDate),
            _buildDetailRow("Presentation Type", movie.presentationType ?? 'N/A'),
            _buildDetailRow("Market Language", getLanguageDescription(movie.marketLanguageCode)),
            _buildDetailRow("Rating Description", movie.ratingDescription ?? 'N/A'),
            _buildDetailRow("Warning", movie.warning ?? 'N/A'),
            _buildDetailRow("Formats", movie.formats?.join(', ') ?? 'N/A'),
          ],
        ),
      ),
      actions: [
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text('Close'),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String category, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$category:', style: TextStyle(fontWeight: FontWeight.bold)),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Text(value),
            ),
          ),
        ],
      ),
    );
  }
}