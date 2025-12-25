import 'dart:io';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:permission_handler/permission_handler.dart';
import '../models/survey_model.dart';
import '../../core/constants/app_constants.dart';
import '../../core/config/app_config.dart';

final invoiceRepositoryProvider = Provider<InvoiceRepository?>((ref) {
  // In demo mode, return null (PDF generation still works, but upload won't)
  if (AppConfig.useDemoMode) {
    return null;
  }
  return InvoiceRepository(
    FirebaseFirestore.instance,
    FirebaseStorage.instance,
  );
});

class InvoiceRepository {
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;
  
  InvoiceRepository(this._firestore, this._storage);
  
  /// Generate PDF invoice for a survey
  Future<Uint8List> generateInvoicePdf(SurveyModel survey, {
    String? companyName,
    String? companyAddress,
    String? companyPhone,
  }) async {
    final pdf = pw.Document();
    
    final invoiceNumber = 'INV-${survey.id?.substring(0, 8).toUpperCase() ?? DateTime.now().millisecondsSinceEpoch}';
    final invoiceDate = DateTime.now();
    
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        companyName ?? AppConstants.appName,
                        style: pw.TextStyle(
                          fontSize: 24,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.blue800,
                        ),
                      ),
                      pw.SizedBox(height: 4),
                      if (companyAddress != null)
                        pw.Text(
                          companyAddress,
                          style: const pw.TextStyle(
                            fontSize: 10,
                            color: PdfColors.grey700,
                          ),
                        ),
                      if (companyPhone != null)
                        pw.Text(
                          companyPhone,
                          style: const pw.TextStyle(
                            fontSize: 10,
                            color: PdfColors.grey700,
                          ),
                        ),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text(
                        'INVOICE',
                        style: pw.TextStyle(
                          fontSize: 28,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.blue800,
                        ),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text(
                        invoiceNumber,
                        style: const pw.TextStyle(
                          fontSize: 12,
                          color: PdfColors.grey700,
                        ),
                      ),
                      pw.Text(
                        'Date: ${_formatDate(invoiceDate)}',
                        style: const pw.TextStyle(
                          fontSize: 10,
                          color: PdfColors.grey700,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              
              pw.SizedBox(height: 30),
              pw.Divider(color: PdfColors.grey400),
              pw.SizedBox(height: 20),
              
              // Bill To Section
              pw.Text(
                'Bill To:',
                style: pw.TextStyle(
                  fontSize: 12,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.grey800,
                ),
              ),
              pw.SizedBox(height: 8),
              pw.Text(
                survey.applicantName,
                style: pw.TextStyle(
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.Text(
                'Mobile: ${survey.mobileNumber}',
                style: const pw.TextStyle(fontSize: 11),
              ),
              
              pw.SizedBox(height: 30),
              
              // Survey Details Table
              pw.Text(
                'Survey Details',
                style: pw.TextStyle(
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.blue800,
                ),
              ),
              pw.SizedBox(height: 10),
              
              pw.Table(
                border: pw.TableBorder.all(color: PdfColors.grey400),
                columnWidths: {
                  0: const pw.FlexColumnWidth(2),
                  1: const pw.FlexColumnWidth(3),
                },
                children: [
                  _buildTableRow('Village Name', survey.villageName, isHeader: false),
                  _buildTableRow('Survey Number', survey.surveyNumber, isHeader: false),
                  _buildTableRow('Survey Type', survey.surveyType.displayName, isHeader: false),
                  _buildTableRow('Status', survey.status.displayName, isHeader: false),
                  _buildTableRow('Survey Date', _formatDate(survey.createdAt), isHeader: false),
                ],
              ),
              
              pw.SizedBox(height: 30),
              
              // Payment Summary
              pw.Text(
                'Payment Summary',
                style: pw.TextStyle(
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.blue800,
                ),
              ),
              pw.SizedBox(height: 10),
              
              pw.Container(
                padding: const pw.EdgeInsets.all(15),
                decoration: pw.BoxDecoration(
                  color: PdfColors.grey100,
                  borderRadius: pw.BorderRadius.circular(8),
                ),
                child: pw.Column(
                  children: [
                    _buildPaymentRow('Total Amount', survey.totalPayment),
                    pw.SizedBox(height: 8),
                    _buildPaymentRow('Amount Received', survey.receivedPayment, isGreen: true),
                    pw.SizedBox(height: 8),
                    pw.Divider(color: PdfColors.grey400),
                    pw.SizedBox(height: 8),
                    _buildPaymentRow('Pending Amount', survey.pendingPayment, isBold: true, isRed: survey.pendingPayment > 0),
                  ],
                ),
              ),
              
              pw.Spacer(),
              
              // Footer
              pw.Divider(color: PdfColors.grey400),
              pw.SizedBox(height: 10),
              pw.Center(
                child: pw.Text(
                  'Thank you for your business!',
                  style: pw.TextStyle(
                    fontSize: 12,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.grey700,
                  ),
                ),
              ),
              pw.SizedBox(height: 5),
              pw.Center(
                child: pw.Text(
                  'Generated on ${_formatDateTime(DateTime.now())}',
                  style: const pw.TextStyle(
                    fontSize: 9,
                    color: PdfColors.grey500,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
    
    return pdf.save();
  }
  
  pw.TableRow _buildTableRow(String label, String value, {bool isHeader = false}) {
    return pw.TableRow(
      children: [
        pw.Padding(
          padding: const pw.EdgeInsets.all(8),
          child: pw.Text(
            label,
            style: pw.TextStyle(
              fontSize: 11,
              fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
              color: PdfColors.grey700,
            ),
          ),
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.all(8),
          child: pw.Text(
            value,
            style: pw.TextStyle(
              fontSize: 11,
              fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
            ),
          ),
        ),
      ],
    );
  }
  
  pw.Widget _buildPaymentRow(String label, double amount, {bool isBold = false, bool isGreen = false, bool isRed = false}) {
    PdfColor textColor = PdfColors.black;
    if (isGreen) textColor = PdfColors.green700;
    if (isRed) textColor = PdfColors.red700;
    
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(
          label,
          style: pw.TextStyle(
            fontSize: 11,
            fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
          ),
        ),
        pw.Text(
          '${AppConstants.currencySymbol}${amount.toStringAsFixed(2)}',
          style: pw.TextStyle(
            fontSize: 11,
            fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
            color: textColor,
          ),
        ),
      ],
    );
  }
  
  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
  
  String _formatDateTime(DateTime date) {
    return '${_formatDate(date)} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
  
  /// Upload invoice PDF to Firebase Storage
  Future<String> uploadInvoice(String userId, String surveyId, Uint8List pdfBytes) async {
    final fileName = 'invoice_${surveyId}_${DateTime.now().millisecondsSinceEpoch}.pdf';
    final ref = _storage.ref().child('invoices/$userId/$fileName');
    
    final uploadTask = await ref.putData(
      pdfBytes,
      SettableMetadata(contentType: 'application/pdf'),
    );
    
    final downloadUrl = await uploadTask.ref.getDownloadURL();
    
    // Update survey with invoice URL
    await _firestore.collection(AppConstants.surveysCollection).doc(surveyId).update({
      'invoice_url': downloadUrl,
      'updated_at': Timestamp.now(),
    });
    
    return downloadUrl;
  }
  
  /// Save invoice to local storage
  Future<String> saveInvoiceLocally(Uint8List pdfBytes, String surveyId) async {
    Directory directory;
    
    if (Platform.isAndroid) {
      // Request storage permission on Android
      final status = await Permission.storage.request();
      if (!status.isGranted) {
        final manageStatus = await Permission.manageExternalStorage.request();
        if (!manageStatus.isGranted) {
          throw Exception('Storage permission denied');
        }
      }
      
      // Try to get Downloads directory, fallback to app documents
      try {
        directory = Directory('/storage/emulated/0/Download');
        if (!await directory.exists()) {
          directory = await getApplicationDocumentsDirectory();
        }
      } catch (e) {
        directory = await getApplicationDocumentsDirectory();
      }
    } else {
      // iOS - use Documents directory
      directory = await getApplicationDocumentsDirectory();
    }
    
    final fileName = 'Invoice_${surveyId}_${DateTime.now().millisecondsSinceEpoch}.pdf';
    final filePath = '${directory.path}/$fileName';
    
    final file = File(filePath);
    await file.writeAsBytes(pdfBytes);
    
    return filePath;
  }
  
  /// Download invoice from URL and save locally
  Future<String> downloadInvoice(String invoiceUrl, String surveyId) async {
    final ref = _storage.refFromURL(invoiceUrl);
    final bytes = await ref.getData();
    
    if (bytes == null) {
      throw Exception('Failed to download invoice');
    }
    
    return saveInvoiceLocally(bytes, surveyId);
  }
  
  /// Delete invoice from Firebase Storage
  Future<void> deleteInvoice(String invoiceUrl) async {
    try {
      final ref = _storage.refFromURL(invoiceUrl);
      await ref.delete();
    } catch (e) {
      // Ignore if file doesn't exist
    }
  }
  
  /// Get temporary file path for sharing
  Future<String> getShareableFilePath(Uint8List pdfBytes, String surveyId) async {
    final tempDir = await getTemporaryDirectory();
    final fileName = 'Invoice_$surveyId.pdf';
    final filePath = '${tempDir.path}/$fileName';
    
    final file = File(filePath);
    await file.writeAsBytes(pdfBytes);
    
    return filePath;
  }
}
