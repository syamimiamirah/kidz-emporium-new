import 'dart:math';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'dart:typed_data';

Future<Uint8List> generateReceipt({
  required String serviceName,
  required String customerName,
  required String date,
  required double amount,
  String paymentMode = 'Debit/Credit Card',
  required String referenceNumber,
}) async {
  final pdf = pw.Document();

  // Generate a random receipt number
  final receiptNumber = Random().nextInt(900000) + 100000; // Random 6-digit number

  pdf.addPage(
    pw.Page(
      build: (pw.Context context) {
        return pw.Padding(
          padding: const pw.EdgeInsets.all(20),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'No.8-17-02, Jalan Medan Pusat Bandar 7A\nBangi Sentral, 43650 Bandar Baru Bangi, Selangor',
                style: pw.TextStyle(fontSize: 12),
                textAlign: pw.TextAlign.left,
              ),
              pw.SizedBox(height: 20),
              pw.Text('Receipt No: $receiptNumber', style: pw.TextStyle(fontSize: 16)),
              pw.SizedBox(height: 10),
              pw.Text('Payment Date: $date', style: pw.TextStyle(fontSize: 16)),
              pw.SizedBox(height: 10),
              pw.Text('Payment Mode: $paymentMode', style: pw.TextStyle(fontSize: 16)),
              pw.SizedBox(height: 10),
              pw.Text('Reference Number: $referenceNumber', style: pw.TextStyle(fontSize: 16)),
              pw.SizedBox(height: 20),
              pw.Text('Amount Received: ', style: pw.TextStyle(fontSize: 16)),
              pw.Text('RM ${amount.toStringAsFixed(2)}', style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 20),
              pw.Text('Received From: ', style: pw.TextStyle(fontSize: 16)),
              pw.Text('$customerName', style: pw.TextStyle(fontSize: 20)),
              pw.SizedBox(height: 20),
              pw.Text('Appointment at - ', style: pw.TextStyle(fontSize: 16)),
              pw.Divider(),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('No Details', style: pw.TextStyle(fontSize: 16)),
                  pw.Text('Qty', style: pw.TextStyle(fontSize: 16)),
                  pw.Text('Amount', style: pw.TextStyle(fontSize: 16)),
                ],
              ),
              pw.Divider(),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('$serviceName', style: pw.TextStyle(fontSize: 16)),
                  pw.Text('1', style: pw.TextStyle(fontSize: 16)),
                  pw.Text('RM ${amount.toStringAsFixed(2)}', style: pw.TextStyle(fontSize: 16)),
                ],
              ),
              pw.SizedBox(height: 20),
              pw.Text('Thank you for your business!', style: pw.TextStyle(fontSize: 16)),
            ],
          ),
        );
      },
    ),
  );

  return pdf.save();
}
