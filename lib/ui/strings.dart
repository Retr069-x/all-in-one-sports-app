abstract final class Copy {
  static const appName = 'SportConnect';
  static const demoData = 'Demo data';
  static const loading = 'Loading';
  static const empty = 'Nothing to show yet';
  static const error = 'Something went wrong';
  static const offline = 'You’re offline';
  static const retry = 'Try again';
  static const searchSports = 'Search sports';
  static const clearSearch = 'Clear search';
  static const beginner = 'Beginner';
  static const notProvided = 'Not provided';
  static const source = 'Source';
  static const coach = 'Coach';
  static const venue = 'Venue';
  static const learn = 'Learn';
  static const ask = 'Ask AI';
  static const play = 'Play';
  static const profile = 'Profile';
  static const learnTitle = 'Learn a sport';
  static const learnIntro =
      'Start with the basics, then take your first practice into play.';
  static const featured = 'FEATURED COURSE';
  static const continueLearning = 'Continue learning';
  static const continueCourse = 'Continue course';
  static const startCourse = 'Start course';
  static const browseCourses = 'Browse courses';
  static const searchEmpty = 'Try a sport name or a different spelling.';
  static const selectCountry = 'Choose a country and city';
  static const regionHelp = 'Choose from the available demo cities.';
  static const saveError = 'Could not save your changes. Try again.';
  static const questionEquipment = 'What equipment do I need?';
  static const questionScoring = 'How do I score?';
  static const questionPractice = 'What should I practise first?';
  static const suggested = [
    questionEquipment,
    questionScoring,
    questionPractice,
  ];
  static const askIntro = 'Ask a question about the sport you’re learning.';
  static const rankingSource = 'SportConnect sample ranking';
  static const progress = 'Learning progress';
  static const progressLocal = 'Saved on this device';
  static const progressEmpty =
      'Complete a lesson to start tracking your progress.';
  static const demoDirectory =
      'Sample listings and distances for the selected city.';
  static const offlineAi =
      'The lesson assistant is available in demo mode in the next phase.';

  static String trending(String country) => 'Trending in $country';
  static String lessons(String count) => '$count lessons';
  static String courseInfo(String count) => '$beginner · ${lessons(count)}';
  static String completed(String done, String total) =>
      '$done of $total lessons complete';
  static String place(String city, String country) => '$city, $country';
  static String rank(String count) => '#$count';
}
