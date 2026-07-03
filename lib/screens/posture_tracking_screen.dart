import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../providers/posture_provider.dart';
import '../providers/auth_provider.dart';
import '../models/posture_photo.dart';
import '../theme/app_theme.dart';
import '../core/api/api_config.dart';

class PostureTrackingScreen extends StatefulWidget {
  final bool embedded;

  const PostureTrackingScreen({
    Key? key,
    this.embedded = false,
  }) : super(key: key);

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
      if (!mounted) return;
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
      if (!mounted) return;

      // Show details dialog
      final details = await showDialog<Map<String, String?>>(
        context: context,
        builder: (context) => const _PhotoDetailsDialog(),
      );
      if (details == null) return;

      // Upload photo
      if (!mounted) return;
      final postureProvider = context.read<PostureProvider>();
      final photo = await postureProvider.uploadPhoto(
        imageFile: File(image.path),
        viewAngle: _selectedViewAngle,
        name: details['name'] ?? 'Posture photo',
        notes: details['notes'],
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

    // Show photo selection sheet
    final result = await showModalBottomSheet<Map<String, PosturePhoto>>(
      context: context,
      isScrollControlled: true,
      builder: (context) => _ComparePhotosSheet(
        photos: postureProvider.photos,
      ),
    );

    if (result == null) return;

    final beforePhoto = result['beforePhoto']!;
    final afterPhoto = result['afterPhoto']!;

    if (!mounted) return;
    if (beforePhoto.id == afterPhoto.id) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Choose two different photos to compare'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final savedComparison = await postureProvider.comparePhotos(
      beforePhotoId: beforePhoto.id,
      afterPhotoId: afterPhoto.id,
      notes:
          'Visual comparison: ${_photoTitle(beforePhoto)} and ${_photoTitle(afterPhoto)}',
    );

    if (!mounted) return;

    final comparison = savedComparison ??
        PostureComparison(
          id: 'local-${DateTime.now().millisecondsSinceEpoch}',
          userId: context.read<AuthProvider>().userId ?? '',
          beforePhoto: beforePhoto,
          afterPhoto: afterPhoto,
          comparisonDate: DateTime.now(),
          notes: 'Not saved to history',
        );

