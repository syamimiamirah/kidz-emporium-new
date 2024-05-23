// /*
// import 'package:flutter/services.dart';
// import 'package:flutter_stripe/flutter_stripe.dart';
//
// class StripeService {
//
//   Future<PaymentMethod> createPaymentMethod(
//       Map<String, dynamic> cardData) async {
//     Card card = Card(
//       number: cardData['cardNumber'],
//       expMonth: int.parse(cardData['expirationDate'].split('/')[0]),
//       expYear: int.parse(cardData['expirationDate'].split('/')[1]),
//       cvc: cardData['cvv'],
//     );
//
//     PaymentMethod paymentMethod = PaymentMethod(
//       type: 'card',
//       card: card,
//       billingDetails: BillingDetails(
//         name: cardData['cardHolderName'],
//         email: cardData['email'],
//       ),
//     );
//
//     return paymentMethod;
//   }
// }*/
