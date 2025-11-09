import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/recipe_model.dart';
import '../screens/recipe/recipe_detail_screen.dart';

class RecipeCard extends StatelessWidget {
  final RecipeModel recipe;
  final VoidCallback? onLike;
  final VoidCallback? onSave;

  const RecipeCard({
    super.key,
    required this.recipe,
    this.onLike,
    this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => RecipeDetailScreen(recipeId: recipe.id),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Recipe Image
            AspectRatio(
              aspectRatio: 16 / 9,
              child: CachedNetworkImage(
                imageUrl: recipe.mainImage,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: Colors.grey[300],
                  child: const Center(child: CircularProgressIndicator()),
                ),
                errorWidget: (context, url, error) => Container(
                  color: Colors.grey[300],
                  child: const Icon(Icons.restaurant, size: 50),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    recipe.title,
                    style: Theme.of(context).textTheme.titleLarge,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),

                  // Author
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 12,
                        backgroundImage: recipe.author.avatar != null
                            ? CachedNetworkImageProvider(recipe.author.avatar!)
                            : null,
                        child: recipe.author.avatar == null
                            ? Text(recipe.author.username[0].toUpperCase())
                            : null,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        recipe.author.username,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Recipe Info
                  Row(
                    children: [
                      Icon(Icons.schedule, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        '${recipe.totalTime} min',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(width: 16),
                      Icon(Icons.people, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        '${recipe.servings} servings',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(width: 16),
                      Icon(Icons.bar_chart, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        recipe.difficulty,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Tags
                  if (recipe.tags.isNotEmpty)
                    Wrap(
                      spacing: 4,
                      runSpacing: 4,
                      children: recipe.tags.take(3).map((tag) {
                        return Chip(
                          label: Text(tag),
                          labelStyle: const TextStyle(fontSize: 11),
                          padding: EdgeInsets.zero,
                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        );
                      }).toList(),
                    ),
                  const SizedBox(height: 8),

                  // Stats Row
                  Row(
                    children: [
                      // Rating
                      Icon(Icons.star, size: 16, color: Colors.amber[700]),
                      const SizedBox(width: 4),
                      Text(
                        recipe.ratingAverage.toStringAsFixed(1),
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      Text(
                        ' (${recipe.ratingCount})',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const Spacer(),

                      // Actions
                      IconButton(
                        icon: Icon(
                          recipe.isLiked ? Icons.favorite : Icons.favorite_border,
                          color: recipe.isLiked ? Colors.red : null,
                        ),
                        onPressed: onLike,
                        visualDensity: VisualDensity.compact,
                      ),
                      Text('${recipe.likesCount}'),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: Icon(
                          recipe.isSaved ? Icons.bookmark : Icons.bookmark_border,
                          color: recipe.isSaved ? Colors.blue : null,
                        ),
                        onPressed: onSave,
                        visualDensity: VisualDensity.compact,
                      ),
                      Text('${recipe.savesCount}'),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
