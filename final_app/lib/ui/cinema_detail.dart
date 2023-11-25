import 'package:flutter/material.dart';
import 'package:final_app/storage/api_cinema.dart';

class CinemaDetailPage extends StatelessWidget {
  final Cinema cinema;

  CinemaDetailPage({required this.cinema});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(cinema.name),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              cinema.address,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Text(
              'Experiences:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            ...cinema.experiences.map((experience) => ListTile(
              title: Text(experience.title),
              subtitle: Text(experience.description),
            )).toList(),
            SizedBox(height: 20),
            Text(
              'Location:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            cinema.mobileMapImageUrl != null
                ? Image.network(
              cinema.mobileMapImageUrl!,
              fit: BoxFit.cover, // Use BoxFit.cover to display the full image
            )
                : Text('Image not available'),
            SizedBox(height: 20),
            Text(
              'Background:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            cinema.mobileBackgroundImageUrl != null
                ? Image.network(
              cinema.mobileBackgroundImageUrl!,
              fit: BoxFit.cover, // Use BoxFit.cover to display the full image
            )
                : Text('Image not available'),
          ],
        ),
      ),
    );
  }
}
