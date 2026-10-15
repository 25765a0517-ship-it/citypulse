import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';

class FirebaseService {
  static bool _isInitialized = false;
  static bool get isInitialized => _isInitialized;

  static Future<void> initialize() async {
    try {
      if (Firebase.apps.isNotEmpty) {
        _isInitialized = true;
        return;
      }
      // Attempt default platform Firebase initialize
      await Firebase.initializeApp();
      _isInitialized = true;
      debugPrint('[FirebaseService] Firebase initialized successfully');
    } catch (e) {
      // Gracefully fall back to local offline storage persistence for demo & development
      _isInitialized = false;
      debugPrint('[FirebaseService] Notice: Firebase initialization bypassed ($e). Operating in robust hybrid offline/local mode.');
    }
  }
}
