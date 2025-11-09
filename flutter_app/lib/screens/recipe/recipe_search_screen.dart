import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/recipe_provider.dart';
import '../../widgets/recipe_card.dart';
import '../../widgets/loading_indicator.dart';
import '../../widgets/empty_state.dart';

class RecipeSearchScreen extends StatefulWidget {
  const RecipeSearchScreen({super.key});

  @override
  State<RecipeSearchScreen> createState() => _RecipeSearchScreenState();
}

class _RecipeSearchScreenState extends State<RecipeSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _showFilters = false;
  String? _selectedCategory;
  String? _selectedDifficulty;
  final Set<String> _selectedDietary = {};

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _performSearch() {
    context.read<RecipeProvider>().searchRecipes(_searchController.text);
  }

  void _applyFilters() {
    context.read<RecipeProvider>().filterRecipes(
          categoryId: _selectedCategory != null ? int.parse(_selectedCategory!) : null,
          difficulty: _selectedDifficulty,
          isVegan: _selectedDietary.contains('vegan'),
          isVegetarian: _selectedDietary.contains('vegetarian'),
          isGlutenFree: _selectedDietary.contains('gluten_free'),
        );
    setState(() {
      _showFilters = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Search recipes...',
            border: InputBorder.none,
            suffixIcon: IconButton(
              icon: const Icon(Icons.search),
              onPressed: _performSearch,
            ),
          ),
          onSubmitted: (_) => _performSearch(),
        ),
        actions: [
          IconButton(
            icon: Icon(_showFilters ? Icons.filter_list_off : Icons.filter_list),
            onPressed: () {
              setState(() {
                _showFilters = !_showFilters;
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          if (_showFilters)
            Container(
              padding: const EdgeInsets.all(16),
              color: Theme.of(context).colorScheme.surface,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Filters',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),

                  // Category Filter
                  Consumer<RecipeProvider>(
                    builder: (context, provider, _) {
                      return DropdownButtonFormField<String>(
                        decoration: const InputDecoration(labelText: 'Category'),
                        value: _selectedCategory,
                        items: provider.categories.map((category) {
                          return DropdownMenuItem(
                            value: category.id.toString(),
                            child: Text(category.name),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedCategory = value;
                          });
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 12),

                  // Difficulty Filter
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(labelText: 'Difficulty'),
                    value: _selectedDifficulty,
                    items: const [
                      DropdownMenuItem(value: 'easy', child: Text('Easy')),
                      DropdownMenuItem(value: 'medium', child: Text('Medium')),
                      DropdownMenuItem(value: 'hard', child: Text('Hard')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedDifficulty = value;
                      });
                    },
                  ),
                  const SizedBox(height: 12),

                  // Dietary Preferences
                  Text(
                    'Dietary Preferences',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  Wrap(
                    spacing: 8,
                    children: [
                      FilterChip(
                        label: const Text('Vegan'),
                        selected: _selectedDietary.contains('vegan'),
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              _selectedDietary.add('vegan');
                            } else {
                              _selectedDietary.remove('vegan');
                            }
                          });
                        },
                      ),
                      FilterChip(
                        label: const Text('Vegetarian'),
                        selected: _selectedDietary.contains('vegetarian'),
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              _selectedDietary.add('vegetarian');
                            } else {
                              _selectedDietary.remove('vegetarian');
                            }
                          });
                        },
                      ),
                      FilterChip(
                        label: const Text('Gluten Free'),
                        selected: _selectedDietary.contains('gluten_free'),
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              _selectedDietary.add('gluten_free');
                            } else {
                              _selectedDietary.remove('gluten_free');
                            }
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  ElevatedButton(
                    onPressed: _applyFilters,
                    child: const Text('Apply Filters'),
                  ),
                ],
              ),
            ),

          // Search Results
          Expanded(
            child: Consumer<RecipeProvider>(
              builder: (context, recipeProvider, _) {
                if (recipeProvider.isLoading) {
                  return const LoadingIndicator(message: 'Searching...');
                }

                if (recipeProvider.recipes.isEmpty) {
                  return const EmptyState(
                    icon: Icons.search_off,
                    title: 'No Results',
                    message: 'Try adjusting your search or filters',
                  );
                }

                return ListView.builder(
                  itemCount: recipeProvider.recipes.length,
                  itemBuilder: (context, index) {
                    final recipe = recipeProvider.recipes[index];
                    return RecipeCard(
                      recipe: recipe,
                      onLike: () {
                        recipeProvider.likeRecipe(recipe.id);
                      },
                      onSave: () {
                        recipeProvider.saveRecipe(recipe.id);
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
