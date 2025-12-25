import 'dart:typed_data';
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../data/models/survey_model.dart';
import '../data/repositories/invoice_repository.dart';
import '../core/config/app_config.dart';
import '../core/constants/app_constants.dart';
import 'auth_provider.dart';

// Invoice state
class InvoiceState {
  final bool isGenerating;
  final bool isUploading;
  final bool isDownloading;
  final bool isSuccess;
  final String? errorMessage;
  final Uint8List? pdfBytes;
  final String? localFilePath;
  final String? downloadUrl;
  
  const InvoiceState({
    this.isGenerating = false,
    this.isUploading = false,
    this.isDownloading = false,
    this.isSuccess = false,
    this.errorMessage,
    this.pdfBytes,
    this.localFilePath,
    this.downloadUrl,
  });
  
  InvoiceState copyWith({
    bool? isGenerating,
    bool? isUploading,
    bool? isDownloading,
    bool? isSuccess,
    String? errorMessage,
    Uint8List? pdfBytes,
    String? localFilePath,
    String? downloadUrl,
    bool clearPdf = false,
    bool clearLocalPath = false,
    bool clearDownloadUrl = false,
  }) {
    return InvoiceState(
      isGenerating: isGenerating ?? this.isGenerating,
      isUploading: isUploading ?? this.isUploading,
      isDownloading: isDownloading ?? this.isDownloading,
      isSuccess: isSuccess ?? this.isSuccess,
      errorMessage: errorMessage,
      pdfBytes: clearPdf ? null : (pdfBytes ?? this.pdfBytes),
      localFilePath: clearLocalPath ? null : (localFilePath ?? this.localFilePath),
      downloadUrl: clearDownloadUrl ? null : (downloadUrl ?? this.downloadUrl),
    );
  }
  
  bool get isLoading => isGenerating || isUploading || isDownloading;
}

