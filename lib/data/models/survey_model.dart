import 'package:cloud_firestore/cloud_firestore.dart';
import 'payment_receipt_model.dart';

/// Enum for survey status
enum SurveyStatus {
  working('Working'),
  waiting('Waiting'),
  done('Done');
  
  final String value;
  const SurveyStatus(this.value);
  
  /// Display name for UI
  String get displayName => value;
  
  static SurveyStatus fromString(String value) {
    return SurveyStatus.values.firstWhere(
      (e) => e.value.toLowerCase() == value.toLowerCase(),
      orElse: () => SurveyStatus.waiting,
    );
  }
}

/// Enum for survey type (Government/Private)
enum SurveyType {
  government('Government'),
  private('Private');
  
  final String value;
  const SurveyType(this.value);
  
  /// Display name for UI
  String get displayName => value;
  
  static SurveyType fromString(String value) {
    return SurveyType.values.firstWhere(
      (e) => e.value.toLowerCase() == value.toLowerCase(),
      orElse: () => SurveyType.government,
    );
  }
}



/// Sort options for surveys
enum SurveySortOption {
  dateDesc,
  dateAsc,
  pendingDesc,
  pendingAsc,
}

class SurveyModel {
  final String? id;
  final String? userId;  // Added for Firebase security rules
  final String villageName;
  final String surveyNumber;
  final String mobileNumber;
  final String applicantName;
  final SurveyType surveyType;
  final double totalPayment;
  final double receivedPayment;
  final double pendingPayment;
  final SurveyStatus status;
  final String? invoiceUrl;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? surveyDate; // Added survey date field
  final List<PaymentReceiptModel> paymentReceipts; // Payment history
  
  SurveyModel({
    this.id,
    this.userId,
    required this.villageName,
    required this.surveyNumber,
    required this.mobileNumber,
    required this.applicantName,
    this.surveyType = SurveyType.government,
    required this.totalPayment,
    required this.receivedPayment,
    double? pendingPayment,
    required this.status,
    this.invoiceUrl,
    this.notes,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.surveyDate, // Survey date can be null initially
    List<PaymentReceiptModel>? paymentReceipts,
  }) : paymentReceipts = paymentReceipts ?? [],
       pendingPayment = pendingPayment ?? (totalPayment - receivedPayment),
       createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now() {
    // Validate payment amounts
    if (totalPayment < 0) {
      throw ArgumentError('Total payment cannot be negative');
    }
    if (receivedPayment < 0) {
      throw ArgumentError('Received payment cannot be negative');
    }
    if (receivedPayment > totalPayment) {
      throw ArgumentError('Received payment cannot exceed total payment');
    }
  }
  
  /// Create from Firestore document
  factory SurveyModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;
    
    // Handle null data case
    if (data == null) {
      throw Exception('Document data is null for survey: ${doc.id}');
    }
    
    try {
      return SurveyModel(
        id: doc.id,
        userId: data['user_id'] as String?,
        villageName: data['village_name'] as String? ?? '',
        surveyNumber: data['survey_number'] as String? ?? '',
        mobileNumber: data['mobile_number'] as String? ?? '',
        applicantName: data['applicant_name'] as String? ?? '',
        surveyType: SurveyType.fromString(data['survey_type'] as String? ?? 'Government'),
        totalPayment: (data['total_payment'] as num?)?.toDouble() ?? 0.0,
        receivedPayment: (data['received_payment'] as num?)?.toDouble() ?? 0.0,
        pendingPayment: (data['pending_payment'] as num?)?.toDouble() ?? 0.0,
        status: SurveyStatus.fromString(data['status'] as String? ?? 'Waiting'),
        invoiceUrl: data['invoice_url'] as String?,
        notes: data['notes'] as String?,
        createdAt: data['created_at'] != null 
            ? (data['created_at'] as Timestamp).toDate()
            : DateTime.now(),
        updatedAt: data['updated_at'] != null 
            ? (data['updated_at'] as Timestamp).toDate()
            : DateTime.now(),
        surveyDate: data['survey_date'] != null 
            ? (data['survey_date'] as Timestamp).toDate()
            : null,
        paymentReceipts: (data['payment_receipts'] as List<dynamic>?)
            ?.map((e) => PaymentReceiptModel.fromMap(e as Map<String, dynamic>))
            .toList() ?? [],
      );
    } catch (e) {
      throw Exception('Failed to parse survey data for ${doc.id}: $e');
    }
  }
  
  /// Convert to Firestore map
  Map<String, dynamic> toFirestore() {
    return {
      'user_id': userId,
      'village_name': villageName,
      'survey_number': surveyNumber,
      'mobile_number': mobileNumber,
      'applicant_name': applicantName,
      'survey_type': surveyType.value,
      'total_payment': totalPayment,
      'received_payment': receivedPayment,
      'pending_payment': totalPayment - receivedPayment,
      'status': status.value,
      'invoice_url': invoiceUrl,
      'notes': notes,
      'created_at': Timestamp.fromDate(createdAt),
      'updated_at': Timestamp.fromDate(DateTime.now()),
      'survey_date': surveyDate != null ? Timestamp.fromDate(surveyDate!) : null,
      'payment_receipts': paymentReceipts.map((e) => e.toMap()).toList(),
    };
  }
  
  /// Copy with new values
  SurveyModel copyWith({
    String? id,
    String? userId,
    String? villageName,
    String? surveyNumber,
    String? mobileNumber,
    String? applicantName,
    SurveyType? surveyType,
    double? totalPayment,
    double? receivedPayment,
    double? pendingPayment,
    SurveyStatus? status,
    String? invoiceUrl,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? surveyDate,
    List<PaymentReceiptModel>? paymentReceipts,
  }) {
    return SurveyModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      villageName: villageName ?? this.villageName,
      surveyNumber: surveyNumber ?? this.surveyNumber,
      mobileNumber: mobileNumber ?? this.mobileNumber,
      applicantName: applicantName ?? this.applicantName,
      surveyType: surveyType ?? this.surveyType,
      totalPayment: totalPayment ?? this.totalPayment,
      receivedPayment: receivedPayment ?? this.receivedPayment,
      pendingPayment: pendingPayment ?? this.pendingPayment,
      status: status ?? this.status,
      invoiceUrl: invoiceUrl ?? this.invoiceUrl,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      surveyDate: surveyDate ?? this.surveyDate,
      paymentReceipts: paymentReceipts ?? this.paymentReceipts,
    );
  }
  
  @override
  String toString() {
    return 'SurveyModel(id: $id, villageName: $villageName, surveyNumber: $surveyNumber, '
        'applicantName: $applicantName, status: ${status.value}, pendingPayment: $pendingPayment)';
  }
}
