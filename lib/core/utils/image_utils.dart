import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import 'package:image_cropper/image_cropper.dart';
import '../theme/app_colors.dart';
import '../localization/app_localizations.dart';

/// Utility class for image operations
class ImageUtils {
  static const int maxFileSizeBytes = 1024 * 1024; // 1 MB
  static const int targetWidth = 800; // Target width for compression
  static const int jpegQuality = 85; // JPEG quality (0-100)

  /// Pick an image from gallery or camera
  static Future<XFile?> pickImage({
    ImageSource source = ImageSource.gallery,
  }) async {
    final picker = ImagePicker();
    return await picker.pickImage(
      source: source,
      maxWidth: 1920,
      maxHeight: 1920,
    );
  }

  /// Pick and crop an image
  static Future<CroppedFile?> pickAndCropImage({
    required BuildContext context,
    required ImageSource source,
    CropStyle cropStyle = CropStyle.circle,
    CropAspectRatio? aspectRatio,
    List<CropAspectRatioPreset>? aspectRatioPresets,
    String? toolbarTitle,
  }) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: source,
      maxWidth: 1920,
      maxHeight: 1920,
    );

    if (pickedFile == null) return null;
    if (!context.mounted) return null;

    return await cropImage(
      context: context,
      imagePath: pickedFile.path,
      cropStyle: cropStyle,
      aspectRatio: aspectRatio,
      aspectRatioPresets: aspectRatioPresets,
      toolbarTitle: toolbarTitle,
    );
  }

  /// Pick an image and ask user if they want to crop it
  /// Returns a record with the file path and whether it was cropped
  static Future<({String? path, bool wasCropped})?> pickImageWithCropConfirmation({
    required BuildContext context,
    required ImageSource source,
    CropStyle cropStyle = CropStyle.circle,
    CropAspectRatio? aspectRatio,
    List<CropAspectRatioPreset>? aspectRatioPresets,
    String? toolbarTitle,
  }) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: source,
      maxWidth: 1920,
      maxHeight: 1920,
    );

    if (pickedFile == null) return null;
    if (!context.mounted) return null;

    final l10n = AppLocalizations.of(context);
    
    // Show confirmation dialog
    final shouldCrop = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.cropImage),
        content: Text(l10n.cropImageConfirmation),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cropImageNo),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.cropImageYes),
          ),
        ],
      ),
    );

    if (shouldCrop == null) {
      // Dialog was dismissed
      return null;
    }

    if (!context.mounted) return null;

    if (shouldCrop) {
      // User wants to crop
      final croppedFile = await cropImage(
        context: context,
        imagePath: pickedFile.path,
        cropStyle: cropStyle,
        aspectRatio: aspectRatio,
        aspectRatioPresets: aspectRatioPresets,
        toolbarTitle: toolbarTitle,
      );
      
      if (croppedFile == null) return null;
      return (path: croppedFile.path, wasCropped: true);
    } else {
      // User wants to use image as-is
      return (path: pickedFile.path, wasCropped: false);
    }
  }

  /// Crop an existing image
  static Future<CroppedFile?> cropImage({
    required BuildContext context,
    required String imagePath,
    CropStyle cropStyle = CropStyle.circle,
    CropAspectRatio? aspectRatio,
    List<CropAspectRatioPreset>? aspectRatioPresets,
    String? toolbarTitle,
  }) async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final presets = aspectRatioPresets ?? [
      CropAspectRatioPreset.square,
      CropAspectRatioPreset.ratio3x2,
      CropAspectRatioPreset.original,
      CropAspectRatioPreset.ratio4x3,
      CropAspectRatioPreset.ratio16x9,
    ];
    
    return await ImageCropper().cropImage(
      sourcePath: imagePath,
      aspectRatio: aspectRatio,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: toolbarTitle ?? 'Crop Image',
          toolbarColor: isDark ? const Color(0xFF1C1C1E) : AppColors.primary,
          toolbarWidgetColor: Colors.white,
          backgroundColor: isDark ? const Color(0xFF000000) : Colors.white,
          activeControlsWidgetColor: AppColors.primary,
          initAspectRatio: CropAspectRatioPreset.square,
          lockAspectRatio: cropStyle == CropStyle.circle,
          hideBottomControls: false,
          dimmedLayerColor: Colors.black.withValues(alpha: 0.6),
          showCropGrid: true,
          cropGridColor: Colors.white.withValues(alpha: 0.5),
          cropFrameColor: AppColors.primary,
          cropGridRowCount: 3,
          cropGridColumnCount: 3,
          cropStyle: cropStyle,
          aspectRatioPresets: presets,
        ),
        IOSUiSettings(
          title: toolbarTitle ?? 'Crop Image',
          doneButtonTitle: 'Done',
          cancelButtonTitle: 'Cancel',
          aspectRatioLockEnabled: cropStyle == CropStyle.circle,
          resetAspectRatioEnabled: true,
          aspectRatioPickerButtonHidden: cropStyle == CropStyle.circle,
          rotateButtonsHidden: false,
          rotateClockwiseButtonHidden: true,
          hidesNavigationBar: false,
          resetButtonHidden: false,
          showActivitySheetOnDone: false,
          showCancelConfirmationDialog: true,
          cropStyle: cropStyle,
          aspectRatioPresets: presets,
        ),
      ],
    );
  }

  /// Compress image to be under 1MB and convert to base64
  static Future<String?> compressAndConvertToBase64(XFile file) async {
    try {
      // Read file bytes
      final bytes = await file.readAsBytes();
      
      // Check if already under 1MB
      if (bytes.length <= maxFileSizeBytes) {
        return base64Encode(bytes);
      }
      
      // Compress the image
      final compressedBytes = await compute(_compressImage, bytes);
      
      if (compressedBytes != null) {
        return base64Encode(compressedBytes);
      }
      
      return null;
    } catch (e) {
      debugPrint('Error compressing image: $e');
      return null;
    }
  }

  /// Compress cropped image to be under 1MB and convert to base64
  static Future<String?> compressCroppedAndConvertToBase64(CroppedFile file) async {
    try {
      // Read file bytes
      final bytes = await File(file.path).readAsBytes();
      
      // Check if already under 1MB
      if (bytes.length <= maxFileSizeBytes) {
        return base64Encode(bytes);
      }
      
      // Compress the image
      final compressedBytes = await compute(_compressImage, bytes);
      
      if (compressedBytes != null) {
        return base64Encode(compressedBytes);
      }
      
      return null;
    } catch (e) {
      debugPrint('Error compressing cropped image: $e');
      return null;
    }
  }

  /// Compress image bytes (runs in isolate)
  static Uint8List? _compressImage(Uint8List bytes) {
    try {
      // Decode the image
      final image = img.decodeImage(bytes);
      if (image == null) return null;

      // Calculate new dimensions maintaining aspect ratio
      int newWidth = targetWidth;
      int newHeight = (image.height * targetWidth / image.width).round();
      
      // Resize the image
      final resized = img.copyResize(
        image,
        width: newWidth,
        height: newHeight,
        interpolation: img.Interpolation.linear,
      );

      // Encode as JPEG with quality
      int quality = jpegQuality;
      Uint8List? result;
      
      // Try progressively lower quality until under 1MB
      while (quality >= 20) {
        result = Uint8List.fromList(img.encodeJpg(resized, quality: quality));
        if (result.length <= maxFileSizeBytes) {
          return result;
        }
        quality -= 10;
      }
      
      // If still too large, reduce dimensions further
      int scale = 2;
      while (scale <= 4) {
        final smallerWidth = targetWidth ~/ scale;
        final smallerHeight = (image.height * smallerWidth / image.width).round();
        
        final smaller = img.copyResize(
          image,
          width: smallerWidth,
          height: smallerHeight,
          interpolation: img.Interpolation.linear,
        );
        
        result = Uint8List.fromList(img.encodeJpg(smaller, quality: 70));
        if (result.length <= maxFileSizeBytes) {
          return result;
        }
        scale++;
      }
      
      return result;
    } catch (e) {
      debugPrint('Error in _compressImage: $e');
      return null;
    }
  }

  /// Convert base64 string to image bytes
  static Uint8List? base64ToBytes(String base64String) {
    try {
      return base64Decode(base64String);
    } catch (e) {
      debugPrint('Error decoding base64: $e');
      return null;
    }
  }

  /// Check if a string is valid base64
  static bool isValidBase64(String? value) {
    if (value == null || value.isEmpty) return false;
    try {
      base64Decode(value);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Get file size in MB from bytes
  static double bytesToMB(int bytes) {
    return bytes / (1024 * 1024);
  }

  /// Format file size for display
  static String formatFileSize(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    } else {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
    }
  }
}
