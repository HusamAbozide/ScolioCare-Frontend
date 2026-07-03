import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../providers/posture_provider.dart';
import '../providers/auth_provider.dart';
import '../models/posture_photo.dart';
import '../theme/app_theme.dart';

class PostureTrackingScreen extends StatefulWidget {
  const PostureTrackingScreen({Key? key}) : super(key: key);

  @override
  State<PostureTrackingScreen> createState() => _PostureTrackingScreenState();
}

class _PostureTrackingScreenState extends State<PostureTrackingScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ImagePicker _imagePicker = ImagePicker();
  String _selectedViewAngle = 'FRONT';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final authProvider = context.read<AuthProvider>();
    final postureProvider = context.read<PostureProvider>();

    if (authProvider.userId != null) {
      await Future.wait([
        postureProvider.fetchUserPhotos(authProvider.userId!),
        postureProvider.fetchUserComparisons(authProvider.userId!),
      ]);
    }
  }

  Future<void> _capturePhoto() async {
    try {
      // Show dialog to select view angle
      final viewAngle = await showDialog<String>(
        context: context,
        builder: (context) => _ViewAngleDialog(
          selectedAngle: _selectedViewAngle,
        ),
      );

      if (viewAngle == null) return;
      _selectedViewAngle = viewAngle;

      // Show options: camera or gallery
      final source = await showDialog<ImageSource>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Select Photo Source'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Take Photo'),
                onTap: () => Navigator.pop(context, ImageSource.camera),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Choose from Gallery'),
                onTap: () => Navigator.pop(context, ImageSource.gallery),
              ),
            ],
          ),
        ),
      );

      if (source == null) return;

      final XFile? image = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image == null) return;

      // Show notes dialog
      final notes = await showDialog<String>(
        context: context,
        builder: (context) => _NotesDialog(),
      );

      // Upload photo
      final postureProvider = context.read<PostureProvider>();
      final photo = await postureProvider.uploadPhoto(
        imageFile: File(image.path),
        viewAngle: _selectedViewAngle,
        notes: notes,
      );

      if (photo != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Posture photo uploaded successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error capturing photo: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _comparePhotos() async {
    final postureProvider = context.read<PostureProvider>();

    if (postureProvider.photos.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You need at least 2 photos to compare'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Show photo selection dialog
    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (context) => _ComparePhotosDialog(
        photos: postureProvider.photos,
      ),
    );

    if (result == null) return;

    final beforeId = result['beforeId']!;
    final afterId = result['afterId']!;
    final notes = result['notes'];

    final comparison = await postureProvider.comparePhotos(
      beforePhotoId: beforeId,
      afterPhotoId: afterId,
      notes: notes,
    );

    if (comparison != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Comparison created successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      _tabController.animateTo(1); // Switch to comparisons tab
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Column(
        children: [
          AppBar(
            title: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Posture Tracking'),
                Text(
                  'Monitor your posture progress',
                  style: TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),
          TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: 'My Photos', icon: Icon(Icons.photo_library)),
              Tab(text: 'Comparisons', icon: Icon(Icons.compare)),
            ],
            labelColor: Theme.of(context).colorScheme.primary,
            unselectedLabelColor: Colors.grey,
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildPhotosTab(),
                _buildComparisonsTab(),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_tabController.index == 0)
            FloatingActionButton.extended(
              onPressed: _capturePhoto,
              icon: const Icon(Icons.camera_alt),
              label: const Text('Add Photo'),
              backgroundColor: Theme.of(context).colorScheme.primary,
            ),
          if (_tabController.index == 0) const SizedBox(height: 8),
          if (_tabController.index == 0)
            FloatingActionButton(
              onPressed: _comparePhotos,
              child: const Icon(Icons.compare_arrows),
              backgroundColor: AppTheme.secondary,
            ),
        ],
      ),
    );
  }

  Widget _buildPhotosTab() {
    return Consumer<PostureProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading && provider.photos.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.error != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                const SizedBox(height: 16),
                Text(provider.error!, textAlign: TextAlign.center),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _loadData,
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        if (provider.photos.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.photo_camera, size: 80, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  'No posture photos yet',
                  style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                ),
                const SizedBox(height: 8),
                Text(
                  'Tap the button below to add your first photo',
                  style: TextStyle(color: Colors.grey[500]),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: _loadData,
          child: GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.7,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: provider.photos.length,
            itemBuilder: (context, index) {
              final photo = provider.photos[index];
              return _buildPhotoCard(photo);
            },
          ),
        );
      },
    );
  }

  Widget _buildPhotoCard(PosturePhoto photo) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _showPhotoDetail(photo),
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(12)),
                child: Image.network(
                  photo.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey[300],
                      child: const Icon(Icons.photo, size: 64),
                    );
                  },
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        _getViewAngleIcon(photo.viewAngle),
                        size: 16,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        photo.viewAngle,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatDate(photo.capturedAt),
                    style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                  ),
                  if (photo.notes != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      photo.notes!,
                      style: TextStyle(fontSize: 11, color: Colors.grey[700]),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildComparisonsTab() {
    return Consumer<PostureProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading && provider.comparisons.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.comparisons.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.compare_arrows, size: 80, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  'No comparisons yet',
                  style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                ),
                const SizedBox(height: 8),
                Text(
                  'Create a comparison from the Photos tab',
                  style: TextStyle(color: Colors.grey[500]),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: _loadData,
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: provider.comparisons.length,
            itemBuilder: (context, index) {
              final comparison = provider.comparisons[index];
              return _buildComparisonCard(comparison);
            },
          ),
        );
      },
    );
  }

  Widget _buildComparisonCard(PostureComparison comparison) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _showComparisonDetail(comparison),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.calendar_today, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    _formatDate(comparison.comparisonDate),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  if (comparison.improvementScore != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _getScoreColor(comparison.improvementScore!),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${(comparison.improvementScore! * 100).toInt()}%',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        const Text('Before',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            comparison.beforePhoto.imageUrl,
                            height: 150,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                height: 150,
                                color: Colors.grey[300],
                                child: const Icon(Icons.photo, size: 48),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      children: [
                        const Text('After',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            comparison.afterPhoto.imageUrl,
                            height: 150,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                height: 150,
                                color: Colors.grey[300],
                                child: const Icon(Icons.photo, size: 48),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (comparison.notes != null) ...[
                const SizedBox(height: 12),
                Text(
                  comparison.notes!,
                  style: TextStyle(color: Colors.grey[700]),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _showPhotoDetail(PosturePhoto photo) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.network(photo.imageUrl),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${photo.viewAngle} View',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text('Date: ${_formatDate(photo.capturedAt)}'),
                  if (photo.notes != null) ...[
                    const SizedBox(height: 8),
                    Text('Notes: ${photo.notes}'),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showComparisonDetail(PostureComparison comparison) {
    // Navigate to a detailed comparison screen or show dialog
    // Implementation can be expanded
    _showPhotoDetail(comparison.afterPhoto);
  }

  IconData _getViewAngleIcon(String viewAngle) {
    switch (viewAngle) {
      case 'FRONT':
        return Icons.person;
      case 'BACK':
        return Icons.person_outline;
      case 'LEFT':
        return Icons.keyboard_arrow_left;
      case 'RIGHT':
        return Icons.keyboard_arrow_right;
      default:
        return Icons.photo;
    }
  }

  Color _getScoreColor(double score) {
    if (score >= 0.75) return Colors.green;
    if (score >= 0.5) return Colors.orange;
    return Colors.red;
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

// View Angle Selection Dialog
class _ViewAngleDialog extends StatefulWidget {
  final String selectedAngle;

  const _ViewAngleDialog({required this.selectedAngle});

  @override
  State<_ViewAngleDialog> createState() => _ViewAngleDialogState();
}

class _ViewAngleDialogState extends State<_ViewAngleDialog> {
  late String _selectedAngle;

  @override
  void initState() {
    super.initState();
    _selectedAngle = widget.selectedAngle;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Select View Angle'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          RadioListTile<String>(
            title: const Text('Front View'),
            value: 'FRONT',
            groupValue: _selectedAngle,
            onChanged: (value) => setState(() => _selectedAngle = value!),
          ),
          RadioListTile<String>(
            title: const Text('Back View'),
            value: 'BACK',
            groupValue: _selectedAngle,
            onChanged: (value) => setState(() => _selectedAngle = value!),
          ),
          RadioListTile<String>(
            title: const Text('Left Side'),
            value: 'LEFT',
            groupValue: _selectedAngle,
            onChanged: (value) => setState(() => _selectedAngle = value!),
          ),
          RadioListTile<String>(
            title: const Text('Right Side'),
            value: 'RIGHT',
            groupValue: _selectedAngle,
            onChanged: (value) => setState(() => _selectedAngle = value!),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, _selectedAngle),
          child: const Text('Continue'),
        ),
      ],
    );
  }
}

// Notes Dialog
class _NotesDialog extends StatefulWidget {
  @override
  State<_NotesDialog> createState() => _NotesDialogState();
}

class _NotesDialogState extends State<_NotesDialog> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Notes (Optional)'),
      content: TextField(
        controller: _controller,
        decoration: const InputDecoration(
          hintText: 'Enter notes about this photo...',
          border: OutlineInputBorder(),
        ),
        maxLines: 3,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Skip'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, _controller.text),
          child: const Text('Save'),
        ),
      ],
    );
  }
}

