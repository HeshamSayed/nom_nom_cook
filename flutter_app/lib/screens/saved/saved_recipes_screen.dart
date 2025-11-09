import 'package:flutter/material.dart';
import '../../widgets/empty_state.dart';

class SavedRecipesScreen extends StatelessWidget {
  const SavedRecipesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved Recipes'),
      ),
      body: const EmptyState(
        icon: Icons.bookmark_border,
        title: 'No Saved Recipes',
        message: 'Start saving recipes you love!',
      ),
    );
  }
}
