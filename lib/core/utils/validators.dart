class Validators {
  Validators._();
  
  static final RegExp _emailRegex = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );
  
  static final RegExp _phoneRegex = RegExp(r'^[6-9]\d{9}$');
  
  static final RegExp _otpRegex = RegExp(r'^\d{6}$');
  
  /// Validate email address
  static String? validateEmail(String? value, {String? emptyMessage, String? invalidMessage}) {
    if (value == null || value.trim().isEmpty) {
      return emptyMessage ?? 'Email is required';
    }
    if (!_emailRegex.hasMatch(value.trim())) {
      return invalidMessage ?? 'Please enter a valid email address';
    }
    return null;
  }
  
  /// Validate phone number (Indian format - 10 digits starting with 6-9)
  static String? validatePhone(String? value, {String? emptyMessage, String? invalidMessage}) {
    if (value == null || value.trim().isEmpty) {
      return emptyMessage ?? 'Phone number is required';
    }
    final cleanPhone = value.replaceAll(RegExp(r'\D'), '');
    if (!_phoneRegex.hasMatch(cleanPhone)) {
      return invalidMessage ?? 'Please enter a valid 10-digit phone number';
    }
    return null;
  }
  
  /// Validate OTP (6 digits)
  static String? validateOtp(String? value, {String? emptyMessage, String? invalidMessage}) {
    if (value == null || value.trim().isEmpty) {
      return emptyMessage ?? 'OTP is required';
    }
    if (!_otpRegex.hasMatch(value.trim())) {
      return invalidMessage ?? 'Please enter a valid 6-digit OTP';
    }
    return null;
  }
  
  /// Validate password
  static String? validatePassword(String? value, {
    String? emptyMessage,
    String? shortMessage,
    int minLength = 6,
  }) {
    if (value == null || value.isEmpty) {
      return emptyMessage ?? 'Password is required';
    }
    if (value.length < minLength) {
      return shortMessage ?? 'Password must be at least $minLength characters';
    }
    return null;
  }
  
  /// Validate confirm password
  static String? validateConfirmPassword(String? value, String? password, {
    String? emptyMessage,
    String? mismatchMessage,
  }) {
    if (value == null || value.isEmpty) {
      return emptyMessage ?? 'Please confirm your password';
    }
    if (value != password) {
      return mismatchMessage ?? 'Passwords do not match';
    }
    return null;
  }
  
  /// Validate required field
  static String? validateRequired(String? value, {String? message}) {
    if (value == null || value.trim().isEmpty) {
      return message ?? 'This field is required';
    }
    return null;
  }
  
  /// Validate amount (positive number)
  static String? validateAmount(String? value, {
    String? emptyMessage,
    String? invalidMessage,
    String? negativeMessage,
    bool allowZero = true,
  }) {
    if (value == null || value.trim().isEmpty) {
      return emptyMessage ?? 'Amount is required';
    }
    
    final amount = double.tryParse(value.trim());
    if (amount == null) {
      return invalidMessage ?? 'Please enter a valid amount';
    }
    
    if (amount < 0) {
      return negativeMessage ?? 'Amount cannot be negative';
    }
    
    if (!allowZero && amount == 0) {
      return 'Amount must be greater than zero';
    }
    
    return null;
  }
  
  /// Validate that received payment doesn't exceed total payment
  static String? validateReceivedPayment(String? received, String? total, {
    String? exceedsMessage,
  }) {
    if (received == null || total == null) return null;
    
    final receivedAmount = double.tryParse(received.trim()) ?? 0;
    final totalAmount = double.tryParse(total.trim()) ?? 0;
    
    if (receivedAmount > totalAmount) {
      return exceedsMessage ?? 'Received payment cannot exceed total payment';
    }
    
    return null;
  }
  
  /// Validate survey number format
  static String? validateSurveyNumber(String? value, {String? emptyMessage, String? invalidMessage}) {
    if (value == null || value.trim().isEmpty) {
      return emptyMessage ?? 'Survey number is required';
    }
    // Survey number is valid if not empty (already checked above)
    return null;
  }
  
  /// Validate village name
  static String? validateVillageName(String? value, {String? emptyMessage, String? invalidMessage}) {
    if (value == null || value.trim().isEmpty) {
      return emptyMessage ?? 'Village name is required';
    }
    if (value.trim().length < 2) {
      return invalidMessage ?? 'Village name must be at least 2 characters';
    }
    return null;
  }
  
  /// Validate applicant name
  static String? validateApplicantName(String? value, {String? emptyMessage, String? invalidMessage}) {
    if (value == null || value.trim().isEmpty) {
      return emptyMessage ?? 'Applicant name is required';
    }
    if (value.trim().length < 2) {
      return invalidMessage ?? 'Name must be at least 2 characters';
    }
    return null;
  }
  
  /// Format phone number for display
  static String formatPhoneNumber(String phone) {
    final cleanPhone = phone.replaceAll(RegExp(r'\D'), '');
    if (cleanPhone.length == 10) {
      return '${cleanPhone.substring(0, 5)} ${cleanPhone.substring(5)}';
    }
    return phone;
  }
  
  /// Format phone number with country code
  static String formatPhoneWithCountryCode(String phone, {String countryCode = '+91'}) {
    final cleanPhone = phone.replaceAll(RegExp(r'\D'), '');
    if (cleanPhone.length == 10) {
      return '$countryCode$cleanPhone';
    }
    if (cleanPhone.length == 12 && cleanPhone.startsWith('91')) {
      return '+$cleanPhone';
    }
    return phone;
  }
  
  /// Clean phone number (remove non-digits)
  static String cleanPhoneNumber(String phone) {
    return phone.replaceAll(RegExp(r'\D'), '');
  }
  
  /// Format currency amount
  static String formatCurrency(double amount, {String symbol = '₹'}) {
    return '$symbol${amount.toStringAsFixed(2)}';
  }
  
  /// Parse amount string to double
  static double parseAmount(String? value) {
    if (value == null || value.trim().isEmpty) return 0;
    return double.tryParse(value.trim()) ?? 0;
  }
}
