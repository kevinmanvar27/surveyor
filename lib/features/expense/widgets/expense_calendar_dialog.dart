import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../data/models/expense_model.dart';

/// Result of calendar selection
class CalendarSelectionResult {
  final ExpenseTimePeriod period;
  final DateTime selectedDate;
  final int? selectedWeekOfMonth; // 0-based week index within the month

  CalendarSelectionResult({
    required this.period,
    required this.selectedDate,
    this.selectedWeekOfMonth,
  });
}

/// Custom calendar dialog for expense filtering
/// Supports granular selection: year, month, week, or specific date
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
  int? _selectedWeekIndex; // Week row index (0-based)
  
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
                  if (isSelected) ...[
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'View Year',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              onTap: () {
                if (isSelected) {
                  // Already selected - apply year filter
                  _selectYear(year);
                } else {
                  // Select this year to view months
                  setState(() {
                    _selectedYear = year;
                    _showYearPicker = false;
                    _selectedDay = null;
                    _selectedWeekIndex = null;
                  });
                }
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
      children: [
        // Week indicator column header
        const SizedBox(
          width: 28,
          child: Icon(
            Icons.date_range,
            size: 14,
            color: AppColors.textSecondary,
          ),
        ),
        // Day headers
        ...weekDays.asMap().entries.map((entry) {
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
        }),
      ],
    );
  }

  Widget _buildWeekRow(int weekIndex, int startOffset, int daysInMonth) {
    final isWeekSelected = _selectedWeekIndex == weekIndex && _selectedDay == null;
    
    // Check if this week has any valid days
    bool hasValidDays = false;
    for (int dayOfWeek = 0; dayOfWeek < 7; dayOfWeek++) {
      final dayNumber = weekIndex * 7 + dayOfWeek - startOffset + 1;
      if (dayNumber >= 1 && dayNumber <= daysInMonth) {
        hasValidDays = true;
        break;
      }
    }
    
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 2),
      decoration: BoxDecoration(
        color: isWeekSelected ? AppColors.primary.withOpacity(0.1) : null,
        borderRadius: BorderRadius.circular(8),
        border: isWeekSelected 
            ? Border.all(color: AppColors.primary, width: 2)
            : null,
      ),
      child: Row(
        children: [
          // Week selector button
          GestureDetector(
            onTap: hasValidDays ? () => _selectWeek(weekIndex) : null,
            child: Container(
              width: 28,
              height: 44,
              alignment: Alignment.center,
              child: Icon(
                isWeekSelected ? Icons.check_circle : Icons.radio_button_unchecked,
                size: 18,
                color: isWeekSelected 
                    ? AppColors.primary 
                    : hasValidDays 
                        ? AppColors.textSecondary.withOpacity(0.5)
                        : Colors.transparent,
              ),
            ),
          ),
          // Day cells
          ...List.generate(7, (dayOfWeek) {
            final dayNumber = weekIndex * 7 + dayOfWeek - startOffset + 1;
            
            if (dayNumber < 1 || dayNumber > daysInMonth) {
              return Expanded(child: Container(height: 44));
            }
            
            return Expanded(
              child: _buildDayCell(dayNumber, weekIndex),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildDayCell(int day, int weekIndex) {
    final isSelected = _selectedDay == day;
    final isToday = _isToday(day);
    final isFuture = _isFutureDate(day);
    final isWeekSelected = _selectedWeekIndex == weekIndex && _selectedDay == null;
    
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
                      : isWeekSelected
                          ? AppColors.primary
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
    } else if (_selectedWeekIndex != null) {
      final weekDates = _getWeekDateRange(_selectedWeekIndex!);
      selectionText = 'Week: ${weekDates.start.day} - ${weekDates.end.day} ${_getMonthName(_selectedMonth)}';
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
      _selectedWeekIndex = null;
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
      _selectedWeekIndex = null;
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

  void _selectWeek(int weekIndex) {
    setState(() {
      _selectedWeekIndex = weekIndex;
      _selectedDay = null;
    });
  }

  void _selectDay(int day) {
    setState(() {
      _selectedDay = day;
      _selectedWeekIndex = null;
    });
  }

  DateRange _getWeekDateRange(int weekIndex) {
    final firstDayOfMonth = DateTime(_selectedYear, _selectedMonth, 1);
    final startOffset = firstDayOfMonth.weekday % 7;
    
    // Calculate the first day of this week row
    int firstDayOfWeek = weekIndex * 7 - startOffset + 1;
    if (firstDayOfWeek < 1) firstDayOfWeek = 1;
    
    // Calculate the last day of this week row
    int lastDayOfWeek = firstDayOfWeek + 6;
    final daysInMonth = DateTime(_selectedYear, _selectedMonth + 1, 0).day;
    if (lastDayOfWeek > daysInMonth) lastDayOfWeek = daysInMonth;
    
    // Adjust first day if it's from previous month
    final adjustedFirstDay = (weekIndex * 7 - startOffset + 1).clamp(1, daysInMonth);
    
    return DateRange(
      start: DateTime(_selectedYear, _selectedMonth, adjustedFirstDay),
      end: DateTime(_selectedYear, _selectedMonth, lastDayOfWeek),
    );
  }

  void _applySelection() {
    CalendarSelectionResult result;
    
    if (_selectedDay != null) {
      // Specific day selected
      result = CalendarSelectionResult(
        period: ExpenseTimePeriod.day,
        selectedDate: DateTime(_selectedYear, _selectedMonth, _selectedDay!),
      );
    } else if (_selectedWeekIndex != null) {
      // Week selected
      final weekRange = _getWeekDateRange(_selectedWeekIndex!);
      result = CalendarSelectionResult(
        period: ExpenseTimePeriod.week,
        selectedDate: weekRange.start,
        selectedWeekOfMonth: _selectedWeekIndex,
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

/// Simple date range helper
class DateRange {
  final DateTime start;
  final DateTime end;

  DateRange({required this.start, required this.end});
}
