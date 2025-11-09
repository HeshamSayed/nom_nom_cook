import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../providers/recipe_provider.dart';
import '../../widgets/loading_indicator.dart';
import '../../widgets/error_view.dart';

class RecipeDetailScreen extends StatefulWidget {
  final int recipeId;

  const RecipeDetailScreen({super.key, required this.recipeId});

  @override
  State<RecipeDetailScreen> createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends State<RecipeDetailScreen> {
  @override
  void initState() {
    super.initState();
    context.read<RecipeProvider>().fetchRecipeDetails(widget.recipeId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<RecipeProvider>(
        builder: (context, recipeProvider, _) {
          final recipe = recipeProvider.selectedRecipe;

          if (recipeProvider.isLoading || recipe == null) {
            return const LoadingIndicator(message: 'Loading recipe...');
          }

          if (recipeProvider.error != null) {
            return ErrorView(
              message: recipeProvider.error!,
              onRetry: () {
                recipeProvider.fetchRecipeDetails(widget.recipeId);
              },
            );
          }

          return CustomScrollView(
            slivers: [
              // App Bar with Image
              SliverAppBar(
                expandedHeight: 300,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(
                    recipe.title,
                    style: const TextStyle(
                      color: Colors.white,
                      shadows: [Shadow(blurRadius: 4, color: Colors.black)],
                    ),
                  ),
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      CachedNetworkImage(
                        imageUrl: recipe.mainImage,
                        fit: BoxFit.cover,
                      ),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withOpacity(0.7),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Content
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Author Info
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 24,
                            backgroundImage: recipe.author.avatar != null
                                ? CachedNetworkImageProvider(recipe.author.avatar!)
                                : null,
                            child: recipe.author.avatar == null
                                ? Text(recipe.author.username[0].toUpperCase())
                                : null,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  recipe.author.fullName,
                                  style: Theme.of(context).textTheme.titleMedium,
                                ),
                                Text(
                                  '@${recipe.author.username}',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              // TODO: Follow/Unfollow
                            },
                            child: const Text('Follow'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Description
                      Text(
                        recipe.description,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      const SizedBox(height: 16),

                      // Recipe Info
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildInfoItem(
                                context,
                                Icons.schedule,
                                '${recipe.totalTime} min',
                                'Total Time',
                              ),
                              _buildInfoItem(
                                context,
                                Icons.people,
                                '${recipe.servings}',
                                'Servings',
                              ),
                              _buildInfoItem(
                                context,
                                Icons.bar_chart,
                                recipe.difficulty,
                                'Difficulty',
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Action Buttons
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () {
                                recipeProvider.likeRecipe(recipe.id);
                              },
                              icon: Icon(
                                recipe.isLiked ? Icons.favorite : Icons.favorite_border,
                                color: recipe.isLiked ? Colors.red : null,
                              ),
                              label: Text('${recipe.likesCount} Likes'),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () {
                                recipeProvider.saveRecipe(recipe.id);
                              },
                              icon: Icon(
                                recipe.isSaved ? Icons.bookmark : Icons.bookmark_border,
                                color: recipe.isSaved ? Colors.blue : null,
                              ),
                              label: const Text('Save'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Ingredients
                      Text(
                        'Ingredients',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 12),
                      ...recipe.ingredients.map((ingredient) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            children: [
                              const Icon(Icons.check_circle_outline, size: 20),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  '${ingredient.quantity} ${ingredient.unit} ${ingredient.ingredient.name}',
                                  style: Theme.of(context).textTheme.bodyLarge,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                      const SizedBox(height: 24),

                      // Instructions
                      Text(
                        'Instructions',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 12),
                      ...recipe.steps.map((step) {
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 16,
                                      child: Text('${step.stepNumber}'),
                                    ),
                                    const SizedBox(width: 12),
                                    if (step.duration != null)
                                      Chip(
                                        label: Text('${step.duration} min'),
                                        avatar: const Icon(Icons.timer, size: 16),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  step.instruction,
                                  style: Theme.of(context).textTheme.bodyLarge,
                                ),
                                if (step.image != null) ...[
                                  const SizedBox(height: 8),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: CachedNetworkImage(
                                      imageUrl: step.image!,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                      const SizedBox(height: 24),

                      // Nutrition (if available)
                      if (recipe.calories != null) ...[
                        Text(
                          'Nutritional Information',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 12),
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              children: [
                                _buildNutritionRow('Calories', '${recipe.calories} kcal'),
                                if (recipe.protein != null)
                                  _buildNutritionRow('Protein', '${recipe.protein}g'),
                                if (recipe.carbs != null)
                                  _buildNutritionRow('Carbs', '${recipe.carbs}g'),
                                if (recipe.fat != null)
                                  _buildNutritionRow('Fat', '${recipe.fat}g'),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],

                      // CookSnaps
                      if (recipe.cooksnaps.isNotEmpty) ...[
                        Text(
                          'CookSnaps (${recipe.cooksnaps.length})',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          height: 200,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: recipe.cooksnaps.length,
                            itemBuilder: (context, index) {
                              final cooksnap = recipe.cooksnaps[index];
                              return Card(
                                clipBehavior: Clip.antiAlias,
                                margin: const EdgeInsets.only(right: 12),
                                child: SizedBox(
                                  width: 200,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: CachedNetworkImage(
                                          imageUrl: cooksnap.image,
                                          fit: BoxFit.cover,
                                          width: double.infinity,
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8),
                                        child: Text(
                                          'by @${cooksnap.user.username}',
                                          style: Theme.of(context).textTheme.bodySmall,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // TODO: Share CookSnap
        },
        icon: const Icon(Icons.camera_alt),
        label: const Text('Share CookSnap'),
      ),
    );
  }

  Widget _buildInfoItem(BuildContext context, IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, size: 32),
        const SizedBox(height: 4),
        Text(value, style: Theme.of(context).textTheme.titleMedium),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }

  Widget _buildNutritionRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
