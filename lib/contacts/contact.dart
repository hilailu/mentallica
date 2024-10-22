import 'package:cloud_firestore/cloud_firestore.dart';

class Contact {
  final String id;
  final String name;
  final String address;
  final GeoPoint location;

  Contact({
    required this.id,
    required this.name,
    required this.address,
    required this.location,
  });

  factory Contact.fromDocument(DocumentSnapshot doc) {
    return Contact(
      id: doc.id,
      name: doc['name'],
      address: doc['address'],
      location: doc['location'],
    );
  }
}