// Compare Photos Dialog
class _ComparePhotosDialog extends StatefulWidget {
  final List<PosturePhoto> photos;

  const _ComparePhotosDialog({required this.photos});

  @override
  State<_ComparePhotosDialog> createState() => _ComparePhotosDialogState();
}

class _ComparePhotosDialogState extends State<_ComparePhotosDialog> {
  PosturePhoto? _beforePhoto;
  PosturePhoto? _afterPhoto;
  final TextEditingController _notesController = TextEditingController();

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Compare Photos'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<PosturePhoto>(
              decoration: const InputDecoration(
                labelText: 'Before Photo',
                border: OutlineInputBorder(),
              ),
              value: _beforePhoto,
              items: widget.photos.map((photo) {
                return DropdownMenuItem(
                  value: photo,
                  child: Text(
                    '${photo.viewAngle} - ${photo.capturedAt.day}/${photo.capturedAt.month}',
                  ),
                );
              }).toList(),
              onChanged: (value) => setState(() => _beforePhoto = value),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<PosturePhoto>(
              decoration: const InputDecoration(
                labelText: 'After Photo',
                border: OutlineInputBorder(),
              ),
              value: _afterPhoto,
              items: widget.photos.map((photo) {
                return DropdownMenuItem(
                  value: photo,
                  child: Text(
                    '${photo.viewAngle} - ${photo.capturedAt.day}/${photo.capturedAt.month}',
                  ),
                );
              }).toList(),
              onChanged: (value) => setState(() => _afterPhoto = value),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Notes (Optional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _beforePhoto != null && _afterPhoto != null
              ? () {
                  Navigator.pop(context, {
                    'beforeId': _beforePhoto!.id,
                    'afterId': _afterPhoto!.id,
                    'notes': _notesController.text.isEmpty
                        ? null
                        : _notesController.text,
                  });
                }
              : null,
          child: const Text('Compare'),
        ),
      ],
    );
  }
}
