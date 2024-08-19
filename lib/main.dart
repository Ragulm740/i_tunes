import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:i_tunes/views/media_search_view.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'iTunes Media Search',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MediaSearchView(),
    );
  }
}

