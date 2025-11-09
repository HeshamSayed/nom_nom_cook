import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../providers/recipe_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/recipe_model.dart';

class RecipeCreateScreen extends StatefulWidget {
  const RecipeCreateScreen({super.key});

  @override
  State<RecipeCreateScreen> createState() => _RecipeCreateScreenState();
}

class _RecipeCreateScreenState extends State<RecipeCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _prepTimeController = TextEditingController();
  final _cookTimeController = TextEditingController();
  final _servingsController = TextEditingController();

  File? _mainImage;
  final ImagePicker _picker = ImagePicker();

  String _difficulty = 'easy';
  int? _selectedCategoryId;
  final List<String> _tags = [];
  final TextEditingController _tagController = TextEditingController();

  // Dietary preferences
  bool _isVegan = false;
  bool _isVegetarian = false;
  bool _isGlutenFree = false;
  bool _isDairyFree = false;
  bool _isKeto = false;
  bool _isHalal = true;

  // Ingredients
  final List<IngredientInput> _ingredients = [];

  // Steps
  final List<StepInput> _steps = [];

  int _currentStep = 0;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _prepTimeController.dispose();
    _cookTimeController.dispose();
    _servingsController.dispose();
    _tagController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1920,
      maxHeight: 1080,
      imageQuality: 85,
    );

    if (image != null) {
      setState(() {
        _mainImage = File(image.path);
      });
    }
  }

  void _addIngredient() {
    setState(() {
      _ingredients.add(IngredientInput());
    });
  }

  void _removeIngredient(int index) {
    setState(() {
      _ingredients.removeAt(index);
    });
  }

  void _addStep() {
    setState(() {
      _steps.add(StepInput(stepNumber: _steps.length + 1));
    });
  }

  void _removeStep(int index) {
    setState(() {
      _steps.removeAt(index);
      // Renumber steps
      for (int i = 0; i < _steps.length; i++) {
        _steps[i].stepNumber = i + 1;
      }
    });
  }

  void _addTag() {
    if (_tagController.text.isNotEmpty) {
      setState(() {
        _tags.add(_tagController.text.trim());
        _tagController.clear();
      });
    }
  }

  Future<void> _submitRecipe() async {
    if (_formKey.currentState!.validate()) {
      if (_mainImage == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please add a recipe image')),
        );
        return;
      }

      if (_ingredients.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please add at least one ingredient')),
        );
        return;
      }

      if (_steps.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please add at least one step')),
        );
        return;
      }

      // TODO: Upload image and create recipe
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Recipe created successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Recipe'),
        actions: [
          TextButton(
            onPressed: _submitRecipe,
            child: const Text('Publish', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: Stepper(
          currentStep: _currentStep,
          onStepContinue: () {
            if (_currentStep < 3) {
              setState(() {
                _currentStep++;
              });
            }
          },
          onStepCancel: () {
            if (_currentStep > 0) {
              setState(() {
                _currentStep--;
              });
            }
          },
          steps: [
            // Step 1: Basic Info
            Step(
              title: const Text('Basic Info'),
              content: Column(
                children: [
                  // Image Picker
                  GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      height: 200,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(12),
                        image: _mainImage != null
                            ? DecorationImage(
                                image: FileImage(_mainImage!),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      child: _mainImage == null
                          ? Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.add_photo_alternate, size: 50, color: Colors.grey[400]),
                                const SizedBox(height: 8),
                                Text('Add Recipe Photo', style: TextStyle(color: Colors.grey[600])),
                              ],
                            )
                          : null,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Title
                  TextFormField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      labelText: 'Recipe Title *',
                      hintText: 'e.g., Egyptian Koshari',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a title';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Description
                  TextFormField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Description *',
                      hintText: 'Describe your recipe...',
                    ),
                    maxLines: 3,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a description';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Category
                  Consumer<RecipeProvider>(
                    builder: (context, provider, _) {
                      return DropdownButtonFormField<int>(
                        decoration: const InputDecoration(labelText: 'Category *'),
                        value: _selectedCategoryId,
                        items: provider.categories.map((category) {
                          return DropdownMenuItem(
                            value: category.id,
                            child: Text(category.name),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedCategoryId = value;
                          });
                        },
                        validator: (value) {
                          if (value == null) {
                            return 'Please select a category';
                          }
                          return null;
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 16),

                  // Time and Servings
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _prepTimeController,
                          decoration: const InputDecoration(
                            labelText: 'Prep Time (min) *',
                          ),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Required';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          controller: _cookTimeController,
                          decoration: const InputDecoration(
                            labelText: 'Cook Time (min) *',
                          ),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Required';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _servingsController,
                          decoration: const InputDecoration(
                            labelText: 'Servings *',
                          ),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Required';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          decoration: const InputDecoration(labelText: 'Difficulty *'),
                          value: _difficulty,
                          items: const [
                            DropdownMenuItem(value: 'easy', child: Text('Easy')),
                            DropdownMenuItem(value: 'medium', child: Text('Medium')),
                            DropdownMenuItem(value: 'hard', child: Text('Hard')),
                          ],
                          onChanged: (value) {
                            setState(() {
                              _difficulty = value!;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Dietary Preferences
                  const Text('Dietary Information', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [
                      FilterChip(
                        label: const Text('Vegan'),
                        selected: _isVegan,
                        onSelected: (value) => setState(() => _isVegan = value),
                      ),
                      FilterChip(
                        label: const Text('Vegetarian'),
                        selected: _isVegetarian,
                        onSelected: (value) => setState(() => _isVegetarian = value),
                      ),
                      FilterChip(
                        label: const Text('Gluten Free'),
                        selected: _isGlutenFree,
                        onSelected: (value) => setState(() => _isGlutenFree = value),
                      ),
                      FilterChip(
                        label: const Text('Dairy Free'),
                        selected: _isDairyFree,
                        onSelected: (value) => setState(() => _isDairyFree = value),
                      ),
                      FilterChip(
                        label: const Text('Keto'),
                        selected: _isKeto,
                        onSelected: (value) => setState(() => _isKeto = value),
                      ),
                      FilterChip(
                        label: const Text('Halal'),
                        selected: _isHalal,
                        onSelected: (value) => setState(() => _isHalal = value),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Tags
                  const Text('Tags', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _tagController,
                          decoration: const InputDecoration(
                            hintText: 'Add tag (e.g., ramadan, iftar)',
                          ),
                          onSubmitted: (_) => _addTag(),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: _addTag,
                      ),
                    ],
                  ),
                  Wrap(
                    spacing: 8,
                    children: _tags.map((tag) {
                      return Chip(
                        label: Text(tag),
                        onDeleted: () {
                          setState(() {
                            _tags.remove(tag);
                          });
                        },
                      );
                    }).toList(),
                  ),
                ],
              ),
              isActive: _currentStep >= 0,
            ),

            // Step 2: Ingredients
            Step(
              title: const Text('Ingredients'),
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ..._ingredients.asMap().entries.map((entry) {
                    int index = entry.key;
                    IngredientInput ingredient = entry.value;
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  flex: 2,
                                  child: TextField(
                                    controller: ingredient.nameController,
                                    decoration: const InputDecoration(
                                      labelText: 'Ingredient',
                                      hintText: 'e.g., Rice',
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: TextField(
                                    controller: ingredient.quantityController,
                                    decoration: const InputDecoration(
                                      labelText: 'Qty',
                                      hintText: '2',
                                    ),
                                    keyboardType: TextInputType.number,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: TextField(
                                    controller: ingredient.unitController,
                                    decoration: const InputDecoration(
                                      labelText: 'Unit',
                                      hintText: 'cups',
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () => _removeIngredient(index),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                  const SizedBox(height: 16),
                  OutlinedButton.icon(
                    onPressed: _addIngredient,
                    icon: const Icon(Icons.add),
                    label: const Text('Add Ingredient'),
                  ),
                ],
              ),
              isActive: _currentStep >= 1,
            ),

            // Step 3: Instructions
            Step(
              title: const Text('Instructions'),
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ..._steps.asMap().entries.map((entry) {
                    int index = entry.key;
                    StepInput step = entry.value;
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
                                  child: Text('${step.stepNumber}'),
                                ),
                                const Spacer(),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () => _removeStep(index),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            TextField(
                              controller: step.instructionController,
                              decoration: const InputDecoration(
                                labelText: 'Instruction',
                                hintText: 'Describe this step...',
                              ),
                              maxLines: 3,
                            ),
                            const SizedBox(height: 8),
                            TextField(
                              controller: step.durationController,
                              decoration: const InputDecoration(
                                labelText: 'Duration (minutes)',
                                hintText: 'Optional',
                              ),
                              keyboardType: TextInputType.number,
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                  const SizedBox(height: 16),
                  OutlinedButton.icon(
                    onPressed: _addStep,
                    icon: const Icon(Icons.add),
                    label: const Text('Add Step'),
                  ),
                ],
              ),
              isActive: _currentStep >= 2,
            ),

            // Step 4: Review
            Step(
              title: const Text('Review'),
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Review your recipe before publishing',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Text('Title: ${_titleController.text}'),
                  Text('Category: ${_selectedCategoryId ?? "Not selected"}'),
                  Text('Prep Time: ${_prepTimeController.text} min'),
                  Text('Cook Time: ${_cookTimeController.text} min'),
                  Text('Servings: ${_servingsController.text}'),
                  Text('Difficulty: $_difficulty'),
                  Text('Ingredients: ${_ingredients.length}'),
                  Text('Steps: ${_steps.length}'),
                  if (_tags.isNotEmpty) Text('Tags: ${_tags.join(", ")}'),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _submitRecipe,
                    icon: const Icon(Icons.publish),
                    label: const Text('Publish Recipe'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                    ),
                  ),
                ],
              ),
              isActive: _currentStep >= 3,
            ),
          ],
        ),
      ),
    );
  }
}

class IngredientInput {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController quantityController = TextEditingController();
  final TextEditingController unitController = TextEditingController();

  void dispose() {
    nameController.dispose();
    quantityController.dispose();
    unitController.dispose();
  }
}

class StepInput {
  int stepNumber;
  final TextEditingController instructionController = TextEditingController();
  final TextEditingController durationController = TextEditingController();

  StepInput({required this.stepNumber});

  void dispose() {
    instructionController.dispose();
    durationController.dispose();
  }
}