// Demo PDF generator (works without Firebase)
class DemoPdfGenerator {
  static Future<Uint8List> generateInvoicePdf(SurveyModel survey, {
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
                  _buildTableRow('Village Name', survey.villageName),
                  _buildTableRow('Survey Number', survey.surveyNumber),
                  _buildTableRow('Survey Type', survey.surveyType.displayName),
                  _buildTableRow('Status', survey.status.displayName),
                  _buildTableRow('Survey Date', _formatDate(survey.createdAt)),
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
                  'Generated on ${_formatDateTime(DateTime.now())} (Demo Mode)',
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
  
  static pw.TableRow _buildTableRow(String label, String value) {
    return pw.TableRow(
      children: [
        pw.Padding(
          padding: const pw.EdgeInsets.all(8),
          child: pw.Text(
            label,
            style: pw.TextStyle(
              fontSize: 11,
              color: PdfColors.grey700,
            ),
          ),
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.all(8),
          child: pw.Text(
            value,
            style: const pw.TextStyle(fontSize: 11),
          ),
        ),
      ],
    );
  }
  
  static pw.Widget _buildPaymentRow(String label, double amount, {bool isBold = false, bool isGreen = false, bool isRed = false}) {
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
  
  static String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
  
  static String _formatDateTime(DateTime date) {
    return '${_formatDate(date)} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
  
  static Future<String> saveInvoiceLocally(Uint8List pdfBytes, String surveyId) async {
    final directory = await getApplicationDocumentsDirectory();
    final fileName = 'Invoice_${surveyId}_${DateTime.now().millisecondsSinceEpoch}.pdf';
    final filePath = '${directory.path}/$fileName';
    
    final file = File(filePath);
    await file.writeAsBytes(pdfBytes);
    
    return filePath;
  }
  
  static Future<String> getShareableFilePath(Uint8List pdfBytes, String surveyId) async {
    final tempDir = await getTemporaryDirectory();
    final fileName = 'Invoice_$surveyId.pdf';
    final filePath = '${tempDir.path}/$fileName';
    
    final file = File(filePath);
    await file.writeAsBytes(pdfBytes);
    
    return filePath;
  }
}

// Invoice notifier
class InvoiceNotifier extends StateNotifier<InvoiceState> {
  final InvoiceRepository? _repository;
  final String? _userId;
  
  InvoiceNotifier(this._repository, this._userId) : super(const InvoiceState());
  
  /// Generate invoice PDF
  Future<void> generateInvoice(
    SurveyModel survey, {
    String? companyName,
    String? companyAddress,
    String? companyPhone,
  }) async {
    state = state.copyWith(
      isGenerating: true,
      errorMessage: null,
      isSuccess: false,
    );
    
    try {
      Uint8List pdfBytes;
      
      final repo = _repository;
      if (AppConfig.useDemoMode || repo == null) {
        pdfBytes = await DemoPdfGenerator.generateInvoicePdf(
          survey,
          companyName: companyName,
          companyAddress: companyAddress,
          companyPhone: companyPhone,
        );
      } else {
        pdfBytes = await repo.generateInvoicePdf(
          survey,
          companyName: companyName,
          companyAddress: companyAddress,
          companyPhone: companyPhone,
        );
      }
      
      state = state.copyWith(
        isGenerating: false,
        pdfBytes: pdfBytes,
        isSuccess: true,
      );
    } catch (e) {
      state = state.copyWith(
        isGenerating: false,
        errorMessage: e.toString(),
      );
    }
  }
  
  /// Upload invoice to Firebase Storage
  Future<String?> uploadInvoice(String surveyId) async {
    // In demo mode, skip upload but return a fake URL
    final repo = _repository;
    if (AppConfig.useDemoMode || repo == null) {
      state = state.copyWith(
        downloadUrl: 'demo://invoice/$surveyId',
        isSuccess: true,
        errorMessage: 'Upload skipped in demo mode. Invoice saved locally only.',
      );
      return 'demo://invoice/$surveyId';
    }
    
    final userId = _userId;
    if (userId == null) {
      state = state.copyWith(errorMessage: 'User not authenticated');
      return null;
    }
    
    if (state.pdfBytes == null) {
      state = state.copyWith(errorMessage: 'No invoice to upload. Generate one first.');
      return null;
    }
    
    state = state.copyWith(
      isUploading: true,
      errorMessage: null,
      isSuccess: false,
    );
    
    try {
      final downloadUrl = await repo.uploadInvoice(
        userId,
        surveyId,
        state.pdfBytes!,
      );
      
      state = state.copyWith(
        isUploading: false,
        downloadUrl: downloadUrl,
        isSuccess: true,
      );
      
      return downloadUrl;
    } catch (e) {
      state = state.copyWith(
        isUploading: false,
        errorMessage: e.toString(),
      );
      return null;
    }
  }
  
  /// Save invoice locally
  Future<String?> saveInvoiceLocally(String surveyId) async {
    if (state.pdfBytes == null) {
      state = state.copyWith(errorMessage: 'No invoice to save. Generate one first.');
      return null;
    }
    
    state = state.copyWith(
      isDownloading: true,
      errorMessage: null,
      isSuccess: false,
    );
    
    try {
      String filePath;
      
      final repo = _repository;
      if (AppConfig.useDemoMode || repo == null) {
        filePath = await DemoPdfGenerator.saveInvoiceLocally(
          state.pdfBytes!,
          surveyId,
        );
      } else {
        filePath = await repo.saveInvoiceLocally(
          state.pdfBytes!,
          surveyId,
        );
      }
      
      state = state.copyWith(
        isDownloading: false,
        localFilePath: filePath,
        isSuccess: true,
      );
      
      return filePath;
    } catch (e) {
      state = state.copyWith(
        isDownloading: false,
        errorMessage: e.toString(),
      );
      return null;
    }
  }
  
  /// Download existing invoice from URL
  Future<String?> downloadExistingInvoice(String invoiceUrl, String surveyId) async {
    // In demo mode, we can't download from Firebase
    final repo = _repository;
    if (AppConfig.useDemoMode || repo == null) {
      state = state.copyWith(
        errorMessage: 'Download from cloud not available in demo mode',
      );
      return null;
    }
    
    state = state.copyWith(
      isDownloading: true,
      errorMessage: null,
      isSuccess: false,
    );
    
    try {
      final filePath = await repo.downloadInvoice(invoiceUrl, surveyId);
      
      state = state.copyWith(
        isDownloading: false,
        localFilePath: filePath,
        isSuccess: true,
      );
      
      return filePath;
    } catch (e) {
      state = state.copyWith(
        isDownloading: false,
        errorMessage: e.toString(),
      );
      return null;
    }
  }
  
  /// Get shareable file path
  Future<String?> getShareableFilePath(String surveyId) async {
    if (state.pdfBytes == null) {
      state = state.copyWith(errorMessage: 'No invoice to share. Generate one first.');
      return null;
    }
    
    try {
      final repo = _repository;
      if (AppConfig.useDemoMode || repo == null) {
        return await DemoPdfGenerator.getShareableFilePath(state.pdfBytes!, surveyId);
      }
      return await repo.getShareableFilePath(state.pdfBytes!, surveyId);
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
      return null;
    }
  }
  
  /// Generate and upload in one step
  Future<String?> generateAndUpload(SurveyModel survey, {
    String? companyName,
    String? companyAddress,
    String? companyPhone,
  }) async {
    await generateInvoice(
      survey,
      companyName: companyName,
      companyAddress: companyAddress,
      companyPhone: companyPhone,
    );
    
    if (state.pdfBytes == null || state.errorMessage != null) {
      return null;
    }
    
    return uploadInvoice(survey.id!);
  }
  
  void reset() {
    state = const InvoiceState();
  }
  
  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}

// Providers
final invoiceProvider = StateNotifierProvider<InvoiceNotifier, InvoiceState>((ref) {
  final repository = ref.watch(invoiceRepositoryProvider);
  final authState = ref.watch(authProvider);
  final userId = authState.userModel?.uid ?? authState.user?.uid;
  return InvoiceNotifier(repository, userId);
});

final invoicePdfBytesProvider = Provider<Uint8List?>((ref) {
  return ref.watch(invoiceProvider).pdfBytes;
});

final invoiceLoadingProvider = Provider<bool>((ref) {
  return ref.watch(invoiceProvider).isLoading;
});
