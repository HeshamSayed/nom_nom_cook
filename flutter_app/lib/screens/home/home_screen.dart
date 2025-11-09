import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/recipe_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/recipe_card.dart';
import '../../widgets/animated_loading.dart';
import '../../widgets/custom_empty_state.dart';
import '../../widgets/custom_bottom_nav.dart';
import '../../theme/app_colors.dart';
import '../recipe/recipe_search_screen.dart';
import '../recipe/recipe_create_screen.dart';
import '../challenges/challenges_screen.dart';
import '../meal_plan/meal_plan_screen.dart';
import '../profile/profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final ScrollController _scrollController = ScrollController();
  late final List<CustomBottomNavItem> _navItems;

  @override
  void initState() {
    super.initState();
    _navItems = [
      CustomBottomNavItem(
        icon: Icons.restaurant_menu_outlined,
        activeIcon: Icons.restaurant_menu,
        label: 'Recipes',
        screen: _buildRecipeFeedScreen(),
      ),
      CustomBottomNavItem(
        icon: Icons.search_outlined,
        activeIcon: Icons.search,
        label: 'Search',
        screen: const RecipeSearchScreen(),
      ),
      CustomBottomNavItem(
        icon: Icons.emoji_events_outlined,
        activeIcon: Icons.emoji_events,
        label: 'Challenges',
        screen: const ChallengesScreen(),
      ),
      CustomBottomNavItem(
        icon: Icons.calendar_today_outlined,
        activeIcon: Icons.calendar_today,
        label: 'Meal Plan',
        screen: const MealPlanScreen(),
      ),
      CustomBottomNavItem(
        icon: Icons.person_outline,
        activeIcon: Icons.person,
        label: 'Profile',
        screen: const ProfileScreen(),
      ),
    ];
    _loadRecipes();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _loadRecipes() {
    final recipeProvider = context.read<RecipeProvider>();
    recipeProvider.fetchRecipes();
    recipeProvider.fetchCategories();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent * 0.9) {
      // Load more recipes when reaching 90% of scroll
      // TODO: Implement pagination
    }
  }

  void _handleLike(int recipeId) async {
    await context.read<RecipeProvider>().likeRecipe(recipeId);
    _loadRecipes(); // Refresh
  }

  void _handleSave(int recipeId) async {
    await context.read<RecipeProvider>().saveRecipe(recipeId);
    _loadRecipes(); // Refresh
  }

  Widget _buildRecipeFeedScreen() {
    return Consumer<RecipeProvider>(
      builder: (context, recipeProvider, _) {
        if (recipeProvider.isLoading && recipeProvider.recipes.isEmpty) {
          return const AnimatedLoading(message: 'Loading delicious recipes...');
        }

        if (recipeProvider.error != null && recipeProvider.recipes.isEmpty) {
          return CustomEmptyState(
            emoji: '😞',
            title: 'Oops!',
            subtitle: recipeProvider.error!,
            actionText: 'Try Again',
            onAction: _loadRecipes,
          );
        }

        if (recipeProvider.recipes.isEmpty) {
          return CustomEmptyState(
            emoji: '🍳',
            title: 'No Recipes Yet',
            subtitle: 'Be the first to share a delicious recipe with our community!',
            actionText: 'Create Your First Recipe',
            onAction: () {
              setState(() {
                _selectedIndex = 1; // Navigate to create
              });
            },
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            await recipeProvider.fetchRecipes();
          },
          child: ListView.builder(
            controller: _scrollController,
            itemCount: recipeProvider.recipes.length + 1,
            itemBuilder: (context, index) {
              if (index == recipeProvider.recipes.length) {
                return recipeProvider.isLoading
                    ? const Padding(
                        padding: EdgeInsets.all(16),
                        child: Center(child: CircularProgressIndicator()),
                      )
                    : const SizedBox(height: 16);
              }

              final recipe = recipeProvider.recipes[index];
              return RecipeCard(
                recipe: recipe,
                onLike: () => _handleLike(recipe.id),
                onSave: () => _handleSave(recipe.id),
              );
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _selectedIndex == 0
          ? AppBar(
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      shape: BoxShape.circle,
                    ),
                    child: const Text(
                      '🍳',
                      style: TextStyle(fontSize: 20),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ShaderMask(
                    shaderCallback: (bounds) => AppColors.primaryGradient.createShader(bounds),
                    child: const Text(
                      'Nom Nom Cook',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.notifications_outlined),
                  onPressed: () {
                    // TODO: Navigate to notifications
                  },
                ),
                Consumer<AuthProvider>(
                  builder: (context, authProvider, _) {
                    if (authProvider.currentUser?.isPremium == true) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            gradient: AppColors.premiumGradient,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.workspace_premium, size: 16, color: Colors.white),
                              SizedBox(width: 4),
                              Text(
                                'Premium',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ],
            )
          : null,
      body: IndexedStack(
        index: _selectedIndex,
        children: _navItems.map((item) => item.screen).toList(),
      ),
      bottomNavigationBar: CustomBottomNav(
        items: _navItems,
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton.extended(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const RecipeCreateScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.add),
              label: const Text('Create Recipe'),
            )
          : null,
    );
  }
}
