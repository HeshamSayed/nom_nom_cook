class AppConstants {
  // API Configuration
  static const String baseUrl = 'http://localhost:8000';
  static const String apiVersion = 'v1';
  static const String apiBaseUrl = '$baseUrl/api/$apiVersion';

  // WebSocket
  static const String wsBaseUrl = 'ws://localhost:8000';

  // Endpoints
  static const String loginEndpoint = '/auth/login/';
  static const String registerEndpoint = '/auth/users/';
  static const String refreshTokenEndpoint = '/auth/token/refresh/';
  static const String recipesEndpoint = '/recipes/recipes/';
  static const String categoriesEndpoint = '/recipes/categories/';
  static const String ingredientsEndpoint = '/recipes/ingredients/';
  static const String subscriptionsEndpoint = '/subscriptions/subscriptions/';

  // Storage Keys
  static const String accessTokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userDataKey = 'user_data';
  static const String languageKey = 'language';

  // Hive Box Names
  static const String recipesBox = 'recipes';
  static const String savedRecipesBox = 'saved_recipes';
  static const String mealPlansBox = 'meal_plans';

  // App Settings
  static const int paginationLimit = 20;
  static const int maxImageSize = 5 * 1024 * 1024; // 5MB
  static const List<String> supportedLanguages = ['en', 'ar'];

  // Egyptian Cuisine Tags
  static const List<String> egyptianCuisines = [
    'Koshari',
    'Molokhia',
    'Ful Medames',
    'Ta\'meya',
    'Mahshi',
    'Shawarma',
    'Hawawshi',
    'Basbousa',
    'Konafa',
  ];

  // Dietary Preferences
  static const List<String> dietaryPreferences = [
    'Vegan',
    'Vegetarian',
    'Keto',
    'Gluten Free',
    'Dairy Free',
    'Halal',
  ];

  // Meal Types
  static const List<String> mealTypes = [
    'Breakfast',
    'Lunch',
    'Dinner',
    'Snack',
    'Suhoor',
    'Iftar',
  ];
}
