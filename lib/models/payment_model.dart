class PaymentModel {
  late int amount;
  late String currency;
  late String paymentMethod;
  late String userId;
  //late String tokenId; // Add tokenId field
  final String? id;

  PaymentModel({
    required this.amount,
    required this.currency,
    required this.paymentMethod,
    required this.userId,
    //required this.tokenId, // Initialize tokenId in the constructor
    this.id,
  });

  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    // Parse the 'amount' field as an integer
    final amount = json['amount'] as int? ?? 50;
    // Ensure 'paymentMethod' is a string
    final paymentMethod = json['paymentMethod'] is String
        ? json['paymentMethod']
        : ''; // Default value if not a string
    return PaymentModel(
      id: json['_id'],
      amount: amount,
      currency: json['currency'] ?? '',
      paymentMethod: paymentMethod,
      userId: json['userId'] ?? '',
      //tokenId: json['tokenId'] ?? '', // Parse tokenId from JSON
    );
  }


  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'userId': userId,
      'amount': amount,
      'currency': currency,
      'paymentMethod': paymentMethod,
      //'tokenId': tokenId, // Include tokenId in JSONaymentMethod,
      '_id': id
    };

    if (id != null) {
      data['_id'] = id; // Include id in JSON if it's not null
    }

    return data;
  }
}
