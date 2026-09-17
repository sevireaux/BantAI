class Report {
  final String id;
  final String title;
  final String? category;
  final String? subcategory;
  final String description;
  final String? address;
  final double lat;
  final double lng;
  final String status;
  final String severity;
  final double? severityConfidence;
  final String? severitySource;
  final String? severityReasoning;
  final int similarReportCount;
  final DateTime submittedDate;
  final List<String> photos;
  final List<String> resolutionPhotos;
  final List<String> barangayPhotos;
  final List<StatusEvent> history;
  final String? resolutionDescription;
  final DateTime? resolutionDate;
  final String? barangay;
  final String? reporterName;
  final String? invalidReason;
  final bool barangayConfirmed;
  final String? barangayNote;
  final bool priorityEndorsed;
  final String? priorityEndorsementReason;
  final bool attentionRequested;
  final String? attentionRequestedReason;
  final bool recurringFlagged;

  Report({
    required this.id,
    required this.title,
    this.category,
    this.subcategory,
    required this.description,
    this.address,
    required this.lat,
    required this.lng,
    required this.status,
    required this.severity,
    this.severityConfidence,
    this.severitySource,
    this.severityReasoning,
    required this.similarReportCount,
    required this.submittedDate,
    required this.photos,
    required this.resolutionPhotos,
    required this.barangayPhotos,
    required this.history,
    this.resolutionDescription,
    this.resolutionDate,
    this.barangay,
    this.reporterName,
    this.invalidReason,
    required this.barangayConfirmed,
    this.barangayNote,
    required this.priorityEndorsed,
    this.priorityEndorsementReason,
    required this.attentionRequested,
    this.attentionRequestedReason,
    required this.recurringFlagged,
  });

  factory Report.fromJson(Map<String, dynamic> json) {
    return Report(
      id: json['id'] as String,
      title: json['title'] as String? ?? '',
      category: json['category'] as String?,
      subcategory: json['subcategory'] as String?,
      description: json['description'] as String? ?? '',
      address: json['address'] as String?,
      lat: (json['lat'] as num).toDouble(),
      lng: (json['lng'] as num).toDouble(),
      status: json['status'] as String? ?? 'Pending',
      severity: json['severity'] as String? ?? 'Moderate',
      severityConfidence: (json['severityConfidence'] as num?)?.toDouble(),
      severitySource: json['severitySource'] as String?,
      severityReasoning: json['severityReasoning'] as String?,
      similarReportCount: (json['similarReportCount'] as num?)?.toInt() ?? 1,
      submittedDate: DateTime.parse(json['submittedDate'] as String),
      photos: List<String>.from(json['photos'] ?? const []),
      resolutionPhotos: List<String>.from(json['resolutionPhotos'] ?? const []),
      barangayPhotos: List<String>.from(json['barangayPhotos'] ?? const []),
      history: (json['history'] as List? ?? const [])
          .map((e) => StatusEvent.fromJson(e as Map<String, dynamic>))
          .toList(),
      resolutionDescription: json['resolutionDescription'] as String?,
      resolutionDate: json['resolutionDate'] != null ? DateTime.tryParse(json['resolutionDate']) : null,
      barangay: json['barangay'] as String?,
      reporterName: json['reporterName'] as String?,
      invalidReason: json['invalidReason'] as String?,
      barangayConfirmed: json['barangayConfirmed'] as bool? ?? false,
      barangayNote: json['barangayNote'] as String?,
      priorityEndorsed: json['priorityEndorsed'] as bool? ?? false,
      priorityEndorsementReason: json['priorityEndorsementReason'] as String?,
      attentionRequested: json['attentionRequested'] as bool? ?? false,
      attentionRequestedReason: json['attentionRequestedReason'] as String?,
      recurringFlagged: json['recurringFlagged'] as bool? ?? false,
    );
  }
}

class StatusEvent {
  final String status;
  final DateTime date;
  final String? note;

  StatusEvent({required this.status, required this.date, this.note});

  factory StatusEvent.fromJson(Map<String, dynamic> json) {
    return StatusEvent(
      status: json['status'] as String,
      date: DateTime.parse(json['date'] as String),
      note: json['note'] as String?,
    );
  }
}
