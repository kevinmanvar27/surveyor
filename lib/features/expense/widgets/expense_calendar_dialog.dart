import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../data/models/expense_model.dart';

/// Result of calendar selection
class CalendarSelectionResult {
  final ExpenseTimePeriod period;
  final DateTime selectedDate;

  CalendarSelectionResult({
    required this.period,
    required this.selectedDate,
  });
}

/// Custom calendar dialog for expense filtering
/// Supports granular selection: year, month, or specific date
class ExpenseCalendarDialog extends StatefulWidget {
  final DateTime initialDate;
  final ExpenseTimePeriod initialPeriod;

  const ExpenseCalendarDialog({
    super.key,
    required this.initialDate,
    required this.initialPeriod,
  });

  @override
  State<ExpenseCalendarDialog> createState() => _ExpenseCalendarDialogState();
}

class _ExpenseCalendarDialogState extends State<ExpenseCalendarDialog> {
  late int _selectedYear;
  late int _selectedMonth;
  int? _selectedDay;
  
  // View modes
  bool _showYearPicker = false;
  
  @override
  void initState() {
    super.initState();
    _selectedYear = widget.initialDate.year;
    _selectedMonth = widget.initialDate.month;
    
    // If initial period is day, pre-select the day
    if (widget.initialPeriod == ExpenseTimePeriod.day) {
      _selectedDay = widget.initialDate.day;
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        constraints: const BoxConstraints(maxWidth: 400),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header with year/month selector
            _buildHeader(loc),
            
            // Calendar body
            if (_showYearPicker)
              _buildYearPicker()
            else
              _buildCalendarGrid(loc),
            
            // Footer with selection info
            _buildFooter(loc),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(AppLocalizations loc) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          // Year selector
          GestureDetector(
            onTap: () {
              setState(() {
                _showYearPicker = !_showYearPicker;
              });
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '$_selectedYear',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  _showYearPicker ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                  color: Colors.white,
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          
          // Month navigation
          if (!_showYearPicker)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: _previousMonth,
                  icon: const Icon(Icons.chevron_left, color: Colors.white),
                ),
                GestureDetector(
                  onTap: _selectCurrentMonth,
                  child: Text(
                    _getMonthName(_selectedMonth),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: _canGoNextMonth() ? _nextMonth : null,
                  icon: Icon(
                    Icons.chevron_right,
                    color: _canGoNextMonth() ? Colors.white : Colors.white38,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildYearPicker() {
    final currentYear = DateTime.now().year;
    final years = List.generate(currentYear - 2019, (i) => currentYear - i);
    
    return Container(
      height: 300,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        itemCount: years.length,
        itemBuilder: (context, index) {
          final year = years[index];
          final isSelected = year == _selectedYear;
          
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primary.withOpacity(0.1) : null,
              borderRadius: BorderRadius.circular(12),
              border: isSelected 
                  ? Border.all(color: AppColors.primary, width: 2)
                  : null,
            ),
            child: ListTile(
              title: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '$year',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: isSelected ? AppColors.primary : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'Select Year',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              onTap: () {
                // Apply year filter directly
                _selectYear(year);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildCalendarGrid(AppLocalizations loc) {
    final daysInMonth = DateTime(_selectedYear, _selectedMonth + 1, 0).day;
    final firstDayOfMonth = DateTime(_selectedYear, _selectedMonth, 1);
    final firstWeekday = firstDayOfMonth.weekday; // 1 = Monday, 7 = Sunday
    
    // Adjust for Sunday start (convert Monday=1 to Sunday=0 format)
    final startOffset = firstWeekday % 7;
    
    // Calculate number of weeks
    final totalDays = startOffset + daysInMonth;
    final numberOfWeeks = (totalDays / 7).ceil();
    
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Week day headers - tappable for week selection
          _buildWeekDayHeaders(),
          const SizedBox(height: 8),
          
          // Calendar days
          ...List.generate(numberOfWeeks, (weekIndex) {
            return _buildWeekRow(weekIndex, startOffset, daysInMonth);
          }),
        ],
      ),
    );
  }

  Widget _buildWeekDayHeaders() {
    const weekDays = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
    
    return Row(
      children: weekDays.asMap().entries.map((entry) {
        return Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              entry.value,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: entry.key == 0 ? Colors.red.shade400 : AppColors.textSecondary,
                fontSize: 14,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildWeekRow(int weekIndex, int startOffset, int daysInMonth) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: List.generate(7, (dayOfWeek) {
          final dayNumber = weekIndex * 7 + dayOfWeek - startOffset + 1;
          
          if (dayNumber < 1 || dayNumber > daysInMonth) {
            return Expanded(child: Container(height: 44));
          }
          
          return Expanded(
            child: _buildDayCell(dayNumber),
          );
        }),
      ),
    );
  }

  Widget _buildDayCell(int day) {
    final isSelected = _selectedDay == day;
    final isToday = _isToday(day);
    final isFuture = _isFutureDate(day);
    
    return GestureDetector(
      onTap: isFuture ? null : () => _selectDay(day),
      child: Container(
        height: 44,
        margin: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: isSelected 
              ? AppColors.primary 
              : isToday 
                  ? AppColors.primary.withOpacity(0.15)
                  : null,
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Text(
            '$day',
            style: TextStyle(
              fontWeight: isSelected || isToday ? FontWeight.w600 : FontWeight.w500,
              color: isSelected 
                  ? Colors.white 
                  : isFuture 
                      ? AppColors.textSecondary.withOpacity(0.4)
                      : AppColors.textPrimary,
              fontSize: 15,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFooter(AppLocalizations loc) {
    String selectionText;
    
    if (_selectedDay != null) {
      selectionText = '${_getMonthName(_selectedMonth)} $_selectedDay, $_selectedYear';
    } else {
      selectionText = '${_getMonthName(_selectedMonth)} $_selectedYear';
    }
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          // Selection indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              selectionText,
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          // Action buttons
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    loc.cancel,
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: _applySelection,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: Text(loc.apply),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Helper methods
  String _getMonthName(int month) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return months[month - 1];
  }

  bool _isToday(int day) {
    final now = DateTime.now();
    return now.year == _selectedYear && 
           now.month == _selectedMonth && 
           now.day == day;
  }

  bool _isFutureDate(int day) {
    final date = DateTime(_selectedYear, _selectedMonth, day);
    final today = DateTime.now();
    return date.isAfter(DateTime(today.year, today.month, today.day));
  }

  bool _canGoNextMonth() {
    final now = DateTime.now();
    if (_selectedYear < now.year) return true;
    if (_selectedYear == now.year && _selectedMonth < now.month) return true;
    return false;
  }

  void _previousMonth() {
    setState(() {
      if (_selectedMonth == 1) {
        _selectedMonth = 12;
        _selectedYear--;
      } else {
        _selectedMonth--;
      }
      _selectedDay = null;
    });
  }

  void _nextMonth() {
    if (!_canGoNextMonth()) return;
    
    setState(() {
      if (_selectedMonth == 12) {
        _selectedMonth = 1;
        _selectedYear++;
      } else {
        _selectedMonth++;
      }
      _selectedDay = null;
    });
  }

  void _selectCurrentMonth() {
    // Tapping on month name = auto-apply month filter
    final result = CalendarSelectionResult(
      period: ExpenseTimePeriod.month,
      selectedDate: DateTime(_selectedYear, _selectedMonth, 1),
    );
    Navigator.pop(context, result);
  }

  void _selectYear(int year) {
    final result = CalendarSelectionResult(
      period: ExpenseTimePeriod.year,
      selectedDate: DateTime(year, 1, 1),
    );
    Navigator.pop(context, result);
  }

  void _selectDay(int day) {
    setState(() {
      _selectedDay = day;
    });
  }

  void _applySelection() {
    CalendarSelectionResult result;
    
    if (_selectedDay != null) {
      // Specific day selected
      result = CalendarSelectionResult(
        period: ExpenseTimePeriod.day,
        selectedDate: DateTime(_selectedYear, _selectedMonth, _selectedDay!),
      );
    } else {
      // Month selected (default)
      result = CalendarSelectionResult(
        period: ExpenseTimePeriod.month,
        selectedDate: DateTime(_selectedYear, _selectedMonth, 1),
      );
    }
    
    Navigator.pop(context, result);
  }
}
