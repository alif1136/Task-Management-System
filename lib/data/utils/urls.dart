// lib/data/utils/urls.dart

class Urls {
  // Base URL from your Postman API
  static const String baseUrl = 'http://35.73.30.144:2005/api/v1';

  // ---------- Auth ----------
  static const String registrationUrl = '$baseUrl/Registration';
  static const String loginUrl        = '$baseUrl/Login';

  // Profile
  static const String updateProfileUrl  = '$baseUrl/ProfileUpdate';
  static const String profileDetailsUrl = '$baseUrl/profileDetails';

  // ---------- Password recovery (OTP) ----------
  // Send OTP to email
  static const String recoverVerifyEmailUrl = '$baseUrl/RecoverVerifyEmail'; // + /{email}

  // Some servers use RecoverVerifyOtp, some RecoverVerifyOTP
  static const String recoverVerifyOtpUrlPrimary = '$baseUrl/RecoverVerifyOtp'; // + /{email}/{otp}
  static const String recoverVerifyOtpUrlAlt     = '$baseUrl/RecoverVerifyOTP'; // + /{email}/{otp}

  // Reset password with email + OTP + new password
  static const String recoverResetPasswordUrl = '$baseUrl/RecoverResetPassword';

  // ---------- Tasks ----------
  // Create task
  static const String createNewTaskUrl = '$baseUrl/createTask';

  // List tasks by status (as used in your task list screens)
  static String get newTasksUrl       => '$baseUrl/listTaskByStatus/New';
  static String get progressTasksUrl  => '$baseUrl/listTaskByStatus/InProgress';
  static String get completedTasksUrl => '$baseUrl/listTaskByStatus/Completed';
  static String get cancelledTasksUrl => '$baseUrl/listTaskByStatus/Canceled';

  // Task count by status
  static const String taskCountUrl = '$baseUrl/taskStatusCount';

  // Change task status
  static String changeTaskStatusUrl(String id, String status) =>
      '$baseUrl/updateTaskStatus/$id/$status';

  // Delete task
  static String deleteTaskUrl(String id) => '$baseUrl/deleteTask/$id';
}
