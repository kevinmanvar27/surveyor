import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/utils/validators.dart';
import '../../../data/models/survey_model.dart';
import '../../../providers/survey_provider.dart';
import '../../../providers/auth_provider.dart';

class SurveyFormScreen extends ConsumerStatefulWidget {
  final String? surveyId;

  const SurveyFormScreen({
    super.key,
    this.surveyId,
  });

  @override
  ConsumerState<SurveyFormScreen> createState() => _SurveyFormScreenState();
}

class _SurveyFormScreenState extends ConsumerState<SurveyFormScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _villageController = TextEditingController();
  final _surveyNumberController = TextEditingController();
  final _applicantController = TextEditingController();
  final _mobileController = TextEditingController();
  final _totalPaymentController = TextEditingController();
  final _receivedPaymentController = TextEditingController();
  
  SurveyType _surveyType = SurveyType.government;
  SurveyStatus _status = SurveyStatus.waiting;
  DateTime? _surveyDate;
  bool _isEditing = false;
  SurveyModel? _existingSurvey;
  
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _isEditing = widget.surveyId != null;
    
    // Initialize animations
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.2, 0.8, curve: Curves.easeOutCubic),
    ));
    
    if (_isEditing) {
      // Delay provider modification to avoid modifying during build
      Future.microtask(() => _loadSurvey());
    }
    
    // Start animation
    _animationController.forward();
  }

  Future<void> _loadSurvey() async {
    if (!mounted) return;
    await ref.read(surveyFormProvider.notifier).loadSurvey(widget.surveyId!);
  }

  void _populateForm(SurveyModel survey) {
    _existingSurvey = survey;
    _villageController.text = survey.villageName;
    _surveyNumberController.text = survey.surveyNumber;
    _applicantController.text = survey.applicantName;
    _mobileController.text = survey.mobileNumber;
    _totalPaymentController.text = survey.totalPayment.toString();
    _receivedPaymentController.text = survey.receivedPayment.toString();
    _surveyType = survey.surveyType;
    _status = survey.status;
    _surveyDate = survey.surveyDate; // Load survey date
  }

  @override
  void dispose() {
    _animationController.dispose();
    _villageController.dispose();
    _surveyNumberController.dispose();
    _applicantController.dispose();
    _mobileController.dispose();
    _totalPaymentController.dispose();
    _receivedPaymentController.dispose();
    super.dispose();
  }

  double get _pendingPayment {
    final total = double.tryParse(_totalPaymentController.text) ?? 0;
    final received = double.tryParse(_receivedPaymentController.text) ?? 0;
    return (total - received).clamp(0, double.infinity);
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    // Get current user ID for Firebase security rules
    final authState = ref.read(authProvider);
    final userId = authState.userModel?.uid ?? authState.user?.uid;
    
    // Validate user ID is not null
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('User not authenticated. Please sign in again.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final survey = SurveyModel(
      id: widget.surveyId,
      userId: userId,
      villageName: _villageController.text.trim(),
      surveyNumber: _surveyNumberController.text.trim(),
      applicantName: _applicantController.text.trim(),
      mobileNumber: _mobileController.text.trim(),
      surveyType: _surveyType,
      totalPayment: double.tryParse(_totalPaymentController.text) ?? 0,
      receivedPayment: double.tryParse(_receivedPaymentController.text) ?? 0,
      pendingPayment: _pendingPayment,
      status: _status,
      createdAt: _existingSurvey?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
      invoiceUrl: _existingSurvey?.invoiceUrl,
      surveyDate: _surveyDate, // Include survey date
    );

    if (_isEditing) {
      await ref.read(surveyFormProvider.notifier).updateSurvey(survey);
    } else {
      await ref.read(surveyFormProvider.notifier).createSurvey(survey);
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final formState = ref.watch(surveyFormProvider);

    // Load existing survey data
    ref.listen<SurveyFormState>(surveyFormProvider, (previous, next) {
      if (next.survey != null && _existingSurvey == null) {
        _populateForm(next.survey!);
        setState(() {});
      }
      
      if (next.isSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isEditing ? loc.surveyUpdated : loc.surveyCreated),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
        ref.read(surveyListProvider.notifier).refresh();
        Navigator.of(context).pop();
      } else if (next.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage!),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
        ref.read(surveyFormProvider.notifier).clearError();
      }
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // Stunning App Bar with Gradient
          SliverAppBar(
            expandedHeight: 120,
            floating: false,
            pinned: true,
            elevation: 0,
            backgroundColor: Colors.transparent,
            flexibleSpace: Container(
              decoration: const BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: FlexibleSpaceBar(
                title: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Text(
                    _isEditing ? 'Edit Survey' : 'Create Survey',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 20,
                    ),
                  ),
                ),
                centerTitle: true,
              ),
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          
          // Form Content
          SliverToBoxAdapter(
            child: formState.isLoading && _isEditing && _existingSurvey == null
                ? _buildLoadingState()
                : AnimatedBuilder(
                    animation: _animationController,
                    builder: (context, child) {
                      return FadeTransition(
                        opacity: _fadeAnimation,
                        child: SlideTransition(
                          position: _slideAnimation,
                          child: _buildFormContent(context, loc, formState),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Container(
      height: 400,
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              strokeWidth: 3,
            ),
            SizedBox(height: 24),
            Text(
              'Loading survey details...',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormContent(BuildContext context, AppLocalizations loc, SurveyFormState formState) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header Card
            _buildHeaderCard(),
            
            const SizedBox(height: 24),
            
            // Personal Information Section
            _buildSectionCard(
              title: 'Personal Information',
              icon: Icons.person_outline_rounded,
              children: [
                _buildStunningTextField(
                  controller: _applicantController,
                  label: 'Applicant Name',
                  hint: 'Enter full name',
                  icon: Icons.person_outline,
                  validator: (value) => Validators.validateApplicantName(
                    value,
                    emptyMessage: 'Applicant name is required',
                  ),
                ),
                
                const SizedBox(height: 20),
                
                _buildStunningTextField(
                  controller: _mobileController,
                  label: 'Mobile Number',
                  hint: 'Enter 10-digit mobile number',
                  icon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                  maxLength: 10,
                  validator: (value) => Validators.validatePhone(
                    value,
                    emptyMessage: 'Mobile number is required',
                    invalidMessage: 'Invalid mobile number',
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Survey Details Section
            _buildSectionCard(
              title: 'Survey Details',
              icon: Icons.location_on_outlined,
              children: [
                _buildStunningTextField(
                  controller: _villageController,
                  label: 'Village Name',
                  hint: 'Enter village name',
                  icon: Icons.location_city_outlined,
                  validator: (value) => Validators.validateVillageName(
                    value,
                    emptyMessage: 'Village name is required',
                  ),
                ),
                
                const SizedBox(height: 20),
                
                _buildStunningTextField(
                  controller: _surveyNumberController,
                  label: 'Survey Number',
                  hint: 'Enter survey number',
                  icon: Icons.numbers_outlined,
                  validator: (value) => Validators.validateSurveyNumber(
                    value,
                    emptyMessage: 'Survey number is required',
                  ),
                ),
                
                const SizedBox(height: 20),
                
                _buildStunningDateField(),
                
                const SizedBox(height: 20),
                
                Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: _buildStunningDropdown<SurveyType>(
                        label: 'Survey Type',
                        value: _surveyType,
                        items: SurveyType.values,
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _surveyType = value;
                            });
                          }
                        },
                        itemLabel: (item) => item.displayName,
                        icon: Icons.business_outlined,
                      ),
                    ),
                    
                    const SizedBox(width: 16),
                    
                    Expanded(
                      flex: 1,
                      child: _buildStunningDropdown<SurveyStatus>(
                        label: 'Status',
                        value: _status,
                        items: SurveyStatus.values,
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _status = value;
                            });
                          }
                        },
                        itemLabel: (item) => item.displayName,
                        icon: Icons.flag_outlined,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Payment Section
            _buildPaymentSection(),
            
            const SizedBox(height: 32),
            
            // Save Button
            _buildStunningSaveButton(formState),
            
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: AppColors.surfaceGradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              _isEditing ? Icons.edit_document : Icons.add_task,
              color: Colors.white,
              size: 32,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            _isEditing ? 'Update Survey Details' : 'Create New Survey',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _isEditing 
                ? 'Modify the survey information below'
                : 'Fill in the details to create a new survey',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark 
            ? AppColors.darkSurface 
            : AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).brightness == Brightness.dark 
                ? AppColors.darkShadow 
                : AppColors.shadow.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: Theme.of(context).brightness == Brightness.dark 
              ? AppColors.darkBorder.withOpacity(0.1)
              : AppColors.border.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          ...children,
        ],
      ),
    );
  }

  Widget _buildStunningTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    int? maxLength,
    String? Function(String?)? validator,
    void Function(String)? onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLength: maxLength,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 20,
            ),
          ),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide(
              color: AppColors.border.withOpacity(0.2),
              width: 1,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: const BorderSide(
              color: AppColors.primary,
              width: 2,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: const BorderSide(
              color: AppColors.error,
              width: 1,
            ),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: const BorderSide(
              color: AppColors.error,
              width: 2,
            ),
          ),
          labelStyle: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          hintStyle: TextStyle(
            color: AppColors.textSecondary.withOpacity(0.7),
            fontSize: 14,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          counterText: '',
        ),
        validator: validator,
        onChanged: onChanged,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }

  Widget _buildStunningDateField() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () async {
          final date = await showDatePicker(
            context: context,
            initialDate: _surveyDate ?? DateTime.now(),
            firstDate: DateTime(2020),
            lastDate: DateTime.now().add(const Duration(days: 365)),
            builder: (context, child) {
              return Theme(
                data: Theme.of(context).copyWith(
                  colorScheme: Theme.of(context).colorScheme.copyWith(
                    primary: AppColors.primary,
                  ),
                ),
                child: child!,
              );
            },
          );
          if (date != null) {
            setState(() {
              _surveyDate = date;
            });
          }
        },
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppColors.border.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                margin: const EdgeInsets.only(right: 12),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.calendar_today_outlined,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Survey Date',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _surveyDate != null
                          ? '${_surveyDate!.day}/${_surveyDate!.month}/${_surveyDate!.year}'
                          : 'Select survey date',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: _surveyDate != null 
                            ? AppColors.textPrimary 
                            : AppColors.textSecondary.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
              if (_surveyDate != null)
                IconButton(
                  icon: const Icon(Icons.clear, color: AppColors.textSecondary),
                  onPressed: () => setState(() => _surveyDate = null),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStunningDropdown<T>({
    required String label,
    required T value,
    required List<T> items,
    required void Function(T?) onChanged,
    required String Function(T) itemLabel,
    required IconData icon,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: DropdownButtonFormField<T>(
        value: value,
        isExpanded: true,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 20,
            ),
          ),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide(
              color: AppColors.border.withOpacity(0.2),
              width: 1,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: const BorderSide(
              color: AppColors.primary,
              width: 2,
            ),
          ),
          labelStyle: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        ),
        items: items.map((item) {
          return DropdownMenuItem<T>(
            value: item,
            child: Text(
              itemLabel(item),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          );
        }).toList(),
        onChanged: onChanged,
        dropdownColor: Colors.white,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }

  Widget _buildPaymentSection() {
    return _buildSectionCard(
      title: 'Payment Details',
      icon: Icons.payments_outlined,
      children: [
        _buildStunningTextField(
          controller: _totalPaymentController,
          label: 'Total Payment',
          hint: 'Enter total amount',
          icon: Icons.currency_rupee,
          keyboardType: TextInputType.number,
          onChanged: (_) => setState(() {}),
          validator: (value) => Validators.validateAmount(
            value,
            emptyMessage: 'Total payment is required',
          ),
        ),
        
        const SizedBox(height: 20),
        
        _buildStunningTextField(
          controller: _receivedPaymentController,
          label: 'Received Payment',
          hint: 'Enter received amount',
          icon: Icons.account_balance_wallet_outlined,
          keyboardType: TextInputType.number,
          onChanged: (_) => setState(() {}),
          validator: (value) {
            final amountError = Validators.validateAmount(value, allowZero: true);
            if (amountError != null) return amountError;
            
            return Validators.validateReceivedPayment(
              value,
              _totalPaymentController.text,
              exceedsMessage: 'Received amount cannot exceed total',
            );
          },
        ),
        
        const SizedBox(height: 24),
        
        // Pending Payment Display
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: _pendingPayment > 0
                ? LinearGradient(
                    colors: [
                      AppColors.cardError,
                      AppColors.cardError.withOpacity(0.7),
                    ],
                  )
                : LinearGradient(
                    colors: [
                      AppColors.cardSuccess,
                      AppColors.cardSuccess.withOpacity(0.7),
                    ],
                  ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: _pendingPayment > 0
                  ? AppColors.error.withOpacity(0.2)
                  : AppColors.success.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _pendingPayment > 0 ? AppColors.error : AppColors.success,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  _pendingPayment > 0 ? Icons.pending_actions : Icons.check_circle,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Pending Payment',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '₹${_pendingPayment.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: _pendingPayment > 0 ? AppColors.error : AppColors.success,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _pendingPayment > 0 ? AppColors.error : AppColors.success,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _pendingPayment > 0 ? 'PENDING' : 'PAID',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStunningSaveButton(SurveyFormState formState) {
    return Container(
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: formState.isLoading ? null : _handleSave,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(vertical: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        child: formState.isLoading
            ? const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _isEditing ? Icons.update : Icons.save,
                    color: Colors.white,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    _isEditing ? 'Update Survey' : 'Create Survey',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}