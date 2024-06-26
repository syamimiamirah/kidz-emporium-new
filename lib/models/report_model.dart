class ReportModel {
  late String userId;
  final String? id;
  String reportTitle;
  String reportDescription;
  String childId;
  String bookingId;
  String file;

  ReportModel({
    required this.userId,
    this.id,
    required this.reportTitle,
    required this.reportDescription,
    required this.childId,
    required this.bookingId,
    required this.file,
  });

  factory ReportModel.fromJson(Map<String, dynamic> json) {
    return ReportModel(
      id: json['_id'],
      userId: json['userId'] ?? '',
      reportTitle: json['reportTitle'] ?? '',
      reportDescription: json['reportDescription'] ?? '',
      childId: json['childId'] ?? '',
      bookingId: json['bookingId'] ?? '',
      file: json['filePath'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      '_id': id,
      'userId': userId,
      'reportTitle': reportTitle,
      'reportDescription': reportDescription,
      'childId': childId,
      'bookingId': bookingId,
      'filePath': file,
    };

    if (id != null) {
      data['_id'] = id; // Include id in JSON if it's not null
    }

    return data;
  }
}