    if (savedComparison == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            postureProvider.error ?? 'Could not save comparison history',
          ),
          backgroundColor: Colors.orange,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Comparison saved'),
          backgroundColor: Colors.green,
        ),
      );
      _tabController.animateTo(1);
    }

    _showComparisonDetail(comparison);
  }

  @override
  Widget build(BuildContext context) {
    final content = Column(
      children: [
        if (!widget.embedded)
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
          labelColor: Colors.white,
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
    );

    if (widget.embedded) {
      return Stack(
        children: [
          content,
          Positioned(
            left: 16,
            bottom: 16,
            child: _buildActionButtons(),
          ),
        ],
      );
    }

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: content,
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
      floatingActionButton: _buildActionButtons(),
    );
  }

  Widget _buildActionButtons() {
    return AnimatedBuilder(
      animation: _tabController,
      builder: (context, _) {
        if (_tabController.index != 0) return const SizedBox.shrink();
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            FloatingActionButton.extended(
              onPressed: _capturePhoto,
              icon: const Icon(Icons.camera_alt),
              label: const Text('Add Photo'),
              backgroundColor: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 8),
            FloatingActionButton(
              onPressed: _comparePhotos,
              backgroundColor: AppTheme.secondary,
              child: const Icon(Icons.compare_arrows),
            ),
          ],
        );
      },
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
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(
                      ApiConfig.resolveFileUrl(photo.imageUrl),
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[300],
                          child: const Icon(Icons.photo, size: 64),
                        );
                      },
                    ),
                    Positioned(
                      top: 6,
                      right: 6,
                      child: _DeleteIconButton(
                        onPressed: () => _confirmDeletePhoto(photo),
                      ),
                    ),
                  ],
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
                    _photoTitle(photo),
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
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
                  IconButton(
                    tooltip: 'Delete comparison',
                    onPressed: () => _confirmDeleteComparison(comparison),
                    icon: const Icon(Icons.delete_outline, size: 20),
                  ),
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
                            ApiConfig.resolveFileUrl(
                              comparison.beforePhoto.imageUrl,
                            ),
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
                            ApiConfig.resolveFileUrl(
                              comparison.afterPhoto.imageUrl,
                            ),
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
            Image.network(ApiConfig.resolveFileUrl(photo.imageUrl)),
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

  Future<void> _confirmDeletePhoto(PosturePhoto photo) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove photo?'),
        content: Text(
          'This will remove "${_photoTitle(photo)}" and any comparisons that use it.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Remove'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;
    final provider = context.read<PostureProvider>();
    final deleted = await provider.deletePhoto(photo.id);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          deleted ? 'Photo removed' : provider.error ?? 'Failed to remove photo',
        ),
        backgroundColor: deleted ? Colors.green : Colors.red,
      ),
    );
  }

  Future<void> _confirmDeleteComparison(PostureComparison comparison) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove comparison?'),
        content: const Text('This comparison will be removed from your history.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Remove'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;
    final provider = context.read<PostureProvider>();
    final deleted = await provider.deleteComparison(comparison.id);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          deleted
              ? 'Comparison removed'
              : provider.error ?? 'Failed to remove comparison',
        ),
        backgroundColor: deleted ? Colors.green : Colors.red,
      ),
    );
  }

  void _showComparisonDetail(PostureComparison comparison) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        insetPadding: const EdgeInsets.all(16),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Posture Comparison',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Flexible(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _ComparisonImagePane(
                          label: 'Photo 1',
                          photo: comparison.beforePhoto,
                          formatDate: _formatDate,
                          title: _photoTitle(comparison.beforePhoto),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _ComparisonImagePane(
                          label: 'Photo 2',
                          photo: comparison.afterPhoto,
                          formatDate: _formatDate,
                          title: _photoTitle(comparison.afterPhoto),
                        ),
                      ),
                    ],
                  ),
                ),
                if (comparison.notes != null &&
                    comparison.notes!.trim().isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text('Notes: ${comparison.notes}'),
                ],
              ],
            ),
          ),
        ),
      ),
    );
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

  String _photoTitle(PosturePhoto photo) {
    final name = photo.name?.trim();
    if (name != null && name.isNotEmpty) return name;
    return '${photo.viewAngle} view';
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

class _ComparisonImagePane extends StatelessWidget {
  final String label;
  final PosturePhoto photo;
  final String title;
  final String Function(DateTime date) formatDate;

  const _ComparisonImagePane({
    required this.label,
    required this.photo,
    required this.title,
    required this.formatDate,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: AspectRatio(
            aspectRatio: 0.72,
            child: Image.network(
              ApiConfig.resolveFileUrl(photo.imageUrl),
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                color: Colors.grey[300],
                child: const Icon(Icons.photo, size: 48),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        Text(
          '${photo.viewAngle} - ${formatDate(photo.capturedAt)}',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}

class _DeleteIconButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _DeleteIconButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withOpacity(0.55),
      shape: const CircleBorder(),
      child: IconButton(
        tooltip: 'Remove photo',
        onPressed: onPressed,
        icon: const Icon(Icons.delete_outline, color: Colors.white, size: 18),
        constraints: const BoxConstraints.tightFor(width: 36, height: 36),
        padding: EdgeInsets.zero,
      ),
    );
  }
}

// Photo Details Dialog
class _PhotoDetailsDialog extends StatefulWidget {
  const _PhotoDetailsDialog();

  @override
  State<_PhotoDetailsDialog> createState() => _PhotoDetailsDialogState();
}

class _PhotoDetailsDialogState extends State<_PhotoDetailsDialog> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Photo Details'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Photo name',
              hintText: 'Example: Week 1 front view',
              border: OutlineInputBorder(),
            ),
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _notesController,
            decoration: const InputDecoration(
              labelText: 'Notes (optional)',
              hintText: 'Anything you want to remember...',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            final name = _nameController.text.trim();
            Navigator.pop(context, {
              'name': name.isEmpty ? 'Posture photo' : name,
              'notes': _notesController.text.trim().isEmpty
                  ? null
                  : _notesController.text.trim(),
            });
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}

class _ComparePhotosSheet extends StatefulWidget {
  final List<PosturePhoto> photos;

  const _ComparePhotosSheet({required this.photos});

  @override
  State<_ComparePhotosSheet> createState() => _ComparePhotosSheetState();
}

class _ComparePhotosSheetState extends State<_ComparePhotosSheet> {
  PosturePhoto? _firstPhoto;
  PosturePhoto? _secondPhoto;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          20,
          12,
          20,
          MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.colorScheme.onSurfaceVariant.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Choose two photos',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Select the two posture photos you want to view side by side.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.separated(
                itemCount: widget.photos.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final photo = widget.photos[index];
                  final selectedAsFirst = _firstPhoto?.id == photo.id;
                  final selectedAsSecond = _secondPhoto?.id == photo.id;
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        ApiConfig.resolveFileUrl(photo.imageUrl),
                        width: 56,
                        height: 56,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          width: 56,
                          height: 56,
                          color: Colors.grey[300],
                          child: const Icon(Icons.photo),
                        ),
                      ),
                    ),
                    title: Text(
                      _photoTitle(photo),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(
                      '${photo.viewAngle} - ${photo.capturedAt.day}/${photo.capturedAt.month}/${photo.capturedAt.year}',
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _SelectionPill(
                          label: '1',
                          selected: selectedAsFirst,
                          onTap: () => setState(() {
                            _firstPhoto = photo;
                            if (_secondPhoto?.id == photo.id) {
                              _secondPhoto = null;
                            }
                          }),
                        ),
                        const SizedBox(width: 8),
                        _SelectionPill(
                          label: '2',
                          selected: selectedAsSecond,
                          onTap: () => setState(() {
                            _secondPhoto = photo;
                            if (_firstPhoto?.id == photo.id) {
                              _firstPhoto = null;
                            }
                          }),
                        ),
                      ],
                    ),
                    onTap: () => setState(() {
                      if (_firstPhoto == null && _secondPhoto?.id != photo.id) {
                        _firstPhoto = photo;
                      } else if (_secondPhoto == null &&
                          _firstPhoto?.id != photo.id) {
                        _secondPhoto = photo;
                      } else if (_firstPhoto?.id == photo.id) {
                        _firstPhoto = null;
                      } else if (_secondPhoto?.id == photo.id) {
                        _secondPhoto = null;
                      }
                    }),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: _firstPhoto != null && _secondPhoto != null
                        ? () => Navigator.pop(context, {
                              'beforePhoto': _firstPhoto!,
                              'afterPhoto': _secondPhoto!,
                            })
                        : null,
                    icon: const Icon(Icons.compare_arrows),
                    label: const Text('Compare'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _photoTitle(PosturePhoto photo) {
    final name = photo.name?.trim();
    if (name != null && name.isNotEmpty) return name;
    return '${photo.viewAngle} view';
  }
}

class _SelectionPill extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _SelectionPill({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 32,
        height: 32,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? theme.colorScheme.primary : Colors.transparent,
          shape: BoxShape.circle,
          border: Border.all(color: theme.colorScheme.primary),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : theme.colorScheme.primary,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
