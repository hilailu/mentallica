import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'contact.dart';

class ContactDetailsPage extends StatelessWidget {
  final Contact contact;

  const ContactDetailsPage({required this.contact, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(contact.name),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              contact.name,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              contact.address,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            Expanded(
              child: GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: LatLng(contact.location.latitude, contact.location.longitude),
                  zoom: 15.0,
                ),
                markers: {
                  Marker(
                    markerId: MarkerId(contact.name),
                    position: LatLng(contact.location.latitude, contact.location.longitude),
                    infoWindow: InfoWindow(
                      title: contact.name,
                      snippet: contact.address,
                    ),
                  ),
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
