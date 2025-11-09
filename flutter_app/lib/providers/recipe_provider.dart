import 'package:flutter/foundation.dart';
import '../models/recipe_model.dart';
import '../services/api_service.dart';
import '../core/app_constants.dart';

class RecipeProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<RecipeModel> _recipes = [];
  List<CategoryModel> _categories = [];
  RecipeModel? _selectedRecipe;
  bool _isLoading = false;
  String? _error;

  List<RecipeModel> get recipes => _recipes;
  List<CategoryModel> get categories => _categories;
  RecipeModel? get selectedRecipe => _selectedRecipe;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchRecipes({Map<String, String>? filters}) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      String endpoint = AppConstants.recipesEndpoint;
      if (filters != null && filters.isNotEmpty) {
        final queryString = filters.entries
            .map((e) => '${e.key}=${Uri.encodeComponent(e.value)}')
            .join('&');
        endpoint += '?$queryString';
      }

      final response = await _apiService.get(endpoint, requiresAuth: false);

      _recipes = (response['results'] as List)
          .map((json) => RecipeModel.fromJson(json))
          .toList();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchCategories() async {
    try {
      final response = await _apiService.get(
        AppConstants.categoriesEndpoint,
        requiresAuth: false,
      );

      _categories = (response as List)
          .map((json) => CategoryModel.fromJson(json))
          .toList();

      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> fetchRecipeDetails(int recipeId) async {
    try {
      _isLoading = true;
      notifyListeners();

      final response = await _apiService.get(
        '${AppConstants.recipesEndpoint}$recipeId/',
        requiresAuth: false,
      );

      _selectedRecipe = RecipeModel.fromJson(response);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> likeRecipe(int recipeId) async {
    try {
      await _apiService.post('${AppConstants.recipesEndpoint}$recipeId/like/', {});

      // Update local state
      if (_selectedRecipe?.id == recipeId) {
        // Update selected recipe
        notifyListeners();
      }

      final index = _recipes.indexWhere((r) => r.id == recipeId);
      if (index != -1) {
        // Update in list
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> saveRecipe(int recipeId, {int? folderId}) async {
    try {
      await _apiService.post(
        '${AppConstants.recipesEndpoint}$recipeId/save/',
        {'folder_id': folderId},
      );

      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> rateRecipe(int recipeId, int rating, String review) async {
    try {
      await _apiService.post(
        '${AppConstants.recipesEndpoint}$recipeId/rate/',
        {
          'rating': rating,
          'review': review,
        },
      );

      // Refresh recipe details
      await fetchRecipeDetails(recipeId);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> searchRecipes(String query) async {
    await fetchRecipes(filters: {'search': query});
  }

  Future<void> filterRecipes({
    int? categoryId,
    String? difficulty,
    bool? isVegan,
    bool? isVegetarian,
    bool? isGlutenFree,
    int? maxPrepTime,
  }) async {
    final filters = <String, String>{};

    if (categoryId != null) filters['category'] = categoryId.toString();
    if (difficulty != null) filters['difficulty'] = difficulty;
    if (isVegan != null) filters['is_vegan'] = isVegan.toString();
    if (isVegetarian != null) filters['is_vegetarian'] = isVegetarian.toString();
    if (isGlutenFree != null) filters['is_gluten_free'] = isGlutenFree.toString();
    if (maxPrepTime != null) filters['prep_time_max'] = maxPrepTime.toString();

    await fetchRecipes(filters: filters);
  }
}
