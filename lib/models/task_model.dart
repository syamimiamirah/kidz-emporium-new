class TaskModel {
  late String userId;
  final String? id;
  String taskTitle;
  String taskDescription;
  late String fromDate;
  late String toDate;
  List<String> therapistId;

  TaskModel({
    required this.userId,
    this.id,
    required this.taskTitle,
    required this.taskDescription,
    required this.fromDate,
    required this.toDate,
    required this.therapistId,
});

  // Create TaskModel from a JSON map
  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      id: json['_id'],
      userId: json['userId'] ?? '',
      taskTitle: json['taskTitle'] ?? '',
      taskDescription: json['taskDescription'] ?? '',
      fromDate: json['fromDate'] ?? '',
      toDate: json['toDate'] ?? '',
      therapistId: List<String>.from(json['therapistId'] ?? []),
    );
  }
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'userId': userId,
      'taskTitle': taskTitle,
      'taskDescription': taskDescription,
      'fromDate': fromDate,
      'toDate': toDate,
      'therapistId': therapistId,
    };

    if (id != null) {
      data['_id'] = id; // Include id in JSON if it's not null
    }

    return data;
  }
}