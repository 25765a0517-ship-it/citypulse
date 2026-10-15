import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants/app_constants.dart';
import '../core/errors/app_exceptions.dart';
import '../models/user_model.dart';
import 'firebase_service.dart';
import 'firestore_service.dart';

class AuthService {
  final FirestoreService _firestoreService;
  UserModel? _currentUser;
  final StreamController<UserModel?> _userStreamController = StreamController<UserModel?>.broadcast();

  AuthService(this._firestoreService);

  UserModel? get currentUser => _currentUser;
  Stream<UserModel?> authStateChanges() => _userStreamController.stream;
  bool get isAuthenticated => _currentUser != null;

  Future<void> initializeAuth() async {
    final prefs = await SharedPreferences.getInstance();
    final savedUid = prefs.getString(AppConstants.keyUserId);

    if (savedUid != null) {
      final user = await _firestoreService.getUser(savedUid);
      if (user != null) {
        _currentUser = user;
        _userStreamController.add(_currentUser);
        return;
      }
    }

    if (FirebaseService.isInitialized) {
      final fbUser = FirebaseAuth.instance.currentUser;
      if (fbUser != null) {
        final profile = await _firestoreService.getUser(fbUser.uid);
        _currentUser = profile ?? UserModel(
          uid: fbUser.uid,
          name: fbUser.displayName ?? 'Citizen',
          email: fbUser.email ?? '',
          role: UserRole.citizen,
        );
        _userStreamController.add(_currentUser);
      }
    }
  }

  Future<UserModel> register({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    try {
      String uid = 'user_${DateTime.now().millisecondsSinceEpoch}';

      if (FirebaseService.isInitialized) {
        try {
          final cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
            email: email.trim(),
            password: password,
          );
          if (cred.user != null) {
            uid = cred.user!.uid;
            await cred.user!.updateDisplayName(name.trim());
          }
        } on FirebaseAuthException catch (e) {
          throw AuthException(_mapFirebaseAuthError(e.code));
        }
      }

      // Role is ALWAYS citizen on registration as per security specifications
      final newUser = UserModel(
        uid: uid,
        name: name.trim(),
        email: email.trim().toLowerCase(),
        phone: phone.trim(),
        role: UserRole.citizen,
        ward: 'Ward 4 • Downtown North',
        createdAt: DateTime.now(),
      );

      await _firestoreService.saveUser(newUser);

      _currentUser = newUser;
      _userStreamController.add(_currentUser);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(AppConstants.keyUserId, uid);
      await prefs.setString(AppConstants.keyUserRole, newUser.role.toValue());

      return newUser;
    } catch (e) {
      if (e is AuthException) rethrow;
      throw AuthException(e.toString());
    }
  }

  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    try {
      final cleanEmail = email.trim().toLowerCase();

      // Check pre-configured civic demo accounts for quick testing & evaluation
      if (cleanEmail == 'citizen@citypulse.gov' || cleanEmail == 'alex@citypulse.gov') {
        final user = await _firestoreService.getUser('citizen_101');
        _currentUser = user;
        _userStreamController.add(_currentUser);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(AppConstants.keyUserId, user!.uid);
        return user;
      } else if (cleanEmail == 'officer@citypulse.gov' || cleanEmail == 'marcus@citypulse.gov') {
        final user = await _firestoreService.getUser('officer_202');
        _currentUser = user;
        _userStreamController.add(_currentUser);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(AppConstants.keyUserId, user!.uid);
        return user;
      } else if (cleanEmail == 'admin@citypulse.gov' || cleanEmail == 'director@citypulse.gov') {
        final user = await _firestoreService.getUser('admin_303');
        _currentUser = user;
        _userStreamController.add(_currentUser);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(AppConstants.keyUserId, user!.uid);
        return user;
      }

      if (FirebaseService.isInitialized) {
        try {
          final cred = await FirebaseAuth.instance.signInWithEmailAndPassword(
            email: cleanEmail,
            password: password,
          );
          if (cred.user != null) {
            final profile = await _firestoreService.getUser(cred.user!.uid);
            if (profile != null) {
              _currentUser = profile;
              _userStreamController.add(_currentUser);
              final prefs = await SharedPreferences.getInstance();
              await prefs.setString(AppConstants.keyUserId, profile.uid);
              return profile;
            }
          }
        } on FirebaseAuthException catch (e) {
          throw AuthException(_mapFirebaseAuthError(e.code));
        }
      }

      // Check registered users in Firestore service
      final all = await _firestoreService.getAllUsers();
      final match = all.firstWhere(
        (u) => u.email.toLowerCase() == cleanEmail,
        orElse: () => throw AuthException('No account found with this email. Please check or register.'),
      );

      _currentUser = match;
      _userStreamController.add(_currentUser);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(AppConstants.keyUserId, match.uid);
      return match;
    } catch (e) {
      if (e is AuthException) rethrow;
      throw AuthException(e.toString());
    }
  }

  Future<void> logout() async {
    try {
      if (FirebaseService.isInitialized) {
        await FirebaseAuth.instance.signOut();
      }
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(AppConstants.keyUserId);
      await prefs.remove(AppConstants.keyUserRole);
      _currentUser = null;
      _userStreamController.add(null);
    } catch (e) {
      debugPrint('[AuthService] Logout error: $e');
    }
  }

  Future<void> resetPassword(String email) async {
    try {
      if (FirebaseService.isInitialized) {
        await FirebaseAuth.instance.sendPasswordResetEmail(email: email.trim());
      }
    } catch (e) {
      debugPrint('[AuthService] Reset password note: $e');
    }
  }

  // Quick switch for development / testing demonstration across roles
  Future<void> switchDemoRole(UserRole role) async {
    if (role == UserRole.citizen) {
      _currentUser = await _firestoreService.getUser('citizen_101');
    } else if (role == UserRole.officer) {
      _currentUser = await _firestoreService.getUser('officer_202');
    } else {
      _currentUser = await _firestoreService.getUser('admin_303');
    }
    _userStreamController.add(_currentUser);
  }

  String _mapFirebaseAuthError(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No user found with this email address.';
      case 'wrong-password':
      case 'invalid-credential':
        return 'Incorrect password. Please try again.';
      case 'email-already-in-use':
        return 'This email address is already registered.';
      case 'invalid-email':
        return 'The email address is improperly formatted.';
      case 'weak-password':
        return 'The password provided is too weak (minimum 6 characters).';
      case 'network-request-failed':
        return 'Network connection failed. Please check your connectivity.';
      default:
        return 'Authentication failed: $code';
    }
  }
}
