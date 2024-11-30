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
        appBar: AppBar(title: const Text(
          'Контакты',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),),
        backgroundColor: const Color(0xFF8BACA5),
        body: Center(
          child: Text(
            'Пожалуйста, разрешите использование геолокации для использования данной функции.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.grey[700]),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    if (_currentPosition == null) {
      return Scaffold(
        appBar: AppBar(title: const Text(
          'Контакты',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
          backgroundColor: const Color(0xFF8BACA5),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    _contacts.sort((a, b) => _calculateDistance(a).compareTo(_calculateDistance(b)));

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Контакты',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF8BACA5),
        actions: [
          IconButton(
            icon: Icon(_showMap ? Icons.list_alt : Icons.map, size: 28),
            tooltip: _showMap ? 'Переключиться на список' : 'Переключиться на карту',
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

  Widget _buildList() {
    return ListView.separated(
      itemCount: _contacts.length,
      separatorBuilder: (context, index) => Divider(color: Colors.grey[300]),
      itemBuilder: (context, index) {
        final contact = _contacts[index];
        final distance = _calculateDistance(contact);

        return ListTile(
          leading: const Icon(Icons.person_pin_circle, color: Color(0xFF8BACA5), size: 40),
          title: Text(contact.name, style: Theme.of(context).textTheme.bodyLarge),
          subtitle: Text(contact.address),
          trailing: Chip(
            label: Text('${distance.toStringAsFixed(2)} км', style: const TextStyle(fontSize: 14, color: Colors.white)),
            backgroundColor: const Color(0xFF8BACA5),
          ),
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
