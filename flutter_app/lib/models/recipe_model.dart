import 'user_model.dart';

class RecipeModel {
  final int id;
  final String title;
  final String? titleAr;
  final String description;
  final String? descriptionAr;
  final UserModel author;
  final CategoryModel? category;
  final List<String> tags;
  final int prepTime;
  final int cookTime;
  final int servings;
  final String difficulty;
  final bool isVegan;
  final bool isVegetarian;
  final bool isGlutenFree;
  final bool isDairyFree;
  final bool isKeto;
  final bool isHalal;
  final int? calories;
  final String mainImage;
  final List<RecipeIngredient> ingredients;
  final List<RecipeStep> steps;
  final List<RecipeImage> images;
  final int viewsCount;
  final int likesCount;
  final int savesCount;
  final int cooksnapsCount;
  final double ratingAverage;
  final int ratingCount;
  final bool isFeatured;
  final bool isPremiumOnly;
  final bool isLiked;
  final bool isSaved;
  final DateTime createdAt;

  RecipeModel({
    required this.id,
    required this.title,
    this.titleAr,
    required this.description,
    this.descriptionAr,
    required this.author,
    this.category,
    required this.tags,
    required this.prepTime,
    required this.cookTime,
    required this.servings,
    required this.difficulty,
    required this.isVegan,
    required this.isVegetarian,
    required this.isGlutenFree,
    required this.isDairyFree,
    required this.isKeto,
    required this.isHalal,
    this.calories,
    required this.mainImage,
    this.ingredients = const [],
    this.steps = const [],
    this.images = const [],
    required this.viewsCount,
    required this.likesCount,
    required this.savesCount,
    required this.cooksnapsCount,
    required this.ratingAverage,
    required this.ratingCount,
    required this.isFeatured,
    this.isPremiumOnly = false,
    this.isLiked = false,
    this.isSaved = false,
    required this.createdAt,
  });

  factory RecipeModel.fromJson(Map<String, dynamic> json) {
    return RecipeModel(
      id: json['id'],
      title: json['title'],
      titleAr: json['title_ar'],
      description: json['description'],
      descriptionAr: json['description_ar'],
      author: UserModel.fromJson(json['author']),
      category: json['category'] != null
          ? CategoryModel.fromJson(json['category'])
          : null,
      tags: List<String>.from(json['tags'] ?? []),
      prepTime: json['prep_time'],
      cookTime: json['cook_time'],
      servings: json['servings'],
      difficulty: json['difficulty'],
      isVegan: json['is_vegan'] ?? false,
      isVegetarian: json['is_vegetarian'] ?? false,
      isGlutenFree: json['is_gluten_free'] ?? false,
      isDairyFree: json['is_dairy_free'] ?? false,
      isKeto: json['is_keto'] ?? false,
      isHalal: json['is_halal'] ?? true,
      calories: json['calories'],
      mainImage: json['main_image'],
      ingredients: json['recipe_ingredients'] != null
          ? (json['recipe_ingredients'] as List)
              .map((i) => RecipeIngredient.fromJson(i))
              .toList()
          : [],
      steps: json['steps'] != null
          ? (json['steps'] as List).map((s) => RecipeStep.fromJson(s)).toList()
          : [],
      images: json['images'] != null
          ? (json['images'] as List).map((i) => RecipeImage.fromJson(i)).toList()
          : [],
      viewsCount: json['views_count'] ?? 0,
      likesCount: json['likes_count'] ?? 0,
      savesCount: json['saves_count'] ?? 0,
      cooksnapsCount: json['cooksnaps_count'] ?? 0,
      ratingAverage: (json['rating_average'] ?? 0.0).toDouble(),
      ratingCount: json['rating_count'] ?? 0,
      isFeatured: json['is_featured'] ?? false,
      isPremiumOnly: json['is_premium_only'] ?? false,
      isLiked: json['is_liked'] ?? false,
      isSaved: json['is_saved'] ?? false,
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  int get totalTime => prepTime + cookTime;
}

class CategoryModel {
  final int id;
  final String name;
  final String nameAr;
  final String slug;
  final String? description;
  final String? icon;

  CategoryModel({
    required this.id,
    required this.name,
    required this.nameAr,
    required this.slug,
    this.description,
    this.icon,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'],
      name: json['name'],
      nameAr: json['name_ar'],
      slug: json['slug'],
      description: json['description'],
      icon: json['icon'],
    );
  }
}

class IngredientModel {
  final int id;
  final String name;
  final String nameAr;
  final bool isCommon;

  IngredientModel({
    required this.id,
    required this.name,
    required this.nameAr,
    required this.isCommon,
  });

  factory IngredientModel.fromJson(Map<String, dynamic> json) {
    return IngredientModel(
      id: json['id'],
      name: json['name'],
      nameAr: json['name_ar'],
      isCommon: json['is_common'] ?? false,
    );
  }
}

class RecipeIngredient {
  final int id;
  final IngredientModel ingredient;
  final String quantity;
  final String unit;
  final String? notes;

  RecipeIngredient({
    required this.id,
    required this.ingredient,
    required this.quantity,
    required this.unit,
    this.notes,
  });

  factory RecipeIngredient.fromJson(Map<String, dynamic> json) {
    return RecipeIngredient(
      id: json['id'],
      ingredient: IngredientModel.fromJson(json['ingredient']),
      quantity: json['quantity'],
      unit: json['unit'] ?? '',
      notes: json['notes'],
    );
  }
}

class RecipeStep {
  final int id;
  final int stepNumber;
  final String instruction;
  final String? instructionAr;
  final String? image;
  final int? duration;

  RecipeStep({
    required this.id,
    required this.stepNumber,
    required this.instruction,
    this.instructionAr,
    this.image,
    this.duration,
  });

  factory RecipeStep.fromJson(Map<String, dynamic> json) {
    return RecipeStep(
      id: json['id'],
      stepNumber: json['step_number'],
      instruction: json['instruction'],
      instructionAr: json['instruction_ar'],
      image: json['image'],
      duration: json['duration'],
    );
  }
}

class RecipeImage {
  final int id;
  final String image;
  final String? caption;

  RecipeImage({
    required this.id,
    required this.image,
    this.caption,
  });

  factory RecipeImage.fromJson(Map<String, dynamic> json) {
    return RecipeImage(
      id: json['id'],
      image: json['image'],
      caption: json['caption'],
    );
  }
}
