import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/recipe_model.dart';
import '../screens/recipe/recipe_detail_screen.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

class EnhancedRecipeCard extends StatefulWidget {
  final RecipeModel recipe;
  final VoidCallback? onLike;
  final VoidCallback? onSave;
  final bool isLiked;
  final bool isSaved;

  const EnhancedRecipeCard({
    super.key,
    required this.recipe,
    this.onLike,
    this.onSave,
    this.isLiked = false,
    this.isSaved = false,
  });

  @override
  State<EnhancedRecipeCard> createState() => _EnhancedRecipeCardState();
}

class _EnhancedRecipeCardState extends State<EnhancedRecipeCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: AppDurations.fast,
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.98).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        setState(() => _isPressed = true);
        _controller.forward();
      },
      onTapUp: (_) {
        setState(() => _isPressed = false);
        _controller.reverse();
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RecipeDetailScreen(recipeId: widget.recipe.id),
          ),
        );
      },
      onTapCancel: () {
        setState(() => _isPressed = false);
        _controller.reverse();
      },
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          margin: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: AppSpacing.borderRadiusLg,
            boxShadow: _isPressed ? [] : AppColors.cardShadow,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image with gradient overlay
              Stack(
                children: [
                  // Recipe Image
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(AppSpacing.radiusLg),
                    ),
                    child: AspectRatio(
                      aspectRatio: 16 / 10,
                      child: CachedNetworkImage(
                        imageUrl: widget.recipe.mainImage,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          color: AppColors.surfaceVariant,
                          child: Center(
                            child: CircularProgressIndicator(
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: AppColors.surfaceVariant,
                          child: Icon(
                            Icons.restaurant,
                            size: 50,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Gradient overlay
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 80,
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
                  ),

                  // Difficulty Badge
                  Positioned(
                    top: AppSpacing.sm,
                    left: AppSpacing.sm,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: AppSpacing.xs,
                      ),
                      decoration: BoxDecoration(
                        color: _getDifficultyColor(widget.recipe.difficulty),
                        borderRadius: AppSpacing.borderRadiusSm,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _getDifficultyIcon(widget.recipe.difficulty),
                            size: 14,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            widget.recipe.difficulty.toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Premium Badge
                  if (widget.recipe.isPremiumOnly)
                    Positioned(
                      top: AppSpacing.sm,
                      right: AppSpacing.sm,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                          vertical: AppSpacing.xs,
                        ),
                        decoration: BoxDecoration(
                          gradient: AppColors.premiumGradient,
                          borderRadius: AppSpacing.borderRadiusSm,
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.workspace_premium,
                              size: 14,
                              color: Colors.white,
                            ),
                            SizedBox(width: 4),
                            Text(
                              'PREMIUM',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),

              // Content
              Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      widget.recipe.title,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: AppSpacing.sm),

                    // Author
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 14,
                          backgroundImage: widget.recipe.author.avatar != null
                              ? NetworkImage(widget.recipe.author.avatar!)
                              : null,
                          backgroundColor: AppColors.primaryLight,
                          child: widget.recipe.author.avatar == null
                              ? Icon(
                                  Icons.person,
                                  size: 16,
                                  color: AppColors.primary,
                                )
                              : null,
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Text(
                            widget.recipe.author.username,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textSecondary,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (widget.recipe.author.isPremium)
                          Icon(
                            Icons.verified,
                            size: 16,
                            color: AppColors.premium,
                          ),
                      ],
                    ),

                    const SizedBox(height: AppSpacing.md),

                    // Stats
                    Row(
                      children: [
                        _buildStat(Icons.schedule, '${widget.recipe.totalTime}m'),
                        const SizedBox(width: AppSpacing.md),
                        _buildStat(Icons.restaurant, '${widget.recipe.servings}'),
                        const Spacer(),
                        _buildRating(widget.recipe.ratingAverage),
                      ],
                    ),

                    const SizedBox(height: AppSpacing.md),

                    // Dietary Tags
                    if (widget.recipe.isVegan ||
                        widget.recipe.isVegetarian ||
                        widget.recipe.isHalal)
                      Wrap(
                        spacing: AppSpacing.xs,
                        runSpacing: AppSpacing.xs,
                        children: [
                          if (widget.recipe.isVegan)
                            _buildTag('Vegan', AppColors.success),
                          if (widget.recipe.isVegetarian)
                            _buildTag('Vegetarian', AppColors.accent),
                          if (widget.recipe.isHalal)
                            _buildTag('Halal', AppColors.info),
                        ],
                      ),

                    const SizedBox(height: AppSpacing.md),
                    const Divider(height: 1),
                    const SizedBox(height: AppSpacing.sm),

                    // Actions
                    Row(
                      children: [
                        _buildAction(
                          icon: widget.isLiked
                              ? Icons.favorite
                              : Icons.favorite_border,
                          label: '${widget.recipe.likesCount}',
                          color:
                              widget.isLiked ? AppColors.error : AppColors.textSecondary,
                          onTap: widget.onLike,
                        ),
                        const SizedBox(width: AppSpacing.lg),
                        _buildAction(
                          icon: widget.isSaved
                              ? Icons.bookmark
                              : Icons.bookmark_border,
                          label: '${widget.recipe.savesCount}',
                          color:
                              widget.isSaved ? AppColors.primary : AppColors.textSecondary,
                          onTap: widget.onSave,
                        ),
                        const Spacer(),
                        _buildAction(
                          icon: Icons.visibility,
                          label: '${widget.recipe.viewsCount}',
                          color: AppColors.textSecondary,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStat(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: AppColors.textSecondary),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildRating(double rating) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.star, size: 16, color: AppColors.rating),
        const SizedBox(width: 4),
        Text(
          rating.toStringAsFixed(1),
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildTag(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: AppSpacing.borderRadiusSm,
        border: Border.all(color: color, width: 1),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }

  Widget _buildAction({
    required IconData icon,
    required String label,
    required Color color,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: AppSpacing.borderRadiusSm,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'easy':
        return AppColors.easy;
      case 'medium':
        return AppColors.medium;
      case 'hard':
        return AppColors.hard;
      default:
        return AppColors.textSecondary;
    }
  }

  IconData _getDifficultyIcon(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'easy':
        return Icons.check_circle;
      case 'medium':
        return Icons.adjust;
      case 'hard':
        return Icons.warning;
      default:
        return Icons.circle;
    }
  }
}
