class LivestreamModel {
  String url;
  String bookingId;
  late String userId;
  final String? id;

  LivestreamModel({
    required this.url,
    required this.bookingId,
    required userId,
    this.id,
});
  factory LivestreamModel.fromJson(Map<String, dynamic> json) {
    return LivestreamModel(
      id: json['_id'] ?? '',
      url: json['url'] ?? '',
      bookingId: json['bookingId'] ?? '',
      userId: json['userId'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'url': url,
      'bookingId': bookingId,
      '_id': id,
    };

    if(id != null) {
      data['_id'] = id;
    }

    return data;
  }
}