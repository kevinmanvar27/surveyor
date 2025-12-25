import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/survey_model.dart';
import '../../core/constants/app_constants.dart';
import '../../core/config/app_config.dart';

final surveyRepositoryProvider = Provider<SurveyRepository?>((ref) {
  // In demo mode, return null (will use demo data provider instead)
  if (AppConfig.useDemoMode) {
    return null;
  }
  return SurveyRepository(FirebaseFirestore.instance);
});

class SurveyRepository {
  final FirebaseFirestore _firestore;
  
  SurveyRepository(this._firestore);
  
  CollectionReference<Map<String, dynamic>> get _surveysCollection =>
      _firestore.collection(AppConstants.surveysCollection);
  
  /// Create a new survey
  Future<String> createSurvey(SurveyModel survey) async {
    final docRef = await _surveysCollection.add(survey.toFirestore());
    return docRef.id;
  }
  
  /// Update an existing survey
  Future<void> updateSurvey(SurveyModel survey) async {
    if (survey.id == null) {
      throw Exception('Survey ID is required for update');
    }
    await _surveysCollection.doc(survey.id).update(survey.toFirestore());
  }
  
  /// Delete a survey
  Future<void> deleteSurvey(String surveyId) async {
    await _surveysCollection.doc(surveyId).delete();
  }
  
  /// Get a single survey by ID
  Future<SurveyModel?> getSurveyById(String surveyId) async {
    final doc = await _surveysCollection.doc(surveyId).get();
    if (doc.exists) {
      return SurveyModel.fromFirestore(doc);
    }
    return null;
  }
  
  /// Stream a single survey
  Stream<SurveyModel?> streamSurvey(String surveyId) {
    return _surveysCollection.doc(surveyId).snapshots().map((doc) {
      if (doc.exists) {
        return SurveyModel.fromFirestore(doc);
      }
      return null;
    });
  }
  
  /// Get all surveys with optional filtering, sorting, and pagination
  Future<List<SurveyModel>> getSurveys({
    required String userId,
    String? searchQuery,
    String? statusFilter,
    SurveySortOption sortOption = SurveySortOption.dateDesc,
    int limit = AppConstants.pageSize,
    DocumentSnapshot? lastDocument,
  }) async {
    Query<Map<String, dynamic>> query = _surveysCollection;
    
    // Filter by user_id (required for Firebase security rules)
    query = query.where('user_id', isEqualTo: userId);
    
    // Apply status filter
    if (statusFilter != null && statusFilter.isNotEmpty && statusFilter != 'All') {
      query = query.where('status', isEqualTo: statusFilter);
    }
    
    // Apply sorting
    switch (sortOption) {
      case SurveySortOption.dateDesc:
        query = query.orderBy('created_at', descending: true);
        break;
      case SurveySortOption.dateAsc:
        query = query.orderBy('created_at', descending: false);
        break;
      case SurveySortOption.pendingDesc:
        query = query.orderBy('pending_payment', descending: true);
        break;
      case SurveySortOption.pendingAsc:
        query = query.orderBy('pending_payment', descending: false);
        break;
    }
    
    // Apply pagination
    if (lastDocument != null) {
      query = query.startAfterDocument(lastDocument);
    }
    
    query = query.limit(limit);
    
    final snapshot = await query.get();
    final surveys = snapshot.docs.map((doc) => SurveyModel.fromFirestore(doc)).toList();
    
    // Apply search filter locally (Firestore doesn't support full-text search)
    if (searchQuery != null && searchQuery.isNotEmpty) {
      final searchLower = searchQuery.toLowerCase();
      return surveys.where((survey) {
        return survey.villageName.toLowerCase().contains(searchLower) ||
            survey.surveyNumber.toLowerCase().contains(searchLower) ||
            survey.applicantName.toLowerCase().contains(searchLower) ||
            survey.mobileNumber.contains(searchLower);
      }).toList();
    }
    
    return surveys;
  }
  
  /// Stream surveys with real-time updates
  Stream<List<SurveyModel>> streamSurveys({
    required String userId,
    String? statusFilter,
    SurveySortOption sortOption = SurveySortOption.dateDesc,
    int limit = AppConstants.pageSize,
  }) {
    Query<Map<String, dynamic>> query = _surveysCollection;
    
    // Filter by user_id (required for Firebase security rules)
    query = query.where('user_id', isEqualTo: userId);
    
    // Apply status filter
    if (statusFilter != null && statusFilter.isNotEmpty && statusFilter != 'All') {
      query = query.where('status', isEqualTo: statusFilter);
    }
    
    // Apply sorting
    switch (sortOption) {
      case SurveySortOption.dateDesc:
        query = query.orderBy('created_at', descending: true);
        break;
      case SurveySortOption.dateAsc:
        query = query.orderBy('created_at', descending: false);
        break;
      case SurveySortOption.pendingDesc:
        query = query.orderBy('pending_payment', descending: true);
        break;
      case SurveySortOption.pendingAsc:
        query = query.orderBy('pending_payment', descending: false);
        break;
    }
    
    query = query.limit(limit);
    
    return query.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => SurveyModel.fromFirestore(doc)).toList();
    });
  }
  
  /// Update invoice URL for a survey
  Future<void> updateInvoiceUrl(String surveyId, String invoiceUrl) async {
    await _surveysCollection.doc(surveyId).update({
      'invoice_url': invoiceUrl,
      'updated_at': Timestamp.now(),
    });
  }
  
  /// Get surveys count by status
  Future<Map<String, int>> getSurveysCountByStatus(String userId) async {
    final snapshot = await _surveysCollection
        .where('user_id', isEqualTo: userId)
        .get();
    final counts = <String, int>{
      'Working': 0,
      'Waiting': 0,
      'Done': 0,
      'Total': snapshot.docs.length,
    };
    
    for (final doc in snapshot.docs) {
      final status = doc.data()['status'] as String?;
      if (status != null && counts.containsKey(status)) {
        counts[status] = counts[status]! + 1;
      }
    }
    
    return counts;
  }
  
  /// Get total pending payment
  Future<double> getTotalPendingPayment(String userId) async {
    final snapshot = await _surveysCollection
        .where('user_id', isEqualTo: userId)
        .get();
    double total = 0;
    for (final doc in snapshot.docs) {
      total += (doc.data()['pending_payment'] ?? 0).toDouble();
    }
    return total;
  }
  
  /// Get last document for pagination
  Future<DocumentSnapshot?> getLastDocument(int offset) async {
    final snapshot = await _surveysCollection
        .orderBy('created_at', descending: true)
        .limit(offset)
        .get();
    
    if (snapshot.docs.isNotEmpty) {
      return snapshot.docs.last;
    }
    return null;
  }
}
