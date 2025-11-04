class ApiEndpoints {
  static const String baseUrl = 'https://api.yourapp.com/v1';

  // AUTH
  static const String login = '$baseUrl/auth/login';
  static const String register = '$baseUrl/auth/register';

  // CLASS
  static const String classes = '$baseUrl/classes';
  static const String joinClass = '$baseUrl/classes/join';

  // QUIZ
  static const String quizzes = '$baseUrl/quizzes';
  static const String createQuiz = '$baseUrl/quizzes/create';
  static const String submitAnswer = '$baseUrl/quizzes/submit';

  // TUGAS
  static const String tugas = '$baseUrl/tugas';
  static const String submitTugas = '$baseUrl/tugas/submit';
}
