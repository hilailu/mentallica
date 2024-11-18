import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AddArticlePage extends StatefulWidget {
  @override
  _AddArticlePageState createState() => _AddArticlePageState();
}

class _AddArticlePageState extends State<AddArticlePage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  List<String> _availableTags = ['Depression', 'Anxiety', 'Panic Attack', 'Stress', 'Meditation', 'Tips'];
  Set<String> _selectedTags = {};

  Future<void> _saveArticle() async {
    if (_titleController.text.isNotEmpty && _contentController.text.isNotEmpty) {
      await FirebaseFirestore.instance.collection('articles').add({
        'title': _titleController.text,
        'content': _contentController.text,
        'date': _selectedDate,
        'tags': _selectedTags.toList(),
      });

      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Article', style: TextStyle(fontWeight: FontWeight.bold),),
        backgroundColor: const Color(0xFF8BACA5),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                spreadRadius: 2,
                blurRadius: 5,
              ),
            ],
          ),
          padding: const EdgeInsets.all(16.0),
          child: ListView(
            children: [
              TextField(
                controller: _titleController,
                decoration: _roundedInputDecoration('Title')
              ),
              const SizedBox(height: 16),
              ListTile(
                title: const Text('Date'),
                subtitle: Text(
                    '${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}'),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) {
                    setState(() {
                      _selectedDate = picked;
                    });
                  }
                },
              ),
              const SizedBox(height: 10),
              const Text(' Tags', style: TextStyle(
                fontSize: 18.0,
                color: Colors.black87,
              ),),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8.0,
                children: _availableTags.map((tag) {
                  final selected = _selectedTags.contains(tag);
                  return ChoiceChip(
                    showCheckmark: false,
                    label: Text(tag),
                    selected: selected,
                    selectedColor: const Color(0xFF8BACA5),
                    onSelected: (bool selected) {
                      setState(() {
                        if (selected) {
                          _selectedTags.add(tag);
                        } else {
                          _selectedTags.remove(tag);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _contentController,
                maxLines: 15,
                decoration: _roundedInputDecoration('Article content...'),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _saveArticle,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8BACA5),
                ),
                child: const Text('Save', style: TextStyle(color: Colors.white),),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _roundedInputDecoration(String label) {
    return InputDecoration(
      filled: true,
      fillColor: Colors.grey.shade50,
      labelText: label,
      alignLabelWithHint: true,
      contentPadding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.0),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.0),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.0),
        borderSide: const BorderSide(color: Colors.blueAccent),
      ),
      hintStyle: const TextStyle(color: Colors.grey),
    );
  }
}
