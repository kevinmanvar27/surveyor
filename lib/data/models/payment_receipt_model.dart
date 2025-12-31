import 'package:cloud_firestore/cloud_firestore.dart';

/// Model for tracking individual payment receipts
class PaymentReceiptModel {
  final String? id;
  final double amount;
  final DateTime receivedDate;
  final String? notes;
  final DateTime createdAt;

  PaymentReceiptModel({
    this.id,
    required this.amount,
    required this.receivedDate,
    this.notes,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  /// Create from Firestore map
  factory PaymentReceiptModel.fromMap(Map<String, dynamic> data, {String? id}) {
    return PaymentReceiptModel(
      id: id ?? data['id'] as String?,
      amount: (data['amount'] as num?)?.toDouble() ?? 0.0,
      receivedDate: data['received_date'] != null
          ? (data['received_date'] is Timestamp
              ? (data['received_date'] as Timestamp).toDate()
              : DateTime.parse(data['received_date'] as String))
          : DateTime.now(),
      notes: data['notes'] as String?,
      createdAt: data['created_at'] != null
          ? (data['created_at'] is Timestamp
              ? (data['created_at'] as Timestamp).toDate()
              : DateTime.parse(data['created_at'] as String))
          : DateTime.now(),
    );
  }

  /// Convert to Firestore map
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'amount': amount,
      'received_date': Timestamp.fromDate(receivedDate),
      'notes': notes,
      'created_at': Timestamp.fromDate(createdAt),
    };
  }

  /// Copy with new values
  PaymentReceiptModel copyWith({
    String? id,
    double? amount,
    DateTime? receivedDate,
    String? notes,
    DateTime? createdAt,
  }) {
    return PaymentReceiptModel(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      receivedDate: receivedDate ?? this.receivedDate,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'PaymentReceiptModel(id: $id, amount: $amount, receivedDate: $receivedDate, notes: $notes)';
  }
}
