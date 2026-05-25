class AppConstants {
  AppConstants._();

  // API
  // static const String baseUrl = 'http://10.0.2.2:3000/api/v1'; // for emulator
  // static const String baseUrl = 'http://192.168.x.x:3000/api/v1'; // for phone
  static const String baseUrl = 'http://localhost:3000/api/v1'; //for web

  // Storage Keys
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';
  static const String roleKey = 'user_role';

  // Roles
  static const String roleStudent = 'student';
  static const String roleTeacher = 'teacher';
  static const String roleAdmin = 'admin';

  // App Info
  static const String appName = 'ClassLink';
  static const String university = 'Adama Science and Technology University';
  static const String emailDomain = '@astu.edu.et';

  // Timeouts
  static const int connectTimeout = 30000;
  static const int receiveTimeout = 30000;
}