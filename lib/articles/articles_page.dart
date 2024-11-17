import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'add_article_page.dart';
import 'article.dart';
import 'article_tile.dart';

class ArticlesPage extends StatefulWidget {
  final bool isDoctor;

  const ArticlesPage({super.key,
    required this.isDoctor,
  });

  @override
  _ArticlesPageState createState() => _ArticlesPageState();
}

class _ArticlesPageState extends State<ArticlesPage> {
  List<Article> _articles = [];
  List<Article> _filteredArticles = [];
  String? _selectedTag;
  bool _sortAscending = true;
  String _searchQuery = "";

  @override
  void initState() {
    super.initState();
    _loadArticles();
  }

  void _searchArticles(String query) {
    setState(() {
      _searchQuery = query;
      _applyFilters();
    });
  }

  void _applyFilters() {
    List<Article> filtered = _articles;

    if (_selectedTag != null && _selectedTag!.isNotEmpty) {
      filtered = filtered.where((article) => article.tags.contains(_selectedTag)).toList();
    }

    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((article) => article.title.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
    }

    setState(() {
      _filteredArticles = filtered;
    });
  }

  Future<void> _loadArticles() async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('articles')
        .orderBy('date', descending: !_sortAscending)
        .get();

    setState(() {
      _articles = querySnapshot.docs.map((doc) => Article.fromDocument(doc)).toList();
      _applyFilters();
    });
  }

  void _filterByTag(String? tag) {
    setState(() {
      _selectedTag = tag;
      if (tag == null || tag.isEmpty) {
        _filteredArticles = _articles;
      } else {
        _filteredArticles = _articles.where((article) => article.tags.contains(tag)).toList();
      }
    });
  }

  void _sortArticles() {
    setState(() {
      _sortAscending = !_sortAscending;
      _articles.sort((a, b) => _sortAscending
          ? a.date.compareTo(b.date)
          : b.date.compareTo(a.date));
      _filterByTag(_selectedTag);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Articles',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF8BACA5),
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
                ..._articles
                    .expand((article) => article.tags)
                    .toSet()
                    .map((tag) => PopupMenuItem<String>(
                  value: tag,
                  child: Text(tag),
                ))
              ];
            },
          ),
          IconButton(
            icon: Icon(
                _sortAscending ? Icons.arrow_downward : Icons.arrow_upward),
            onPressed: _sortArticles,
          ),
        ],
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        color: const Color(0xFFF5F5F5),
        child: Column(
          children: [
            const SizedBox(height: 6),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    spreadRadius: 2,
                    blurRadius: 5,
                  ),
                ],
              ),
              child: TextField(
                onChanged: _searchArticles,
                decoration: const InputDecoration(
                  hintText: 'Search by article title...',
                  border: InputBorder.none,
                  prefixIcon: Icon(Icons.search, color: Colors.grey),
                  contentPadding: EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                itemCount: _filteredArticles.length,
                itemBuilder: (context, index) {
                  return ArticleTile(article: _filteredArticles[index]);
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: widget.isDoctor
          ? FloatingActionButton(
        backgroundColor: const Color(0xFF8BACA5),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddArticlePage(),
            ),
          );
        },
        child: const Icon(Icons.add, color: Colors.white),
      )
          : null,
    );
  }
}

