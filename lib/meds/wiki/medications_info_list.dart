import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'medication_tile.dart';
import 'medication_wiki.dart';

class MedicationsInfoPage extends StatefulWidget {
  @override
  _MedicationsInfoPageState createState() => _MedicationsInfoPageState();
}

class _MedicationsInfoPageState extends State<MedicationsInfoPage> {
  List<MedicationWiki> _medications = [];
  List<MedicationWiki> _filteredMedications = [];
  String? _selectedTag;
  bool _sortAscending = true;
  String _searchQuery = "";

  @override
  void initState() {
    super.initState();
    _loadMedications();
  }

  Future<void> _loadMedications() async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('medications_wiki')
        .orderBy('name', descending: !_sortAscending)
        .get();

    setState(() {
      _medications = querySnapshot.docs.map((doc) => MedicationWiki.fromDocument(doc)).toList();
      _filteredMedications = _medications;
    });
  }

  void _filterByTag(String? tag) {
    setState(() {
      _selectedTag = tag;
      _applyFilters();
    });
  }

  void _applyFilters() {
    List<MedicationWiki> filtered = _medications;

    if (_selectedTag != null && _selectedTag!.isNotEmpty) {
      filtered = filtered.where((med) => med.tags.contains(_selectedTag)).toList();
    }

    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((med) => med.name.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
    }

    setState(() {
      _filteredMedications = filtered;
    });
  }

  void _sortMedications() {
    setState(() {
      _sortAscending = !_sortAscending;
      _medications.sort((a, b) => _sortAscending
          ? a.name.compareTo(b.name)
          : b.name.compareTo(a.name));
      _applyFilters();  // Reapply the filter after sorting
    });
  }

  void _searchMedications(String query) {
    setState(() {
      _searchQuery = query;
      _applyFilters();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Medications'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'All') {
                _filterByTag(null);
              } else {
                _filterByTag(value);
              }
            },
            itemBuilder: (context) {
              return <PopupMenuEntry<String>>[
                const PopupMenuItem<String>(
                  value: 'All',
                  child: Text('All'),
                ),
                ..._medications
                    .expand((med) => med.tags)
                    .toSet()
                    .map((tag) => PopupMenuItem<String>(
                  value: tag,
                  child: Text(tag),
                )),
              ];
            },
          ),
          IconButton(
            icon: Icon(_sortAscending ? Icons.arrow_downward : Icons.arrow_upward),
            onPressed: _sortMedications,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              onChanged: _searchMedications,
              decoration: const InputDecoration(
                hintText: 'Search by medication name...',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _filteredMedications.length,
              itemBuilder: (context, index) {
                return MedicationTile(medication: _filteredMedications[index]);
              },
            ),
          ),
        ],
      ),
    );
  }
}
