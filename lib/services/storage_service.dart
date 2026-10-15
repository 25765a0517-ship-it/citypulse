import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'firebase_service.dart';

class StorageService {
  Future<String> uploadComplaintImage({
    required String complaintId,
    required File imageFile,
  }) async {
    try {
      if (FirebaseService.isInitialized) {
        final fileName = 'complaint_${complaintId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
        final ref = FirebaseStorage.instance.ref().child('complaints').child(complaintId).child(fileName);
        final uploadTask = await ref.putFile(imageFile);
        final downloadUrl = await uploadTask.ref.getDownloadURL();
        return downloadUrl;
      }
    } catch (e) {
      debugPrint('[StorageService] Firebase Storage upload fallback: $e');
    }
    // Return local file path or mock storage url
    return imageFile.path;
  }

  Future<String> uploadResolutionImage({
    required String complaintId,
    required File imageFile,
  }) async {
    try {
      if (FirebaseService.isInitialized) {
        final fileName = 'resolution_${complaintId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
        final ref = FirebaseStorage.instance.ref().child('resolutions').child(complaintId).child(fileName);
        final uploadTask = await ref.putFile(imageFile);
        final downloadUrl = await uploadTask.ref.getDownloadURL();
        return downloadUrl;
      }
    } catch (e) {
      debugPrint('[StorageService] Firebase Storage resolution upload fallback: $e');
    }
    return imageFile.path;
  }
}
