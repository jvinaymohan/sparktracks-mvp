import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

/// Service for handling image uploads to Firebase Storage
class ImageUploadService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _picker = ImagePicker();

  /// Pick an image from gallery or camera
  Future<XFile?> pickImage({ImageSource source = ImageSource.gallery}) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );
      return image;
    } catch (e) {
      throw Exception('Failed to pick image: $e');
    }
  }

  /// Upload image to Firebase Storage
  /// Returns the download URL of the uploaded image
  Future<String> uploadImage({
    required XFile imageFile,
    required String path,
    Function(double)? onProgress,
  }) async {
    try {
      final String fileName = '${DateTime.now().millisecondsSinceEpoch}_${imageFile.name}';
      final Reference ref = _storage.ref().child(path).child(fileName);

      UploadTask uploadTask;
      
      if (kIsWeb) {
        // For web, read as bytes
        final bytes = await imageFile.readAsBytes();
        uploadTask = ref.putData(
          bytes,
          SettableMetadata(contentType: 'image/jpeg'),
        );
      } else {
        // For mobile, use file
        uploadTask = ref.putFile(File(imageFile.path));
      }

      // Listen to upload progress
      if (onProgress != null) {
        uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
          final progress = snapshot.bytesTransferred / snapshot.totalBytes;
          onProgress(progress);
        });
      }

      // Wait for upload to complete
      final TaskSnapshot snapshot = await uploadTask;
      
      // Get download URL
      final String downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      throw Exception('Failed to upload image: $e');
    }
  }

  /// Delete image from Firebase Storage
  Future<void> deleteImage(String imageUrl) async {
    try {
      final Reference ref = _storage.refFromURL(imageUrl);
      await ref.delete();
    } catch (e) {
      throw Exception('Failed to delete image: $e');
    }
  }

  /// Upload profile photo for a user
  Future<String> uploadProfilePhoto({
    required String userId,
    required XFile imageFile,
    Function(double)? onProgress,
  }) async {
    return await uploadImage(
      imageFile: imageFile,
      path: 'profile_photos/$userId',
      onProgress: onProgress,
    );
  }

  /// Upload class image
  Future<String> uploadClassImage({
    required String classId,
    required XFile imageFile,
    Function(double)? onProgress,
  }) async {
    return await uploadImage(
      imageFile: imageFile,
      path: 'class_images/$classId',
      onProgress: onProgress,
    );
  }

  /// Upload gallery photo for coach profile
  Future<String> uploadGalleryPhoto({
    required String userId,
    required XFile imageFile,
    Function(double)? onProgress,
  }) async {
    return await uploadImage(
      imageFile: imageFile,
      path: 'gallery_photos/$userId',
      onProgress: onProgress,
    );
  }

  /// Pick and upload gallery photo in one step
  Future<String?> pickAndUploadGalleryPhoto({
    required String userId,
    ImageSource source = ImageSource.gallery,
    Function(double)? onProgress,
  }) async {
    try {
      final XFile? image = await pickImage(source: source);
      if (image == null) return null;
      
      final String url = await uploadGalleryPhoto(
        userId: userId,
        imageFile: image,
        onProgress: onProgress,
      );
      
      return url;
    } catch (e) {
      throw Exception('Failed to pick and upload gallery photo: $e');
    }
  }

  /// Upload multiple images
  Future<List<String>> uploadMultipleImages({
    required List<XFile> imageFiles,
    required String path,
    Function(int current, int total)? onProgress,
  }) async {
    final List<String> urls = [];
    
    for (int i = 0; i < imageFiles.length; i++) {
      if (onProgress != null) {
        onProgress(i + 1, imageFiles.length);
      }
      
      final url = await uploadImage(
        imageFile: imageFiles[i],
        path: path,
      );
      urls.add(url);
    }
    
    return urls;
  }

  /// Pick and upload profile photo in one step
  Future<String?> pickAndUploadProfilePhoto({
    required String userId,
    ImageSource source = ImageSource.gallery,
    Function(double)? onProgress,
  }) async {
    try {
      final XFile? image = await pickImage(source: source);
      if (image == null) return null;
      
      final String url = await uploadProfilePhoto(
        userId: userId,
        imageFile: image,
        onProgress: onProgress,
      );
      
      return url;
    } catch (e) {
      throw Exception('Failed to pick and upload image: $e');
    }
  }

  /// Pick and upload class image in one step
  Future<String?> pickAndUploadClassImage({
    required String classId,
    ImageSource source = ImageSource.gallery,
    Function(double)? onProgress,
  }) async {
    try {
      final XFile? image = await pickImage(source: source);
      if (image == null) return null;
      
      final String url = await uploadClassImage(
        classId: classId,
        imageFile: image,
        onProgress: onProgress,
      );
      
      return url;
    } catch (e) {
      throw Exception('Failed to pick and upload class image: $e');
    }
  }

  /// Compress and resize image before upload
  Future<XFile?> compressImage(XFile imageFile) async {
    // Note: For production, you might want to use image compression packages
    // like flutter_image_compress for better optimization
    return imageFile;
  }
}

