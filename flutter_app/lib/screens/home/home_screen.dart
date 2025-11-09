import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/recipe_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/recipe_card.dart';
import '../../widgets/loading_indicator.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/error_view.dart';
import '../recipe/recipe_search_screen.dart';
import '../recipe/recipe_create_screen.dart';
import '../saved/saved_recipes_screen.dart';
import '../profile/profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
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

  Widget _buildRecipeFeed() {
    return Consumer<RecipeProvider>(
      builder: (context, recipeProvider, _) {
        if (recipeProvider.isLoading && recipeProvider.recipes.isEmpty) {
          return const LoadingIndicator(message: 'Loading delicious recipes...');
        }

        if (recipeProvider.error != null && recipeProvider.recipes.isEmpty) {
          return ErrorView(
            message: recipeProvider.error!,
            onRetry: _loadRecipes,
          );
        }

        if (recipeProvider.recipes.isEmpty) {
          return EmptyState(
            icon: Icons.restaurant_menu,
            title: 'No Recipes Yet',
            message: 'Be the first to share a recipe!',
            actionLabel: 'Create Recipe',
            onAction: () {
              setState(() {
                _selectedIndex = 2; // Navigate to create
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
    final screens = [
      _buildRecipeFeed(),
      const RecipeSearchScreen(),
      const RecipeCreateScreen(),
      const SavedRecipesScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      appBar: _selectedIndex == 0
          ? AppBar(
              title: const Text('Cookpad Egypt'),
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
                        child: Chip(
                          label: const Text('Premium', style: TextStyle(fontSize: 12)),
                          backgroundColor: Colors.amber,
                          avatar: const Icon(Icons.star, size: 16),
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
        children: screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search_outlined),
            activeIcon: Icon(Icons.search),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle_outline),
            activeIcon: Icon(Icons.add_circle),
            label: 'Create',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bookmark_outline),
            activeIcon: Icon(Icons.bookmark),
            label: 'Saved',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
