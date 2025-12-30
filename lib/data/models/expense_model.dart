import 'package:cloud_firestore/cloud_firestore.dart';

/// Model for tracking survey expenses
class ExpenseModel {
  final String? id;
  final String userId;
  final String? surveyId; // Optional link to survey
  final String description;
  final double amount;
  final ExpenseCategory category;
  final DateTime date;
  final DateTime createdAt;
  final DateTime updatedAt;

  ExpenseModel({
    this.id,
    required this.userId,
    this.surveyId,
    required this.description,
    required this.amount,
    required this.category,
    required this.date,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  /// Create from Firestore document
  factory ExpenseModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;

    if (data == null) {
      throw Exception('Document data is null for expense: ${doc.id}');
    }

    return ExpenseModel(
      id: doc.id,
      userId: data['user_id'] as String? ?? '',
      surveyId: data['survey_id'] as String?,
      description: data['description'] as String? ?? '',
      amount: (data['amount'] as num?)?.toDouble() ?? 0.0,
      category: ExpenseCategory.fromString(data['category'] as String? ?? 'other'),
      date: data['date'] != null
          ? (data['date'] as Timestamp).toDate()
          : DateTime.now(),
      createdAt: data['created_at'] != null
          ? (data['created_at'] as Timestamp).toDate()
          : DateTime.now(),
      updatedAt: data['updated_at'] != null
          ? (data['updated_at'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  /// Convert to Firestore map
  Map<String, dynamic> toFirestore() {
    return {
      'user_id': userId,
      'survey_id': surveyId,
      'description': description,
      'amount': amount,
      'category': category.value,
      'date': Timestamp.fromDate(date),
      'created_at': Timestamp.fromDate(createdAt),
      'updated_at': Timestamp.fromDate(DateTime.now()),
    };
  }

  /// Copy with new values
  ExpenseModel copyWith({
    String? id,
    String? userId,
    String? surveyId,
    String? description,
    double? amount,
    ExpenseCategory? category,
    DateTime? date,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ExpenseModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      surveyId: surveyId ?? this.surveyId,
      description: description ?? this.description,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      date: date ?? this.date,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'ExpenseModel(id: $id, description: $description, amount: $amount, category: ${category.value}, date: $date)';
  }
}

/// Expense categories
enum ExpenseCategory {
  travel('Travel'),
  equipment('Equipment'),
  food('Food'),
  fuel('Fuel'),
  accommodation('Accommodation'),
  communication('Communication'),
  other('Other');

  final String value;
  const ExpenseCategory(this.value);

  String get displayName => value;

  static ExpenseCategory fromString(String value) {
    return ExpenseCategory.values.firstWhere(
      (e) => e.value.toLowerCase() == value.toLowerCase(),
      orElse: () => ExpenseCategory.other,
    );
  }
}

/// Time period filter for expenses
enum ExpenseTimePeriod {
  day,
  week,
  month,
  year,
  all,
}
