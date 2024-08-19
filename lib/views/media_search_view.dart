import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/svg.dart';
import 'package:http/http.dart' as http;
import 'media_page.dart'; // Ensure this file imports correctly

class MediaSearchView extends StatefulWidget {
  const MediaSearchView({super.key});

  @override
  State<MediaSearchView> createState() => _MediaPAgeState();
}

class _MediaPAgeState extends State<MediaSearchView> {
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> _searchResults = [];
  bool _isLoading = false;
  String? _errorMessage;
  List<String> _recentSearches = []; // List to store recent search terms

  Future<void> _searchMedia(String query) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final String url = 'https://itunes.apple.com/search?term=$query';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _searchResults = data['results'];
          if (!_recentSearches.contains(query)) {
            _recentSearches.add(query); // Add query to recent searches
          }
        });

        // Navigate to the next screen with search results
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MediaPage(searchResults: _searchResults),
          ),
        );
      } else {
        setState(() {
          _errorMessage = 'Error fetching data. Please try again.';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Network error. Please try again.';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Setting background color to black
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  "images/1314162_apple_company_ios_logo_icon.png",
                  height: 62,
                  width: 50,
                  color: Colors.white,
                ),
                SizedBox(height: 5),
                Text(
                  'iTunes',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            Text(
              'Search for a variety of content from the iTunes store including iBooks, movies, podcasts, music, videos, and audiobooks.',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
              ),
            ),
            SizedBox(height: 30),
            TextField(
              controller: _searchController,
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.grey[800],
                hintText: '',
                hintStyle: TextStyle(color: Colors.white54),
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 25),
            Text(
              'Specify the parameter for the content to be searched.',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
              ),
            ),
            SizedBox(height: 8,),
             if (_recentSearches.isNotEmpty) 
              Wrap(
                spacing: 8.0,
                runSpacing: 4.0,
                children: _recentSearches.map((search) {
                  return Chip(
                    label: Text(search, style: TextStyle(color: Colors.white)),
                    backgroundColor: Colors.grey[800],
                    onDeleted: () {
                      setState(() {
                        _recentSearches.remove(search);
                      });
                    },
                    deleteIconColor: Colors.white,
                    // onSelected: () {
                    //   _searchController.text = search;
                    //   _searchMedia(search);
                    // },
                  );
                }).toList(),
              ),
              SizedBox(height: 25),
            ElevatedButton(
              onPressed: () async {
                final query = _searchController.text;
                if (query.isNotEmpty) {
                  await _searchMedia(query);
                }
              },
              child: Text(
                "Submit",
                style: TextStyle(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[800],
                minimumSize: Size(250, 55), // Width and Height
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            ),
            SizedBox(height: 20),
           
            if (_isLoading) CircularProgressIndicator(color: Colors.white),
            if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(top: 10.0),
                child: Text(
                  _errorMessage!,
                  style: TextStyle(color: Colors.red),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
