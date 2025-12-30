import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../providers/expense_provider.dart';
import '../../../providers/survey_provider.dart';
import '../../../data/models/expense_model.dart';
import '../../../data/models/survey_model.dart';

class ExpenseFormDialog extends ConsumerStatefulWidget {
  final ExpenseModel? expense;
  final String? surveyId; // Optional: pre-select a survey when adding expense from survey screen

  const ExpenseFormDialog({super.key, this.expense, this.surveyId});

  @override
  ConsumerState<ExpenseFormDialog> createState() => _ExpenseFormDialogState();
}

class _ExpenseFormDialogState extends ConsumerState<ExpenseFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _descriptionController;
  late TextEditingController _amountController;
  ExpenseCategory _selectedCategory = ExpenseCategory.other;
  DateTime _selectedDate = DateTime.now();
  String? _selectedSurveyId;
  bool _isSaving = false;

  bool get isEditing => widget.expense != null;

  @override
  void initState() {
    super.initState();
    _descriptionController = TextEditingController(
      text: widget.expense?.description ?? '',
    );
    _amountController = TextEditingController(
      text: widget.expense?.amount.toStringAsFixed(0) ?? '',
    );
    if (widget.expense != null) {
      _selectedCategory = widget.expense!.category;
      _selectedDate = widget.expense!.date;
      _selectedSurveyId = widget.expense!.surveyId;
    } else if (widget.surveyId != null) {
      _selectedSurveyId = widget.surveyId;
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  String _getCategoryName(ExpenseCategory category, AppLocalizations loc) {
    switch (category) {
      case ExpenseCategory.travel:
        return loc.categoryTravel;
      case ExpenseCategory.equipment:
        return loc.categoryEquipment;
      case ExpenseCategory.food:
        return loc.categoryFood;
      case ExpenseCategory.fuel:
        return loc.categoryFuel;
      case ExpenseCategory.accommodation:
        return loc.categoryAccommodation;
      case ExpenseCategory.communication:
        return loc.categoryCommunication;
      case ExpenseCategory.other:
        return loc.categoryOther;
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

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Widget _buildSurveyDropdown(AppLocalizations loc) {
    final waitingSurveysAsync = ref.watch(waitingSurveysProvider);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              loc.linkToSurvey,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '(${loc.optional})',
              style: TextStyle(
                color: AppColors.textSecondary.withOpacity(0.7),
                fontSize: 12,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        waitingSurveysAsync.when(
          data: (surveys) {
            if (surveys.isEmpty) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.border),
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.grey[50],
                ),
                child: Row(
                  children: [
                    Icon(Icons.assignment_outlined, color: AppColors.textSecondary),
                    const SizedBox(width: 12),
                    Text(
                      loc.noWaitingSurveys,
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              );
            }
            
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.border),
                borderRadius: BorderRadius.circular(12),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String?>(
                  value: _selectedSurveyId,
                  isExpanded: true,
                  hint: Row(
                    children: [
                      Icon(Icons.assignment_outlined, color: AppColors.primary),
                      const SizedBox(width: 12),
                      Text(
                        loc.selectSurvey,
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                  items: [
                    // Option to clear selection
                    DropdownMenuItem<String?>(
                      value: null,
                      child: Row(
                        children: [
                          Icon(Icons.clear, color: AppColors.textSecondary, size: 20),
                          const SizedBox(width: 12),
                          Text(
                            '— ${loc.noSelection} —',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    ),
                    ...surveys.map((survey) => DropdownMenuItem<String?>(
                      value: survey.id,
                      child: Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: _getSurveyStatusColor(survey.status),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  survey.surveyNumber,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 14,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  '${survey.applicantName} • ${survey.villageName}',
                                  style: TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 12,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    )),
                  ],
                  onChanged: (value) {
                    setState(() => _selectedSurveyId = value);
                  },
                ),
              ),
            );
          },
          loading: () => Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.border),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                const SizedBox(width: 12),
                Text(
                  loc.loading,
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          error: (_, __) => Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.error.withOpacity(0.5)),
              borderRadius: BorderRadius.circular(12),
              color: AppColors.error.withOpacity(0.05),
            ),
            child: Row(
              children: [
                Icon(Icons.error_outline, color: AppColors.error, size: 20),
                const SizedBox(width: 12),
                Text(
                  loc.error,
                  style: TextStyle(color: AppColors.error),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Color _getSurveyStatusColor(SurveyStatus status) {
    switch (status) {
      case SurveyStatus.waiting:
        return Colors.orange;
      case SurveyStatus.working:
        return Colors.blue;
      case SurveyStatus.done:
        return Colors.green;
    }
  }

  Future<void> _saveExpense() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final amount = double.tryParse(_amountController.text.trim()) ?? 0;
      
      bool success;
      if (isEditing) {
        final updatedExpense = widget.expense!.copyWith(
          description: _descriptionController.text.trim(),
          amount: amount,
          category: _selectedCategory,
          date: _selectedDate,
          surveyId: _selectedSurveyId,
        );
        success = await ref.read(expenseProvider.notifier).updateExpense(updatedExpense);
      } else {
        success = await ref.read(expenseProvider.notifier).addExpense(
          description: _descriptionController.text.trim(),
          amount: amount,
          category: _selectedCategory,
          date: _selectedDate,
          surveyId: _selectedSurveyId,
        );
      }

      if (mounted) {
        final loc = AppLocalizations.of(context);
        if (success) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(isEditing ? loc.expenseUpdated : loc.expenseAdded),
              backgroundColor: AppColors.success,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(loc.error),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final dateFormat = DateFormat('MMMM d, yyyy');

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle bar
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Title
                Text(
                  isEditing ? loc.editExpense : loc.addExpense,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                ),
                const SizedBox(height: 24),

                // Description Field
                TextFormField(
                  controller: _descriptionController,
                  decoration: InputDecoration(
                    labelText: loc.expenseDescription,
                    hintText: loc.enterExpenseDescription,
                    prefixIcon: Icon(Icons.description_outlined, color: AppColors.primary),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppColors.border),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppColors.primary, width: 2),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return loc.expenseDescriptionRequired;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Amount Field
                TextFormField(
                  controller: _amountController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                  ],
                  decoration: InputDecoration(
                    labelText: loc.expenseAmount,
                    hintText: loc.enterExpenseAmount,
                    prefixIcon: Icon(Icons.currency_rupee, color: AppColors.primary),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppColors.border),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppColors.primary, width: 2),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return loc.expenseAmountRequired;
                    }
                    final amount = double.tryParse(value.trim());
                    if (amount == null || amount <= 0) {
                      return loc.invalidExpenseAmount;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Category Selection
                Text(
                  loc.expenseCategory,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: ExpenseCategory.values.map((category) {
                    final isSelected = _selectedCategory == category;
                    final color = _getCategoryColor(category);
                    return GestureDetector(
                      onTap: () => setState(() => _selectedCategory = category),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected ? color.withOpacity(0.15) : Colors.grey[100],
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected ? color : Colors.transparent,
                            width: 1.5,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _getCategoryIcon(category),
                              size: 18,
                              color: isSelected ? color : AppColors.textSecondary,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              _getCategoryName(category, loc),
                              style: TextStyle(
                                color: isSelected ? color : AppColors.textSecondary,
                                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),

                // Date Selection
                Text(
                  loc.expenseDate,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                InkWell(
                  onTap: _selectDate,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.border),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.calendar_today, color: AppColors.primary),
                        const SizedBox(width: 12),
                        Text(
                          dateFormat.format(_selectedDate),
                          style: const TextStyle(
                            fontSize: 16,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const Spacer(),
                        Icon(Icons.arrow_drop_down, color: AppColors.textSecondary),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Survey Linking (Optional)
                _buildSurveyDropdown(loc),
                const SizedBox(height: 32),

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _isSaving ? null : () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          side: BorderSide(color: AppColors.border),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          loc.cancel,
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: _isSaving ? null : _saveExpense,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isSaving
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                loc.save,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
