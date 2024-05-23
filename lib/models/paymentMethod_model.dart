class PaymentMethodModel {
  final String cardNumber;
  final int expYear;
  final int expMonth;
  final String cvv;
  late String userId;
  final String? id;

  PaymentMethodModel({
    required this.cardNumber,
    required this.expMonth,
    required this.expYear,
    required this.cvv,
    required this.userId,
    this.id,
  });

  factory PaymentMethodModel.fromJson(Map<String, dynamic> json) {
    return PaymentMethodModel(
      id: json['_id'],
      cardNumber: json['cardNumber'] ?? '',
      expMonth: json['expMonth'] ?? '',
      expYear: json['expYear'] ?? '',
      cvv: json['cvv'] ?? '',
      userId: json['userId'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'cardNumber': cardNumber,
      'expMonth': expMonth,
      'expYear': expYear,
      'cvv': cvv,
      'userId': userId,
      '_id': id,
    };
    if (id != null) {
      data['_id'] = id; // Include id in JSON if it's not null
    }
    return data;
  }

}