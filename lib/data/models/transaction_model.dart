import 'package:cloud_firestore/cloud_firestore.dart';

/// Transaction types for tracking different kinds of transactions
enum TransactionType {
  surveyPayment('Survey Payment'),      // Total payment when survey is created
  receivedPayment('Received Payment'),  // Payment received from client
  expense('Expense');                   // Expense linked to survey

  final String value;
  const TransactionType(this.value);

  String get displayName => value;

  static TransactionType fromString(String value) {
    return TransactionType.values.firstWhere(
      (e) => e.value.toLowerCase() == value.toLowerCase(),
      orElse: () => TransactionType.surveyPayment,
    );
  }
}

/// Model for tracking all financial transactions
class TransactionModel {
  final String? id;
  final String userId;
  final String? surveyId;           // Link to survey (if applicable)
  final String? expenseId;          // Link to expense (if applicable)
  final TransactionType type;
  final String description;
  final double amount;
  final bool isCredit;              // true = money coming in, false = money going out
  final DateTime date;
  final DateTime createdAt;
  
  // Additional info for display
  final String? surveyNumber;       // For quick reference
  final String? applicantName;      // For quick reference
  final String? expenseCategory;    // For expense transactions

  TransactionModel({
    this.id,
    required this.userId,
    this.surveyId,
    this.expenseId,
    required this.type,
    required this.description,
    required this.amount,
    required this.isCredit,
    required this.date,
    DateTime? createdAt,
    this.surveyNumber,
    this.applicantName,
    this.expenseCategory,
  }) : createdAt = createdAt ?? DateTime.now();

  /// Create from Firestore document
  factory TransactionModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;

    if (data == null) {
      throw Exception('Document data is null for transaction: ${doc.id}');
    }

    return TransactionModel(
      id: doc.id,
      userId: data['user_id'] as String? ?? '',
      surveyId: data['survey_id'] as String?,
      expenseId: data['expense_id'] as String?,
      type: TransactionType.fromString(data['type'] as String? ?? 'Survey Payment'),
      description: data['description'] as String? ?? '',
      amount: (data['amount'] as num?)?.toDouble() ?? 0.0,
      isCredit: data['is_credit'] as bool? ?? true,
      date: data['date'] != null
          ? (data['date'] as Timestamp).toDate()
          : DateTime.now(),
      createdAt: data['created_at'] != null
          ? (data['created_at'] as Timestamp).toDate()
          : DateTime.now(),
      surveyNumber: data['survey_number'] as String?,
      applicantName: data['applicant_name'] as String?,
      expenseCategory: data['expense_category'] as String?,
    );
  }

  /// Convert to Firestore map
  Map<String, dynamic> toFirestore() {
    return {
      'user_id': userId,
      'survey_id': surveyId,
      'expense_id': expenseId,
      'type': type.value,
      'description': description,
      'amount': amount,
      'is_credit': isCredit,
      'date': Timestamp.fromDate(date),
      'created_at': Timestamp.fromDate(createdAt),
      'survey_number': surveyNumber,
      'applicant_name': applicantName,
      'expense_category': expenseCategory,
    };
  }

  /// Copy with new values
  TransactionModel copyWith({
    String? id,
    String? userId,
    String? surveyId,
    String? expenseId,
    TransactionType? type,
    String? description,
    double? amount,
    bool? isCredit,
    DateTime? date,
    DateTime? createdAt,
    String? surveyNumber,
    String? applicantName,
    String? expenseCategory,
  }) {
    return TransactionModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      surveyId: surveyId ?? this.surveyId,
      expenseId: expenseId ?? this.expenseId,
      type: type ?? this.type,
      description: description ?? this.description,
      amount: amount ?? this.amount,
      isCredit: isCredit ?? this.isCredit,
      date: date ?? this.date,
      createdAt: createdAt ?? this.createdAt,
      surveyNumber: surveyNumber ?? this.surveyNumber,
      applicantName: applicantName ?? this.applicantName,
      expenseCategory: expenseCategory ?? this.expenseCategory,
    );
  }

  @override
  String toString() {
    return 'TransactionModel(id: $id, type: ${type.value}, amount: $amount, isCredit: $isCredit, date: $date)';
  }
}

/// Grouped transactions by date
class TransactionGroup {
  final DateTime date;
  final List<TransactionModel> transactions;
  final double totalCredit;
  final double totalDebit;

  TransactionGroup({
    required this.date,
    required this.transactions,
  }) : totalCredit = transactions
            .where((t) => t.isCredit)
            .fold(0.0, (total, t) => total + t.amount),
       totalDebit = transactions
            .where((t) => !t.isCredit)
            .fold(0.0, (total, t) => total + t.amount);

  double get netAmount => totalCredit - totalDebit;
}
