// Automatic FlutterFlow imports
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/custom_code/widgets/index.dart'; // Imports other custom widgets
import '/flutter_flow/custom_functions.dart'; // Imports custom functions
import 'package:flutter/material.dart';
// Begin custom widget code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import 'package:crop_your_image/crop_your_image.dart';
import 'dart:typed_data';
import '/flutter_flow/upload_data.dart';

class ImageCropperWidget extends StatefulWidget {
  const ImageCropperWidget({
    Key? key,
    this.width,
    this.height,
    required this.inputImage,
    required this.onImageCropped,
  }) : super(key: key);

  final double? width;
  final double? height;
  final FFUploadedFile inputImage;
  final Future Function(FFUploadedFile croppedImage) onImageCropped;

  @override
  State<ImageCropperWidget> createState() => _ImageCropperWidgetState();
}

class _ImageCropperWidgetState extends State<ImageCropperWidget> {
  final _cropController = CropController();
  Uint8List? _imageData;
  Uint8List? _croppedImageBytes;
  bool _isLoading = true;
  bool _isCropping = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  Future<void> _loadImage() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Get bytes from FFUploadedFile
      final bytes = widget.inputImage.bytes;

      if (bytes != null && bytes.isNotEmpty) {
        setState(() {
          _imageData = bytes;
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'No image data available';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error loading image: $e';
        _isLoading = false;
      });
    }
  }

  void _cropImage() {
    setState(() => _isCropping = true);
    _cropController.cropCircle();
  }

  void _resetCrop() => setState(() => _croppedImageBytes = null);

  Future<void> _saveAndReturn() async {
    if (_croppedImageBytes == null) return;

    try {
      // Create a new FFUploadedFile with the cropped image
      final croppedFile = FFUploadedFile(
        name: widget.inputImage.name ?? 'cropped_image.png',
        bytes: _croppedImageBytes,
      );

      // Call the callback with the cropped image
      await widget.onImageCropped(croppedFile);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Image cropped successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Container(
        width: widget.width ?? double.infinity,
        height: widget.height ?? 500,
        color: Colors.black,
        child: const Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      );
    }

    if (_errorMessage != null || _imageData == null) {
      return Container(
        width: widget.width ?? double.infinity,
        height: widget.height ?? 500,
        color: Colors.black,
        child: Center(
          child: Text(
            _errorMessage ?? 'Failed to load image',
            style: const TextStyle(color: Colors.white),
          ),
        ),
      );
    }

    return Container(
      width: widget.width ?? double.infinity,
      height: widget.height ?? 500,
      decoration: const BoxDecoration(
        color: Colors.black,
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (_croppedImageBytes == null)
            Column(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Crop(
                      controller: _cropController,
                      image: _imageData!,
                      withCircleUi: true,
                      fixCropRect: true,
                      aspectRatio: 1,
                      maskColor: Colors.black.withOpacity(0.7),
                      interactive: true,
                      cornerDotBuilder: (size, edgeAlignment) =>
                          const SizedBox.shrink(),
                      onCropped: (result) {
                        switch (result) {
                          case CropSuccess(:final croppedImage):
                            setState(() {
                              _croppedImageBytes = croppedImage;
                              _isCropping = false;
                            });
                            break;
                          case CropFailure(:final cause):
                            setState(() => _isCropping = false);
                            debugPrint('Crop failed: $cause');
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Crop failed: $cause'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                            break;
                        }
                      },
                    ),
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
                  child: ElevatedButton(
                    onPressed: _isCropping ? null : _cropImage,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    child: Text(_isCropping ? 'Cropping...' : 'Continue'),
                  ),
                ),
              ],
            ),
          if (_croppedImageBytes != null)
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 200,
                  height: 200,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 20,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: Image.memory(_croppedImageBytes!, fit: BoxFit.cover),
                  ),
                ),
                const SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    OutlinedButton.icon(
                      onPressed: _resetCrop,
                      icon: const Icon(Icons.edit, size: 18),
                      label: const Text('Edit'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Colors.white70),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 12),
                      ),
                    ),
                    const SizedBox(width: 20),
                    ElevatedButton.icon(
                      onPressed: _saveAndReturn,
                      icon: const Icon(Icons.check, size: 18),
                      label: const Text('Save'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 30, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
        ],
      ),
    );
  }
}
