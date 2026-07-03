import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../providers/scan_provider.dart';
import '../theme/app_theme.dart';

class ImageCaptureScreen extends StatefulWidget {
  const ImageCaptureScreen({super.key});

  @override
  State<ImageCaptureScreen> createState() => _ImageCaptureScreenState();
}

class _ImageCaptureScreenState extends State<ImageCaptureScreen> {
  // 0 = tips, 1 = preview, 2 = validation
  int _step = 0;
  XFile? _imageFile;
  bool _fromCamera = false;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(ImageSource source) async {
    final XFile? file = await _picker.pickImage(
      source: source,
      imageQuality: 90,
      maxWidth: 1920,
    );
    if (file != null) {
      setState(() {
        _imageFile = file;
        _fromCamera = source == ImageSource.camera;
        _step = 1;
      });
    }
  }

  Future<void> _analyzeSelectedImage() async {
    final imageFile = _imageFile;
    if (imageFile == null) return;

    setState(() => _step = 2);

    final scanProvider = context.read<ScanProvider>();
    final imageAsset = await scanProvider.uploadImage(
      File(imageFile.path),
      'FRONT',
      fromCamera: _fromCamera,
    );

    if (!mounted) return;

    if (imageAsset != null &&
        scanProvider.currentAnalysis?.status == 'COMPLETED') {
      Navigator.pushReplacementNamed(context, '/results');
    }
  }

