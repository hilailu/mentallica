import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'contact.dart';
import 'contact_detail.dart';

class ContactsPage extends StatefulWidget {
  const ContactsPage({super.key});

  @override
  _ContactsPageState createState() => _ContactsPageState();
}

class _ContactsPageState extends State<ContactsPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Contact> _contacts = [];
  Position? _currentPosition;
  bool _permissionDenied = false;
  bool _showMap = true;
  late GoogleMapController _mapController;

  @override
  void initState() {
    super.initState();
    _loadContacts();
    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() {
          _permissionDenied = true;
        });
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      setState(() {
        _permissionDenied = true;
      });
      return;
    }

    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      setState(() {
        _currentPosition = position;
      });
    } catch (e) {
      setState(() {
        _permissionDenied = true;
      });
    }
  }

  Future<void> _loadContacts() async {
    QuerySnapshot snapshot = await _firestore.collection('contacts').get();
    setState(() {
      _contacts = snapshot.docs
          .map((doc) => Contact.fromDocument(doc))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_permissionDenied) {
      return Scaffold(
        appBar: AppBar(title: const Text('Contacts')),
        body: Center(
          child: Text(
            'Please enable location services to use this feature.',
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    if (_currentPosition == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Contacts')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    _contacts.sort((a, b) => _calculateDistance(a).compareTo(_calculateDistance(b)));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Contacts'),
        actions: [
          IconButton(
            icon: Icon(_showMap ? Icons.list : Icons.map),
            onPressed: () {
              setState(() {
                _showMap = !_showMap;
              });
            },
          ),
        ],
      ),
      body: _showMap ? _buildMap() : _buildList(),
    );
  }

  Widget _buildMap() {
    Set<Marker> markers = _contacts.map((contact) {
      return Marker(
        markerId: MarkerId(contact.name),
        position: LatLng(contact.location.latitude, contact.location.longitude),
        infoWindow: InfoWindow(
          title: contact.name,
          snippet: contact.address,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ContactDetailsPage(contact: contact),
              ),
            );
          },
        ),
      );
    }).toSet();

    return GoogleMap(
      onMapCreated: (controller) {
        _mapController = controller;
      },
      initialCameraPosition: CameraPosition(
        target: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
        zoom: 11.0,
      ),
      markers: markers,
    );
  }

  Widget _buildList() {
    return ListView.builder(
      itemCount: _contacts.length,
      itemBuilder: (context, index) {
        final contact = _contacts[index];
        final distance = _calculateDistance(contact);

        return ListTile(
          title: Text(contact.name),
          subtitle: Text(contact.address),
          trailing: Text('${distance.toStringAsFixed(2)} km'),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ContactDetailsPage(contact: contact),
              ),
            );
          },
        );
      },
    );
  }

  double _calculateDistance(Contact contact) {
    if (_currentPosition == null) return 0.0;
    return Geolocator.distanceBetween(
      _currentPosition!.latitude,
      _currentPosition!.longitude,
      contact.location.latitude,
      contact.location.longitude,
    ) / 1000; // Distance in kilometers
  }
}
