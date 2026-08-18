class Validators {
  Validators._();

  // RFC 5322 simplified email regex
  static final RegExp _emailRegex = RegExp(
    r'^[a-zA-Z0-9.!#$%&*+/=?^_{|}~-]+'
    r'@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?'
    r'(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$',
  );

  // E.164 phone format
  static final RegExp _phoneRegex = RegExp(r'^\+[1-9]\d{1,14}$');

  // Username: 3-20 alphanumeric + underscores
  static final RegExp _usernameRegex = RegExp(r'^[a-zA-Z0-9_]{3,20}$');

  static bool isValidEmail(String email) {
    return _emailRegex.hasMatch(email.trim());
  }

  static bool isValidPhone(String phone) {
    return _phoneRegex.hasMatch(phone.trim());
  }

  static bool isValidUsername(String username) {
    return _usernameRegex.hasMatch(username.trim());
  }

  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) return 'Email is required';
    if (!isValidEmail(value)) return 'Enter a valid email address';
    return null;
  }

  static String? validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) return 'Phone number is required';
    if (!isValidPhone(value)) return 'Enter a valid phone number (e.g. +1234567890)';
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Password is required';
    if (value.length < 8) return 'Password must be at least 8 characters';
    return null;
  }

  static String? validateDisplayName(String? value) {
    if (value == null || value.trim().isEmpty) return 'Display name is required';
    if (value.trim().length < 2) return 'Name must be at least 2 characters';
    if (value.trim().length > 50) return 'Name must be 50 characters or less';
    return null;
  }

  static String? validateUsername(String? value) {
    if (value == null || value.trim().isEmpty) return 'Username is required';
    if (!isValidUsername(value)) {
      return 'Username must be 3-20 characters (letters, numbers, underscores)';
    }
    return null;
  }

  static String? validateGroupName(String? value) {
    if (value == null || value.trim().isEmpty) return 'Group name is required';
    if (value.trim().length > 50) return 'Group name must be 50 characters or less';
    return null;
  }

  static String? validateEventTitle(String? value) {
    if (value == null || value.trim().isEmpty) return 'Event title is required';
    if (value.trim().length > 100) return 'Title must be 100 characters or less';
    return null;
  }

  static String? validateCaption(String? value) {
    if (value != null && value.length > 300) {
      return 'Caption must be 300 characters or less';
    }
    return null;
  }

  static bool isValidImageFile(String mimeType, int fileSizeBytes) {
    const allowedMimes = ['image/jpeg', 'image/png', 'image/webp'];
    const maxBytes = 10 * 1024 * 1024; // 10 MB
    return allowedMimes.contains(mimeType) && fileSizeBytes <= maxBytes;
  }

  static bool isValidAvatarFile(String mimeType, int fileSizeBytes) {
    const allowedMimes = ['image/jpeg', 'image/png', 'image/webp'];
    const maxBytes = 10 * 1024 * 1024; // 10 MB
    return allowedMimes.contains(mimeType) && fileSizeBytes <= maxBytes;
  }

  static bool isValidMemoryPhoto(String mimeType, int fileSizeBytes) {
    const allowedMimes = ['image/jpeg', 'image/png', 'image/webp'];
    const maxBytes = 20 * 1024 * 1024; // 20 MB
    return allowedMimes.contains(mimeType) && fileSizeBytes <= maxBytes;
  }

  static bool isValidMemoryVideo(String mimeType, int fileSizeBytes) {
    const allowedMimes = ['video/mp4', 'video/quicktime'];
    const maxBytes = 500 * 1024 * 1024; // 500 MB
    return allowedMimes.contains(mimeType) && fileSizeBytes <= maxBytes;
  }

  static bool isValidChatAttachment(int fileSizeBytes) {
    const maxBytes = 100 * 1024 * 1024; // 100 MB
    return fileSizeBytes <= maxBytes;
  }
}
