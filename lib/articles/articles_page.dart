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

  @override
  void initState() {
    super.initState();
    _loadArticles();
  }

  Future<void> _loadArticles() async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('articles')
        .orderBy('date', descending: !_sortAscending)
        .get();

    setState(() {
      _articles = querySnapshot.docs.map((doc) => Article.fromDocument(doc)).toList();
      _filteredArticles = _articles;
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
      _filterByTag(_selectedTag);  // Reapply the filter after sorting
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Articles'),
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
            icon: Icon(_sortAscending ? Icons.arrow_downward : Icons.arrow_upward),
            onPressed: _sortArticles,
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: _filteredArticles.length,
        itemBuilder: (context, index) {
          return ArticleTile(article: _filteredArticles[index]);
        },
      ),
      floatingActionButton: widget.isDoctor
          ? FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddArticlePage(),
            ),
          );
        },
        child: const Icon(Icons.add),
      )
          : null,  // FAB is only shown if isDoctor is true
    );
  }
}

