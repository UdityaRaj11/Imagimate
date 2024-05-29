import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import './story.dart';

class Stories with ChangeNotifier {
  List<Story> _items = [];
  List<Story> get items {
    return [..._items];
  }

  Future<void> fetchAndSetStories() async {
    try {
      FirebaseStorage storage = FirebaseStorage.instance;
      QuerySnapshot storiesSnap =
          await FirebaseFirestore.instance.collection('stories').get();
      final List<Story> loadedStories = [];
      for (var story in storiesSnap.docs) {
        Reference ref = storage.ref().child(story['imageUrl'].toString());
        Reference audioRef = storage.ref().child(story['audio'].toString());
        String downloadURL = await ref.getDownloadURL();
        String audioURL = await audioRef.getDownloadURL();
        loadedStories.add(Story(
          heading: story['heading'],
          text: story['text'],
          type: story['type'],
          audio: audioURL,
          imageUrl: downloadURL,
        ));
      }
      _items = loadedStories;
      print(_items[0].heading);
      notifyListeners();
    } catch (error) {
      rethrow;
    }
  }

  List<Story> getStoriesForCategory(String category) {
    print("lets go");
    switch (category.toLowerCase()) {
      case 'adventure':
        print(Stories().items);
        return _items.where((story) => story.type == 'adventure').toList();
      case 'fantasy':
        return _items.where((story) => story.type == 'fantasy').toList();
      case 'animal':
        return _items.where((story) => story.type == 'animal').toList();
      case 'horror':
        return _items.where((story) => story.type == 'horror').toList();
      case 'mystery':
        return _items.where((story) => story.type == 'mystery').toList();
      case 'educational':
        return _items.where((story) => story.type == 'educational').toList();
      case 'bedtime':
        return _items.where((story) => story.type == 'bedtime').toList();
      case 'fairy tales':
        return _items.where((story) => story.type == 'fairy tales').toList();
      default:
        return [];
    }
  }
}