  void _showPickerSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Add Photo',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Take a Photo'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library_outlined),
                title: const Text('Choose from Gallery'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return PopScope(
      canPop: _step == 0,
      onPopInvoked: (didPop) {
        if (!didPop && _step > 0) {
          setState(() {
            _step--;
            if (_step == 0) _imageFile = null;
          });
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            _step == 0
                ? 'Capture Tips'
                : _step == 1
                    ? 'Review Photo'
                    : 'Validating...',
          ),
          leading: IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: () {
              if (_step > 0) {
                setState(() {
                  _step--;
                  if (_step == 0) _imageFile = null;
                });
              } else {
                if (Navigator.canPop(context)) {
                  Navigator.pop(context);
                } else {
                  Navigator.pushReplacementNamed(context, '/dashboard');
                }
              }
            },
          ),
        ),
        body: SafeArea(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: _step == 0
                ? _buildTips(theme)
                : _step == 1
                    ? _buildPreview(theme)
                    : _buildValidation(theme),
          ),
        ),
      ),
    );
  }

  Widget _buildTips(ThemeData theme) {
    final tips = [
      _Tip(Icons.medical_information_outlined, 'Use a Full Spine X-ray',
          'Choose a clear radiograph that shows the full continuous spine.'),
      _Tip(Icons.crop_free, 'Avoid Cropped Images',
          'Partial cervical, thoracic, or lumbar scans may be rejected by the ML service.'),
      _Tip(Icons.contrast, 'Clear Grayscale Image',
          'Use a readable X-ray image with visible vertebrae and minimal glare.'),
      _Tip(Icons.privacy_tip_outlined, 'Medical Review Required',
          'AI results are for support only and should be reviewed by a healthcare professional.'),
    ];

    return Column(
      children: [
        // Header
        Container(
          margin: const EdgeInsets.all(24),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                theme.colorScheme.primary.withOpacity(0.1),
                theme.colorScheme.secondary.withOpacity(0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              Icon(Icons.medical_information_outlined,
                  size: 48, color: theme.colorScheme.primary),
              const SizedBox(height: 12),
              Text('X-ray Analysis',
                  style: theme.textTheme.titleLarge
                      ?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(
                'Upload a full spine X-ray to run the ML analysis',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),

        // Tips list
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            itemCount: tips.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (_, i) {
              final tip = tips[i];
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? const Color(0xFF2D2340)
                      : const Color(0xFFF0ECF5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(tip.icon, color: theme.colorScheme.primary),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(tip.title,
                              style: theme.textTheme.titleSmall
                                  ?.copyWith(fontWeight: FontWeight.w600)),
                          const SizedBox(height: 2),
                          Text(tip.description,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              )),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),

        // Start button
        Padding(
          padding: const EdgeInsets.all(24),
          child: FilledButton.icon(
            onPressed: _showPickerSheet,
            icon: const Icon(Icons.add_a_photo),
            label: const Text('Add X-ray'),
          ),
        ),
      ],
    );
  }

  Widget _buildPreview(ThemeData theme) {
    return Column(
      children: [
        Expanded(
          child: Container(
            margin: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(16),
            ),
            clipBehavior: Clip.hardEdge,
            child: _imageFile != null
                ? Image.file(
                    File(_imageFile!.path),
                    fit: BoxFit.contain,
                    width: double.infinity,
                    height: double.infinity,
                  )
                : Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.image_outlined,
                            size: 48, color: Colors.grey[600]),
                        const SizedBox(height: 8),
                        Text('No photo selected',
                            style: TextStyle(color: Colors.grey[400])),
                      ],
                    ),
                  ),
          ),
        ),

        // Action buttons
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Gallery
              GestureDetector(
                onTap: () => _pickImage(ImageSource.gallery),
                child: Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? const Color(0xFF2D2340)
                        : const Color(0xFFF0ECF5),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.photo_library_outlined),
                ),
              ),

              // Re-take / Take Photo
              GestureDetector(
                onTap: () => _pickImage(ImageSource.camera),
                child: Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border:
                        Border.all(color: theme.colorScheme.primary, width: 4),
                  ),
                  child: Container(
                    margin: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.camera_alt,
                        color: Colors.white, size: 24),
                  ),
                ),
              ),

              // Placeholder to balance layout
              const SizedBox(width: 52, height: 52),
            ],
          ),
        ),

        // Analyze button — only shown when an image is ready
        if (_imageFile != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
            child: FilledButton.icon(
              onPressed: _analyzeSelectedImage,
              icon: const Icon(Icons.analytics),
              label: const Text('Analyze X-ray'),
            ),
          )
        else
          const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildValidation(ThemeData theme) {
    return Consumer<ScanProvider>(
      builder: (context, scanProvider, _) {
        final analysis = scanProvider.currentAnalysis;
        final error = scanProvider.errorMessage ?? analysis?.errorMessage;
        final isDone = analysis?.status == 'COMPLETED';
        final isFailed = error != null || analysis?.status == 'FAILED';

        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: (isFailed ? Colors.red : theme.colorScheme.primary)
                    .withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: isDone
                    ? Icon(Icons.check_circle,
                        color: AppTheme.success, size: 64)
                    : isFailed
                        ? const Icon(Icons.error_outline,
                            color: Colors.red, size: 64)
                        : SizedBox(
                            width: 64,
                            height: 64,
                            child: CircularProgressIndicator(
                              color: theme.colorScheme.primary,
                              strokeWidth: 3,
                            ),
                          ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              isFailed
                  ? 'Analysis Failed'
                  : isDone
                      ? 'Analysis Complete'
                      : 'Analyzing X-ray...',
              style: theme.textTheme.titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                isFailed
                    ? error ?? 'The ML service could not analyze this image.'
                    : isDone
                        ? 'Your spine analysis is ready.'
                        : 'The backend is sending your X-ray to the ML service.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 32),
            _ValidationCheck(
                'Image upload', scanProvider.currentImage != null, theme),
            const SizedBox(height: 12),
            _ValidationCheck(
                'ML service processing', isDone || isFailed, theme),
            const SizedBox(height: 12),
            _ValidationCheck('Curvature analysis', isDone, theme),
            const SizedBox(height: 32),
            if (isDone)
              FilledButton(
                onPressed: () =>
                    Navigator.pushReplacementNamed(context, '/results'),
                child: const Text('View Results'),
              )
            else if (isFailed)
              FilledButton.icon(
                onPressed: () => setState(() => _step = 1),
                icon: const Icon(Icons.refresh),
                label: const Text('Try Another Image'),
              ),
          ],
        );
      },
    );
  }
}

class _Tip {
  final IconData icon;
  final String title;
  final String description;
  const _Tip(this.icon, this.title, this.description);
}

class _ValidationCheck extends StatelessWidget {
  final String label;
  final bool done;
  final ThemeData theme;

  const _ValidationCheck(this.label, this.done, this.theme);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 48),
      child: Row(
        children: [
          if (done)
            Icon(Icons.check_circle, color: AppTheme.success, size: 24)
          else
            SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: theme.colorScheme.primary,
              ),
            ),
          const SizedBox(width: 12),
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: done
                  ? theme.colorScheme.onSurface
                  : theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
