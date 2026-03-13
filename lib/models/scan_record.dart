class ScanRecord {
  final int id;
  final DateTime date;
  final String severity;
  final String curveType;
  final bool shared;

  const ScanRecord({
    required this.id,
    required this.date,
    required this.severity,
    required this.curveType,
    this.shared = false,
  });
}

class AtrRecord {
  final int id;
  final DateTime date;
  final double thoracic;
  final double lumbar;
  final double? thoracicChange;
  final double? lumbarChange;

  const AtrRecord({
    required this.id,
    required this.date,
    required this.thoracic,
    required this.lumbar,
    this.thoracicChange,
    this.lumbarChange,
  });
}
