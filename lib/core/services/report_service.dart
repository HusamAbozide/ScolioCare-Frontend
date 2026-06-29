import 'package:path_provider/path_provider.dart';
import '../api/api_client.dart';
import '../api/api_config.dart';
import '../models/report/report.dart';

class ReportService {
  final ApiClient _apiClient;

  ReportService(this._apiClient);

  Future<Report> generateReport(String analysisId) async {
    // Mock mode
    if (ApiConfig.useMockMode) {
      await Future.delayed(const Duration(seconds: 2));
      return Report(
        reportId: 'mock-report-${DateTime.now().millisecondsSinceEpoch}',
        analysisId: analysisId,
        generatedAt: DateTime.now(),
        severityLevel: 'MILD',
        curveType: 'THORACIC',
        confidenceScore: 0.89,
        summaryJson: {
          'painLevel': 3,
          'exerciseAdherence': 78.5,
          'scolioReading': 5.2,
        },
        disclaimerText:
            'ScolioCare is not a medical diagnosis tool and does not replace professional medical advice.',
        pdfUrl: '/mock/reports/mock-report.pdf',
        status: 'COMPLETED',
      );
    }

    final response = await _apiClient.post<Report>(
      '/report/generate',
      data: {'analysisId': analysisId},
      fromJsonT: (json) => Report.fromJson(json as Map<String, dynamic>),
    );

    if (response.success && response.data != null) {
      return response.data!;
    }

    throw Exception(response.message ?? 'Failed to generate report');
  }

  Future<List<Report>> getReportList({
    int page = 0,
    int size = 20,
  }) async {
    // Mock mode
    if (ApiConfig.useMockMode) {
      await Future.delayed(const Duration(milliseconds: 500));
      return List.generate(
        3,
        (index) => Report(
          reportId: 'mock-report-$index',
          analysisId: 'mock-analysis-$index',
          generatedAt: DateTime.now().subtract(Duration(days: index * 30)),
          severityLevel: index == 0 ? 'MILD' : 'MODERATE',
          curveType: 'THORACIC',
          confidenceScore: 0.85 + (index * 0.02),
          summaryJson: {},
          disclaimerText: 'Mock disclaimer',
          pdfUrl: '/mock/reports/report-$index.pdf',
          status: 'COMPLETED',
        ),
      );
    }

    final response = await _apiClient.get(
      '/report/list/mock-user-123',
      queryParameters: {'page': page, 'size': size},
    );

    if (response.success && response.data != null) {
      final list = response.data as List;
      return list
          .map((item) => Report.fromJson(item as Map<String, dynamic>))
          .toList();
    }

    return [];
  }

  Future<Report> getReport(String reportId) async {
    // Mock mode
    if (ApiConfig.useMockMode) {
      await Future.delayed(const Duration(milliseconds: 300));
      return Report(
        reportId: reportId,
        analysisId: 'mock-analysis-1',
        generatedAt: DateTime.now(),
        severityLevel: 'MILD',
        curveType: 'THORACIC',
        confidenceScore: 0.89,
        summaryJson: {
          'painLevel': 3,
          'exerciseAdherence': 78.5,
          'scolioReading': 5.2,
        },
        disclaimerText:
            'ScolioCare is not a medical diagnosis tool and does not replace professional medical advice.',
        pdfUrl: '/mock/reports/mock-report.pdf',
        status: 'COMPLETED',
      );
    }

    final response = await _apiClient.get<Report>(
      '/report/$reportId',
      fromJsonT: (json) => Report.fromJson(json as Map<String, dynamic>),
    );

    if (response.success && response.data != null) {
      return response.data!;
    }

    throw Exception(response.message ?? 'Failed to get report');
  }

  Future<String> downloadReport(String reportId) async {
    // Mock mode
    if (ApiConfig.useMockMode) {
      await Future.delayed(const Duration(seconds: 1));
      // Return a mock path
      final dir = await getApplicationDocumentsDirectory();
      return '${dir.path}/mock-report-$reportId.pdf';
    }

    final dir = await getApplicationDocumentsDirectory();
    final savePath = '${dir.path}/report-$reportId.pdf';

    await _apiClient.download(
      '/report/$reportId/download',
      savePath,
    );

    return savePath;
  }

  Future<Map<String, dynamic>> getReportStatus(String reportId) async {
    // Mock mode
    if (ApiConfig.useMockMode) {
      await Future.delayed(const Duration(milliseconds: 200));
      return {
        'status': 'COMPLETED',
        'progress': 100,
      };
    }

    final response = await _apiClient.get('/report/$reportId/status');

    if (response.success && response.data != null) {
      return response.data as Map<String, dynamic>;
    }

    return {'status': 'UNKNOWN', 'progress': 0};
  }
}
