import 'dart:developer' as developer;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/expense_model.dart';

class ExpenseRepository {
  final FirebaseFirestore _firestore;
  static const String _collection = 'expenses';

  ExpenseRepository(this._firestore);

  /// Get all expenses for a user
  Stream<List<ExpenseModel>> getExpensesStream(String userId) {
    return _firestore
        .collection(_collection)
        .where('user_id', isEqualTo: userId)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ExpenseModel.fromFirestore(doc))
            .toList());
  }

  /// Get expenses for a specific date range
  Future<List<ExpenseModel>> getExpensesByDateRange(
    String userId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('user_id', isEqualTo: userId)
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
          .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
          .orderBy('date', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => ExpenseModel.fromFirestore(doc))
          .toList();
    } catch (e, stackTrace) {
      developer.log(
        'Failed to get expenses by date range',
        name: 'ExpenseRepository',
        error: e,
        stackTrace: stackTrace,
      );
      return [];
    }
  }

  /// Get single expense by ID
  Future<ExpenseModel?> getExpenseById(String expenseId) async {
    try {
      final doc = await _firestore.collection(_collection).doc(expenseId).get();
      if (doc.exists) {
        return ExpenseModel.fromFirestore(doc);
      }
      return null;
    } catch (e, stackTrace) {
      developer.log(
        'Failed to get expense by ID',
        name: 'ExpenseRepository',
        error: e,
        stackTrace: stackTrace,
      );
      return null;
    }
  }

  /// Create new expense
  Future<String?> createExpense(ExpenseModel expense) async {
    try {
      final docRef = await _firestore
          .collection(_collection)
          .add(expense.toFirestore());
      return docRef.id;
    } catch (e, stackTrace) {
      developer.log(
        'Failed to create expense',
        name: 'ExpenseRepository',
        error: e,
        stackTrace: stackTrace,
      );
      return null;
    }
  }

  /// Update existing expense
  Future<bool> updateExpense(ExpenseModel expense) async {
    if (expense.id == null) return false;

    try {
      await _firestore
          .collection(_collection)
          .doc(expense.id)
          .update(expense.toFirestore());
      return true;
    } catch (e, stackTrace) {
      developer.log(
        'Failed to update expense',
        name: 'ExpenseRepository',
        error: e,
        stackTrace: stackTrace,
      );
      return false;
    }
  }

  /// Delete expense
  Future<bool> deleteExpense(String expenseId) async {
    try {
      await _firestore.collection(_collection).doc(expenseId).delete();
      return true;
    } catch (e, stackTrace) {
      developer.log(
        'Failed to delete expense',
        name: 'ExpenseRepository',
        error: e,
        stackTrace: stackTrace,
      );
      return false;
    }
  }

  /// Delete all expenses for a user (used when deleting account)
  Future<bool> deleteAllUserExpenses(String userId) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('user_id', isEqualTo: userId)
          .get();

      final batch = _firestore.batch();
      for (final doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
      return true;
    } catch (e, stackTrace) {
      developer.log(
        'Failed to delete all user expenses',
        name: 'ExpenseRepository',
        error: e,
        stackTrace: stackTrace,
      );
      return false;
    }
  }

  /// Get total expenses for a date range
  Future<double> getTotalExpenses(
    String userId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    final expenses = await getExpensesByDateRange(userId, startDate, endDate);
    return expenses.fold<double>(0.0, (double total, expense) => total + expense.amount);
  }

  /// Get expenses grouped by category for a date range
  Future<Map<ExpenseCategory, double>> getExpensesByCategory(
    String userId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    final expenses = await getExpensesByDateRange(userId, startDate, endDate);
    final Map<ExpenseCategory, double> categoryTotals = {};

    for (final expense in expenses) {
      categoryTotals[expense.category] =
          (categoryTotals[expense.category] ?? 0) + expense.amount;
    }

    return categoryTotals;
  }

  /// Get expenses linked to a specific survey
  Future<List<ExpenseModel>> getExpensesBySurvey(String surveyId, {String? userId}) async {
    try {
      var query = _firestore
          .collection(_collection)
          .where('survey_id', isEqualTo: surveyId);
      
      // Add user_id filter if provided (required for Firestore security rules)
      if (userId != null) {
        query = query.where('user_id', isEqualTo: userId);
      }
      
      // Note: Not using orderBy to avoid requiring composite index
      // Sorting is done in memory instead
      final snapshot = await query.get();

      final expenses = snapshot.docs
          .map((doc) => ExpenseModel.fromFirestore(doc))
          .toList();
      
      // Sort by date descending in memory
      expenses.sort((a, b) => b.date.compareTo(a.date));
      return expenses;
    } catch (e, stackTrace) {
      developer.log(
        'Failed to get expenses by survey',
        name: 'ExpenseRepository',
        error: e,
        stackTrace: stackTrace,
      );
      return [];
    }
  }
}
