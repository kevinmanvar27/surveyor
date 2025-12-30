import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/utils/validators.dart';
import '../../../data/models/survey_model.dart';
import '../../../data/models/expense_model.dart';
import '../../../providers/survey_provider.dart';
import '../../../providers/expense_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../expense/widgets/expense_form_dialog.dart';

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
        // Reset the form state immediately to prevent re-triggering on next navigation
        ref.read(surveyFormProvider.notifier).reset();
        
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
    return SizedBox(
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
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
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
                
                const SizedBox(height: 12),
                
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
            
            const SizedBox(height: 16),
            
            // Survey Details Section
            _buildSectionCard(
              title: 'Survey Details',
              icon: Icons.location_on_outlined,
              children: [
                // Village and Survey Number in a row
                Row(
                  children: [
                    Expanded(
                      child: _buildStunningTextField(
                        controller: _villageController,
                        label: 'Village',
                        hint: 'Village name',
                        icon: Icons.location_city_outlined,
                        validator: (value) => Validators.validateVillageName(
                          value,
                          emptyMessage: 'Required',
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStunningTextField(
                        controller: _surveyNumberController,
                        label: 'Survey No.',
                        hint: 'Number',
                        icon: Icons.numbers_outlined,
                        validator: (value) => Validators.validateSurveyNumber(
                          value,
                          emptyMessage: 'Required',
                        ),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 12),
                
                _buildStunningDateField(),
                
                const SizedBox(height: 12),
                
                // Survey Type and Status in a row
                Row(
                  children: [
                    Expanded(
                      child: _buildStunningDropdown<SurveyType>(
                        label: 'Type',
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
                    const SizedBox(width: 12),
                    Expanded(
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
            
            const SizedBox(height: 16),
            
            // Payment Section
            _buildPaymentSection(),
            
            // Expenses Section (only show when editing existing survey)
            if (_isEditing && widget.surveyId != null) ...[
              const SizedBox(height: 16),
              _buildExpensesSection(loc),
            ],
            
            const SizedBox(height: 20),
            
            // Save Button
            _buildStunningSaveButton(formState),
            
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(16), // Reduced from 24
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
                padding: const EdgeInsets.all(8), // Reduced from 12
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(12), // Reduced from 16
                ),
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: 18, // Reduced from 20
                ),
              ),
              const SizedBox(width: 12), // Reduced from 16
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16, // Reduced from 18
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16), // Reduced from 24
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
            margin: const EdgeInsets.all(8), // Reduced from 12
            padding: const EdgeInsets.all(6), // Reduced from 8
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(10), // Reduced from 12
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 16, // Reduced from 20
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
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14), // Reduced
          counterText: '',
        ),
        validator: validator,
        onChanged: onChanged,
        style: const TextStyle(
          fontSize: 15, // Reduced from 16
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
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12), // Reduced
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
                margin: const EdgeInsets.only(right: 10), // Reduced from 12
                padding: const EdgeInsets.all(6), // Reduced from 8
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(10), // Reduced from 12
                ),
                child: const Icon(
                  Icons.calendar_today_outlined,
                  color: Colors.white,
                  size: 16, // Reduced from 20
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
                        fontSize: 12, // Reduced from 14
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2), // Reduced from 4
                    Text(
                      _surveyDate != null
                          ? '${_surveyDate!.day}/${_surveyDate!.month}/${_surveyDate!.year}'
                          : 'Select date',
                      style: TextStyle(
                        fontSize: 14, // Reduced from 16
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
        initialValue: value,
        isExpanded: true,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Container(
            margin: const EdgeInsets.all(8), // Reduced from 12
            padding: const EdgeInsets.all(6), // Reduced from 8
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(10), // Reduced from 12
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 16, // Reduced from 20
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
            fontSize: 12, // Reduced from 14
            fontWeight: FontWeight.w500,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12), // Reduced
        ),
        items: items.map((item) {
          return DropdownMenuItem<T>(
            value: item,
            child: Text(
              itemLabel(item),
              style: const TextStyle(
                fontSize: 14, // Reduced from 16
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
          fontSize: 14, // Reduced from 16
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
        // Total and Received Payment in a row
        Row(
          children: [
            Expanded(
              child: _buildStunningTextField(
                controller: _totalPaymentController,
                label: 'Total',
                hint: 'Amount',
                icon: Icons.currency_rupee,
                keyboardType: TextInputType.number,
                onChanged: (_) => setState(() {}),
                validator: (value) => Validators.validateAmount(
                  value,
                  emptyMessage: 'Required',
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStunningTextField(
                controller: _receivedPaymentController,
                label: 'Received',
                hint: 'Amount',
                icon: Icons.account_balance_wallet_outlined,
                keyboardType: TextInputType.number,
                onChanged: (_) => setState(() {}),
                validator: (value) {
                  final amountError = Validators.validateAmount(value, allowZero: true);
                  if (amountError != null) return amountError;
                  
                  return Validators.validateReceivedPayment(
                    value,
                    _totalPaymentController.text,
                    exceedsMessage: 'Exceeds total',
                  );
                },
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 12), // Reduced from 24
        
        // Compact Pending Payment Display
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12), // Reduced
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
            borderRadius: BorderRadius.circular(16), // Reduced from 20
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
                padding: const EdgeInsets.all(8), // Reduced from 12
                decoration: BoxDecoration(
                  color: _pendingPayment > 0 ? AppColors.error : AppColors.success,
                  borderRadius: BorderRadius.circular(12), // Reduced from 16
                ),
                child: Icon(
                  _pendingPayment > 0 ? Icons.pending_actions : Icons.check_circle,
                  color: Colors.white,
                  size: 18, // Reduced from 24
                ),
              ),
              const SizedBox(width: 12), // Reduced from 16
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Pending:',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    Text(
                      '₹${_pendingPayment.toStringAsFixed(0)}',
                      style: TextStyle(
                        fontSize: 18, // Reduced from 24
                        fontWeight: FontWeight.w700,
                        color: _pendingPayment > 0 ? AppColors.error : AppColors.success,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), // Reduced
                decoration: BoxDecoration(
                  color: _pendingPayment > 0 ? AppColors.error : AppColors.success,
                  borderRadius: BorderRadius.circular(10), // Reduced from 12
                ),
                child: Text(
                  _pendingPayment > 0 ? 'PENDING' : 'PAID',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11, // Reduced from 12
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
        borderRadius: BorderRadius.circular(16), // Reduced from 20
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 12, // Reduced from 20
            offset: const Offset(0, 4), // Reduced from 8
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: formState.isLoading ? null : _handleSave,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(vertical: 14), // Reduced from 20
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16), // Reduced from 20
          ),
        ),
        child: formState.isLoading
            ? const SizedBox(
                height: 20, // Reduced from 24
                width: 20,
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
                    size: 20, // Reduced from 24
                  ),
                  const SizedBox(width: 8), // Reduced from 12
                  Text(
                    _isEditing ? 'Update Survey' : 'Create Survey',
                    style: const TextStyle(
                      fontSize: 16, // Reduced from 18
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

  Widget _buildExpensesSection(AppLocalizations loc) {
    final expensesAsync = ref.watch(expensesBySurveyProvider(widget.surveyId!));
    
    return _buildSectionCard(
      title: loc.surveyExpensesSection,
      icon: Icons.receipt_long_outlined,
      children: [
        expensesAsync.when(
          data: (expenses) {
            if (expenses.isEmpty) {
              return Column(
                children: [
                  // Empty state
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppColors.border.withOpacity(0.2),
                        style: BorderStyle.solid,
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.receipt_long_outlined,
                          size: 48,
                          color: AppColors.textSecondary.withOpacity(0.5),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          loc.noExpensesForSurvey,
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          loc.tapToAddExpense,
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildAddExpenseButton(loc),
                ],
              );
            }
            
            // Calculate total
            final total = expenses.fold<double>(0, (sum, e) => sum + e.amount);
            
            return Column(
              children: [
                // Expenses list
                ...expenses.map((expense) => _buildExpenseItem(expense, loc)),
                
                const SizedBox(height: 12),
                
                // Total row
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        loc.totalExpenses,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        '₹${total.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 12),
                _buildAddExpenseButton(loc),
              ],
            );
          },
          loading: () => const Center(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
          error: (error, _) => Center(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                'Error loading expenses',
                style: TextStyle(color: AppColors.error),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildExpenseItem(ExpenseModel expense, AppLocalizations loc) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.border.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          // Category icon
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _getCategoryColor(expense.category).withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              _getCategoryIcon(expense.category),
              color: _getCategoryColor(expense.category),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          // Description and date
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  expense.description,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  DateFormat('dd MMM yyyy').format(expense.date),
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          // Amount
          Text(
            '₹${expense.amount.toStringAsFixed(0)}',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddExpenseButton(AppLocalizations loc) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: _showAddExpenseDialog,
        icon: const Icon(Icons.add, size: 20),
        label: Text(loc.addExpenseToSurvey),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: BorderSide(color: AppColors.primary.withOpacity(0.5)),
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  void _showAddExpenseDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ExpenseFormDialog(surveyId: widget.surveyId),
    ).then((_) {
      // Refresh the expenses list
      ref.invalidate(expensesBySurveyProvider(widget.surveyId!));
    });
  }

  Color _getCategoryColor(ExpenseCategory category) {
    switch (category) {
      case ExpenseCategory.travel:
        return Colors.blue;
      case ExpenseCategory.equipment:
        return Colors.orange;
      case ExpenseCategory.food:
        return Colors.green;
      case ExpenseCategory.fuel:
        return Colors.red;
      case ExpenseCategory.accommodation:
        return Colors.purple;
      case ExpenseCategory.communication:
        return Colors.teal;
      case ExpenseCategory.other:
        return Colors.grey;
    }
  }

  IconData _getCategoryIcon(ExpenseCategory category) {
    switch (category) {
      case ExpenseCategory.travel:
        return Icons.directions_car;
      case ExpenseCategory.equipment:
        return Icons.build;
      case ExpenseCategory.food:
        return Icons.restaurant;
      case ExpenseCategory.fuel:
        return Icons.local_gas_station;
      case ExpenseCategory.accommodation:
        return Icons.hotel;
      case ExpenseCategory.communication:
        return Icons.phone;
      case ExpenseCategory.other:
        return Icons.more_horiz;
    }
  }
}