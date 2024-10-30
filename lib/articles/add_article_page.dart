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
        title: const Text('Add New Article'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            // Title Field
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
              ),
            ),

            // Date Picker
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

            const SizedBox(height: 16),

            // Tags (Choice Chips)
            const Text('Tags'),
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
            const Text('Article Content'),
            const SizedBox(height: 10),

            // Content Field
            TextField(
              controller: _contentController,
              maxLines: 15,
              decoration: const InputDecoration(
                alignLabelWithHint: true,
                labelText: 'Content',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _saveArticle,
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}
