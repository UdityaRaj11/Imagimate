import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'app_user.dart';

class UserData with ChangeNotifier {
  AppUser? _user;

  AppUser? get user {
    return _user;
  }

  Future<void> fetchAndSetUser() async {
    try {
      FirebaseAuth auth = FirebaseAuth.instance;
      final userData = await FirebaseFirestore.instance
          .collection('user')
          .doc(auth.currentUser!.uid)
          .get();
      _user = AppUser(
        username: userData['username'],
        email: auth.currentUser!.email,
        imageUrl: userData['image_url'],
      );
      print(_user!.username);
      notifyListeners();
    } catch (error) {
      rethrow;
    }
  }
}
