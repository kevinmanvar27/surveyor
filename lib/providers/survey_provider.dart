import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/survey_model.dart';
import '../data/repositories/survey_repository.dart';
import '../core/constants/app_constants.dart';
import '../core/config/app_config.dart';
import 'auth_provider.dart';

// Demo data for testing without Firebase
class DemoSurveyData {
  static final List<SurveyModel> surveys = [
    SurveyModel(
      id: 'demo_1',
      villageName: 'Greenfield Village',
      surveyNumber: 'SRV-2024-001',
      applicantName: 'John Smith',
      mobileNumber: '+91 9876543210',
      surveyType: SurveyType.government,
      status: SurveyStatus.waiting,
      totalPayment: 15000,
      receivedPayment: 10000,
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
    SurveyModel(
      id: 'demo_2',
      villageName: 'Sunrise Township',
      surveyNumber: 'SRV-2024-002',
      applicantName: 'Priya Sharma',
      mobileNumber: '+91 9876543211',
      surveyType: SurveyType.private,
      status: SurveyStatus.waiting,
      totalPayment: 20000,
      receivedPayment: 5000,
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
    ),
    SurveyModel(
      id: 'demo_3',
      villageName: 'Lakeside Colony',
      surveyNumber: 'SRV-2024-003',
      applicantName: 'Raj Kumar',
      mobileNumber: '+91 9876543212',
      surveyType: SurveyType.government,
      status: SurveyStatus.done,
      totalPayment: 12000,
      receivedPayment: 12000,
      createdAt: DateTime.now().subtract(const Duration(days: 10)),
    ),
    SurveyModel(
      id: 'demo_4',
      villageName: 'Mountain View',
      surveyNumber: 'SRV-2024-004',
      applicantName: 'Anita Patel',
      mobileNumber: '+91 9876543213',
      surveyType: SurveyType.private,
      status: SurveyStatus.waiting,
      totalPayment: 25000,
      receivedPayment: 15000,
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
  ];
  
  static List<SurveyModel> _demoSurveys = List.from(surveys);
  
  static List<SurveyModel> getSurveys({String? statusFilter, SurveySortOption? sortOption}) {
    var result = List<SurveyModel>.from(_demoSurveys);
    
    if (statusFilter != null && statusFilter != 'All') {
      result = result.where((s) => s.status.displayName == statusFilter).toList();
    }
    
    switch (sortOption ?? SurveySortOption.dateDesc) {
      case SurveySortOption.dateDesc:
        result.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case SurveySortOption.dateAsc:
        result.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        break;
      case SurveySortOption.pendingDesc:
        result.sort((a, b) => b.pendingPayment.compareTo(a.pendingPayment));
        break;
      case SurveySortOption.pendingAsc:
        result.sort((a, b) => a.pendingPayment.compareTo(b.pendingPayment));
        break;
    }
    
    return result;
  }
  
  static SurveyModel? getSurveyById(String id) {
    try {
      return _demoSurveys.firstWhere((s) => s.id == id);
    } catch (_) {
      return null;
    }
  }
  
  static String createSurvey(SurveyModel survey) {
    final id = 'demo_${DateTime.now().millisecondsSinceEpoch}';
    final newSurvey = SurveyModel(
      id: id,
      villageName: survey.villageName,
      surveyNumber: survey.surveyNumber,
      applicantName: survey.applicantName,
      mobileNumber: survey.mobileNumber,
      surveyType: survey.surveyType,
      status: survey.status,
      totalPayment: survey.totalPayment,
      receivedPayment: survey.receivedPayment,
      createdAt: DateTime.now(),
    );
    _demoSurveys.insert(0, newSurvey);
    return id;
  }
  
  static void updateSurvey(SurveyModel survey) {
    final index = _demoSurveys.indexWhere((s) => s.id == survey.id);
    if (index != -1) {
      _demoSurveys[index] = survey;
    }
  }
  
  static void deleteSurvey(String id) {
    _demoSurveys.removeWhere((s) => s.id == id);
  }
  
  static Map<String, int> getCounts() {
    return {
      'Working': _demoSurveys.where((s) => s.status == SurveyStatus.working).length,
      'Waiting': _demoSurveys.where((s) => s.status == SurveyStatus.waiting).length,
      'Done': _demoSurveys.where((s) => s.status == SurveyStatus.done).length,
      'Total': _demoSurveys.length,
    };
  }
  
  static double getTotalPending() {
    return _demoSurveys.fold(0.0, (total, s) => total + s.pendingPayment);
  }
}

// Survey list state
class SurveyListState {
  final List<SurveyModel> surveys;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasMore;
  final String? errorMessage;
  final String searchQuery;
  final String statusFilter;
  final SurveySortOption sortOption;
  final DocumentSnapshot? lastDocument;
  
  const SurveyListState({
    this.surveys = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.hasMore = true,
    this.errorMessage,
    this.searchQuery = '',
    this.statusFilter = 'All',
    this.sortOption = SurveySortOption.dateDesc,
    this.lastDocument,
  });
  
  SurveyListState copyWith({
    List<SurveyModel>? surveys,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasMore,
    String? errorMessage,
    String? searchQuery,
    String? statusFilter,
    SurveySortOption? sortOption,
    DocumentSnapshot? lastDocument,
    bool clearLastDocument = false,
  }) {
    return SurveyListState(
      surveys: surveys ?? this.surveys,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      errorMessage: errorMessage,
      searchQuery: searchQuery ?? this.searchQuery,
      statusFilter: statusFilter ?? this.statusFilter,
      sortOption: sortOption ?? this.sortOption,
      lastDocument: clearLastDocument ? null : (lastDocument ?? this.lastDocument),
    );
  }
  
  List<SurveyModel> get filteredSurveys {
    if (searchQuery.isEmpty) return surveys;
    
    final query = searchQuery.toLowerCase();
    return surveys.where((survey) {
      return survey.villageName.toLowerCase().contains(query) ||
          survey.surveyNumber.toLowerCase().contains(query) ||
          survey.applicantName.toLowerCase().contains(query) ||
          survey.mobileNumber.contains(query);
    }).toList();
  }
}

// Survey list notifier
class SurveyListNotifier extends StateNotifier<SurveyListState> {
  final SurveyRepository? _repository;
  final String? _userId;
  
  SurveyListNotifier(this._repository, this._userId) : super(const SurveyListState()) {
    loadSurveys();
  }
  
  Future<void> loadSurveys({bool refresh = false}) async {
    if (state.isLoading) return;
    
    state = state.copyWith(
      isLoading: true,
      errorMessage: null,
      surveys: refresh ? [] : state.surveys,
      clearLastDocument: refresh,
      hasMore: refresh ? true : state.hasMore,
    );
    
    try {
      List<SurveyModel> surveys;
      
      // Use demo data if in demo mode or repository is null
      final repo = _repository;
      if (AppConfig.useDemoMode || repo == null) {
        await Future.delayed(const Duration(milliseconds: 300)); // Simulate network delay
        surveys = DemoSurveyData.getSurveys(
          statusFilter: state.statusFilter == 'All' ? null : state.statusFilter,
          sortOption: state.sortOption,
        );
      } else {
        surveys = await repo.getSurveys(
          userId: _userId ?? '',
          statusFilter: state.statusFilter == 'All' ? null : state.statusFilter,
          sortOption: state.sortOption,
          limit: AppConstants.pageSize,
        );
      }
      
      state = state.copyWith(
        surveys: surveys,
        isLoading: false,
        hasMore: AppConfig.useDemoMode ? false : surveys.length >= AppConstants.pageSize,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }
  
  Future<void> loadMore() async {
    if (state.isLoadingMore || !state.hasMore || state.isLoading) return;
    
    final repo = _repository;
    if (AppConfig.useDemoMode || repo == null) return; // No pagination in demo mode
    
    state = state.copyWith(isLoadingMore: true, errorMessage: null);
    
    try {
      final lastDoc = await repo.getLastDocument(state.surveys.length);
      
      final moreSurveys = await repo.getSurveys(
        userId: _userId ?? '',
        statusFilter: state.statusFilter == 'All' ? null : state.statusFilter,
        sortOption: state.sortOption,
        limit: AppConstants.pageSize,
        lastDocument: lastDoc,
      );
      
      state = state.copyWith(
        surveys: [...state.surveys, ...moreSurveys],
        isLoadingMore: false,
        hasMore: moreSurveys.length >= AppConstants.pageSize,
        lastDocument: lastDoc,
      );
    } catch (e) {
      state = state.copyWith(
        isLoadingMore: false,
        errorMessage: e.toString(),
      );
    }
  }
  
  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }
  
  Future<void> setStatusFilter(String status) async {
    if (state.statusFilter == status) return;
    
    state = state.copyWith(
      statusFilter: status,
      surveys: [],
      clearLastDocument: true,
      hasMore: true,
    );
    await loadSurveys(refresh: true);
  }
  
  Future<void> setSortOption(SurveySortOption option) async {
    if (state.sortOption == option) return;
    
    state = state.copyWith(
      sortOption: option,
      surveys: [],
      clearLastDocument: true,
      hasMore: true,
    );
    await loadSurveys(refresh: true);
  }
  
  Future<void> refresh() async {
    await loadSurveys(refresh: true);
  }
  
  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}

// Survey form state
class SurveyFormState {
  final bool isLoading;
  final bool isSuccess;
  final String? errorMessage;
  final SurveyModel? survey;
  
  const SurveyFormState({
    this.isLoading = false,
    this.isSuccess = false,
    this.errorMessage,
    this.survey,
  });
  
  SurveyFormState copyWith({
    bool? isLoading,
    bool? isSuccess,
    String? errorMessage,
    SurveyModel? survey,
  }) {
    return SurveyFormState(
      isLoading: isLoading ?? this.isLoading,
      isSuccess: isSuccess ?? this.isSuccess,
      errorMessage: errorMessage,
      survey: survey ?? this.survey,
    );
  }
}

// Survey form notifier
class SurveyFormNotifier extends StateNotifier<SurveyFormState> {
  final SurveyRepository? _repository;
  
  SurveyFormNotifier(this._repository) : super(const SurveyFormState());
  
  Future<void> loadSurvey(String surveyId) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    
    try {
      SurveyModel? survey;
      
      final repo = _repository;
      if (AppConfig.useDemoMode || repo == null) {
        await Future.delayed(const Duration(milliseconds: 200));
        survey = DemoSurveyData.getSurveyById(surveyId);
      } else {
        survey = await repo.getSurveyById(surveyId);
      }
      
      state = state.copyWith(
        isLoading: false,
        survey: survey,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }
  
  Future<String?> createSurvey(SurveyModel survey) async {
    state = state.copyWith(isLoading: true, errorMessage: null, isSuccess: false);
    
    try {
      String id;
      
      final repo = _repository;
      if (AppConfig.useDemoMode || repo == null) {
        await Future.delayed(const Duration(milliseconds: 300));
        id = DemoSurveyData.createSurvey(survey);
      } else {
        id = await repo.createSurvey(survey);
      }
      
      state = state.copyWith(
        isLoading: false,
        isSuccess: true,
      );
      return id;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
      return null;
    }
  }
  
  Future<bool> updateSurvey(SurveyModel survey) async {
    state = state.copyWith(isLoading: true, errorMessage: null, isSuccess: false);
    
    try {
      final repo = _repository;
      if (AppConfig.useDemoMode || repo == null) {
        await Future.delayed(const Duration(milliseconds: 300));
        DemoSurveyData.updateSurvey(survey);
      } else {
        await repo.updateSurvey(survey);
      }
      
      state = state.copyWith(
        isLoading: false,
        isSuccess: true,
        survey: survey,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
      return false;
    }
  }
  
  Future<bool> deleteSurvey(String surveyId) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    
    try {
      final repo = _repository;
      if (AppConfig.useDemoMode || repo == null) {
        await Future.delayed(const Duration(milliseconds: 300));
        DemoSurveyData.deleteSurvey(surveyId);
      } else {
        await repo.deleteSurvey(surveyId);
      }
      
      state = state.copyWith(isLoading: false, isSuccess: true);
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
      return false;
    }
  }
  
  void reset() {
    state = const SurveyFormState();
  }
  
  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}

// Providers
final surveyListProvider = StateNotifierProvider<SurveyListNotifier, SurveyListState>((ref) {
  final repository = ref.watch(surveyRepositoryProvider);
  final authState = ref.watch(authProvider);
  final userId = authState.userModel?.uid ?? authState.user?.uid;
  return SurveyListNotifier(repository, userId);
});

final surveyFormProvider = StateNotifierProvider<SurveyFormNotifier, SurveyFormState>((ref) {
  final repository = ref.watch(surveyRepositoryProvider);
  return SurveyFormNotifier(repository);
});

final surveyDetailProvider = FutureProvider.family<SurveyModel?, String>((ref, surveyId) async {
  if (AppConfig.useDemoMode) {
    return DemoSurveyData.getSurveyById(surveyId);
  }
  final repository = ref.watch(surveyRepositoryProvider);
  if (repository == null) {
    return DemoSurveyData.getSurveyById(surveyId);
  }
  return repository.getSurveyById(surveyId);
});

final surveyStreamProvider = StreamProvider.family<SurveyModel?, String>((ref, surveyId) {
  if (AppConfig.useDemoMode) {
    return Stream.value(DemoSurveyData.getSurveyById(surveyId));
  }
  final repository = ref.watch(surveyRepositoryProvider);
  if (repository == null) {
    return Stream.value(DemoSurveyData.getSurveyById(surveyId));
  }
  return repository.streamSurvey(surveyId);
});

final surveysStreamProvider = StreamProvider<List<SurveyModel>>((ref) {
  if (AppConfig.useDemoMode) {
    return Stream.value(DemoSurveyData.getSurveys());
  }
  final repository = ref.watch(surveyRepositoryProvider);
  if (repository == null) {
    return Stream.value(DemoSurveyData.getSurveys());
  }
  final authState = ref.watch(authProvider);
  final userId = authState.userModel?.uid ?? authState.user?.uid ?? '';
  return repository.streamSurveys(userId: userId);
});

final surveyCountsProvider = FutureProvider<Map<String, int>>((ref) async {
  if (AppConfig.useDemoMode) {
    return DemoSurveyData.getCounts();
  }
  final repository = ref.watch(surveyRepositoryProvider);
  if (repository == null) {
    return DemoSurveyData.getCounts();
  }
  final authState = ref.watch(authProvider);
  final userId = authState.userModel?.uid ?? authState.user?.uid ?? '';
  return repository.getSurveysCountByStatus(userId);
});

final totalPendingPaymentProvider = FutureProvider<double>((ref) async {
  if (AppConfig.useDemoMode) {
    return DemoSurveyData.getTotalPending();
  }
  final repository = ref.watch(surveyRepositoryProvider);
  if (repository == null) {
    return DemoSurveyData.getTotalPending();
  }
  final authState = ref.watch(authProvider);
  final userId = authState.userModel?.uid ?? authState.user?.uid ?? '';
  return repository.getTotalPendingPayment(userId);
});

/// Provider to get waiting surveys for expense linking
final waitingSurveysProvider = FutureProvider<List<SurveyModel>>((ref) async {
  if (AppConfig.useDemoMode) {
    return DemoSurveyData.getSurveys(statusFilter: 'Waiting');
  }
  final repository = ref.watch(surveyRepositoryProvider);
  if (repository == null) {
    return DemoSurveyData.getSurveys(statusFilter: 'Waiting');
  }
  final authState = ref.watch(authProvider);
  final userId = authState.userModel?.uid ?? authState.user?.uid ?? '';
  return repository.getSurveys(
    userId: userId,
    statusFilter: 'Waiting',
    sortOption: SurveySortOption.dateDesc,
  );
});
