class Validators {
  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  static String? validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Phone number is required';
    }
    
    final phoneRegex = RegExp(r'^\+?[1-9]\d{9,14}$');
    if (!phoneRegex.hasMatch(value.replaceAll(RegExp(r'\s+'), ''))) {
      return 'Please enter a valid phone number';
    }
    
    return null;
  }

  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null;
    }
    
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email address';
    }
    
    return null;
  }

  static String? validateOTP(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'OTP is required';
    }
    
    if (value.length != 6) {
      return 'OTP must be 6 digits';
    }
    
    if (!RegExp(r'^\d{6}$').hasMatch(value)) {
      return 'OTP must contain only numbers';
    }
    
    return null;
  }

  static String? validatePrice(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Price is required';
    }
    
    final price = double.tryParse(value);
    if (price == null) {
      return 'Please enter a valid price';
    }
    
    if (price <= 0) {
      return 'Price must be greater than 0';
    }
    
    return null;
  }

  static String? validateQuantity(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Quantity is required';
    }
    
    final quantity = double.tryParse(value);
    if (quantity == null) {
      return 'Please enter a valid quantity';
    }
    
    if (quantity <= 0) {
      return 'Quantity must be greater than 0';
    }
    
    return null;
  }

  static String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Name is required';
    }
    
    if (value.length < 2) {
      return 'Name must be at least 2 characters';
    }
    
    if (value.length > 100) {
      return 'Name must not exceed 100 characters';
    }
    
    return null;
  }

  static String? validateProductName(String? value) {
    final nameError = validateName(value);
    if (nameError != null) return nameError;
    
    if (!RegExp(r'^[a-zA-Z0-9\s\-_]+$').hasMatch(value!)) {
      return 'Product name can only contain letters, numbers, spaces, hyphens and underscores';
    }
    
    return null;
  }

  static String? validateMinLength(String? value, int minLength, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    
    if (value.length < minLength) {
      return '$fieldName must be at least $minLength characters';
    }
    
    return null;
  }

  static String? validateMaxLength(String? value, int maxLength, String fieldName) {
    if (value != null && value.length > maxLength) {
      return '$fieldName must not exceed $maxLength characters';
    }
    
    return null;
  }

  static String? validateDate(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Date is required';
    }
    
    try {
      DateTime.parse(value);
      return null;
    } catch (e) {
      return 'Please enter a valid date';
    }
  }

  static String? validateDateRange(String? startDate, String? endDate) {
    if (startDate == null || endDate == null) {
      return 'Both start and end dates are required';
    }
    
    try {
      final start = DateTime.parse(startDate);
      final end = DateTime.parse(endDate);
      
      if (end.isBefore(start)) {
        return 'End date must be after start date';
      }
      
      return null;
    } catch (e) {
      return 'Please enter valid dates';
    }
  }
}
