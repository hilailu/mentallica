import 'package:cloud_firestore/cloud_firestore.dart';

class Contact {
  final String name;
  final String address;
  final GeoPoint location;

  Contact({
    required this.name,
    required this.address,
    required this.location,
  });

  factory Contact.fromDocument(DocumentSnapshot doc) {
    return Contact(
      name: doc['name'],
      address: doc['address'],
      location: doc['location'],
    );
  }
}