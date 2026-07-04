import 'package:flutter/material.dart';
import 'package:open_filex/open_filex.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../providers/report_provider.dart';
import '../providers/scan_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/chat_fab.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ReportProvider>().loadReports();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final reports = context.watch<ReportProvider>();
    final currentAnalysis = context.watch<ScanProvider>().currentAnalysis;
    final latestReport =
        reports.reports.isNotEmpty ? reports.reports.first : null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reports'),
        leading: IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Report Preview
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    // Report icon
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Icon(Icons.description,
                          size: 40, color: theme.colorScheme.primary),
                    ),
                    const SizedBox(height: 16),
                    Text('ScolioCare Report',
                        style: theme.textTheme.titleLarge
                            ?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(
                      latestReport != null
                          ? 'Generated on ${_formatDate(latestReport.generatedAt)}'
                          : 'Generate a report from your latest analysis',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Divider(),
                    const SizedBox(height: 16),

                    // Report contents preview
                    _ReportSection(
                      theme,
                      icon: Icons.person_outline,
                      title: 'Patient Information',
                      subtitle: 'Personal details and medical history',
                    ),
                    _ReportSection(
                      theme,
                      icon: Icons.monitor_heart,
                      title: 'Scan Results',
                      subtitle: '3 scans with analysis',
                    ),
                    _ReportSection(
                      theme,
                      icon: Icons.speed,
                      title: 'ATR Measurements',
                      subtitle: '12 readings over 6 weeks',
                    ),
                    _ReportSection(
                      theme,
                      icon: Icons.trending_up,
                      title: 'Progress Summary',
                      subtitle: 'Trends and improvements',
                    ),
                    _ReportSection(
                      theme,
                      icon: Icons.fitness_center,
                      title: 'Exercise Compliance',
                      subtitle: '78% completion rate',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Actions
            FilledButton.icon(
              onPressed: reports.isGenerating || reports.isLoading
                  ? null
                  : () => _generateOrDownloadReport(
                        context,
                        currentAnalysis?.analysisId,
                        latestReport?.reportId,
                      ),
              icon: Icon(
                currentAnalysis?.analysisId != null
                    ? Icons.picture_as_pdf
                    : latestReport == null
                        ? Icons.picture_as_pdf
                        : Icons.download,
              ),
              label: Text(
                reports.isGenerating
                    ? 'Generating...'
                    : currentAnalysis?.analysisId != null
                        ? 'Generate Fresh PDF'
                        : latestReport == null
                            ? 'Generate PDF'
                            : 'Download PDF',
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: latestReport?.reportId == null
                  ? null
                  : () => _downloadAndShareReport(
                        context,
                        latestReport!.reportId,
                      ),
              icon: const Icon(Icons.share),
              label: const Text('Share Report'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 56),
              ),
            ),
            const SizedBox(height: 24),

            // Share with Doctor
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: AppTheme.info.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.medical_services,
                              color: AppTheme.info),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Share with Your Doctor',
                                  style: theme.textTheme.titleSmall
                                      ?.copyWith(fontWeight: FontWeight.w600)),
                              Text(
                                'Send your report directly to your healthcare provider',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      decoration: InputDecoration(
                        hintText: "Doctor's email address",
                        prefixIcon: const Icon(Icons.mail_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    FilledButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Report sent to doctor!'),
                            backgroundColor: AppTheme.success,
                          ),
                        );
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor: AppTheme.info,
                        minimumSize: const Size(double.infinity, 48),
                      ),
                      child: const Text('Send to Doctor'),
                    ),
                  ],
                ),
              ),
            ),

            // Disclaimer
            Padding(
              padding: const EdgeInsets.only(top: 24),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.warning.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.warning.withOpacity(0.2)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.warning_amber,
                        color: AppTheme.warning, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'This report is for informational purposes only. Always consult with a qualified healthcare professional for medical decisions.',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: const ChatFab(),
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  Future<void> _generateOrDownloadReport(
    BuildContext context,
    String? analysisId,
    String? reportId,
  ) async {
    final provider = context.read<ReportProvider>();
    String? targetReportId = reportId;

    if (analysisId != null) {
      final report = await provider.generateReport(analysisId);
      if (!context.mounted) return;
      if (report == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(provider.error ?? 'Failed to generate report')),
        );
        return;
      }
      targetReportId = report.reportId;
    }

    if (targetReportId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('No completed analysis is available yet.')),
      );
      return;
    }

    final path = await provider.downloadReport(targetReportId);
    if (!context.mounted) return;
    if (path == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.error ?? 'Failed to download report'),
          backgroundColor: AppTheme.destructive,
        ),
      );
      return;
    }

    await _showReportReadySheet(context, path);
  }

  Future<void> _downloadAndShareReport(
    BuildContext context,
    String reportId,
  ) async {
    final provider = context.read<ReportProvider>();
    final path = await provider.downloadReport(reportId);
    if (!context.mounted) return;
    if (path == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.error ?? 'Failed to download report'),
          backgroundColor: AppTheme.destructive,
        ),
      );
      return;
    }
    await _shareReport(path);
  }

  Future<void> _showReportReadySheet(BuildContext context, String path) async {
    final theme = Theme.of(context);
    await showModalBottomSheet<void>(
      context: context,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
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
              const SizedBox(height: 18),
              Row(
                children: [
                  Icon(Icons.picture_as_pdf, color: theme.colorScheme.primary),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Report is ready',
                      style: theme.textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Open it with a PDF viewer or share it with your doctor.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 18),
              FilledButton.icon(
                onPressed: () async {
                  Navigator.pop(context);
                  await _openReport(context, path);
                },
                icon: const Icon(Icons.open_in_new),
                label: const Text('Open PDF'),
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: () async {
                  Navigator.pop(context);
                  await _shareReport(path);
                },
                icon: const Icon(Icons.share),
                label: const Text('Share PDF'),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _openReport(BuildContext context, String path) async {
    final result = await OpenFilex.open(
      path,
      type: 'application/pdf',
    );

    if (!context.mounted) return;
    if (result.type != ResultType.done) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            result.message.isNotEmpty
                ? result.message
                : 'No PDF viewer found. Try sharing the report instead.',
          ),
          backgroundColor: AppTheme.destructive,
        ),
      );
    }
  }

  Future<void> _shareReport(String path) async {
    await Share.shareXFiles(
      [XFile(path, mimeType: 'application/pdf')],
      subject: 'ScolioCare Report',
      text: 'ScolioCare medical report PDF',
    );
  }
}

class _ReportSection extends StatelessWidget {
  final ThemeData theme;
  final IconData icon;
  final String title;
  final String subtitle;

  const _ReportSection(this.theme,
      {required this.icon, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: theme.colorScheme.primary, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: theme.textTheme.bodyMedium
                        ?.copyWith(fontWeight: FontWeight.w600)),
                Text(subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    )),
              ],
            ),
          ),
          Icon(Icons.check_circle,
              color: theme.colorScheme.primary.withOpacity(0.5), size: 20),
        ],
      ),
    );
  }
}
