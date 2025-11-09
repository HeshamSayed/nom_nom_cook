import 'package:flutter/material.dart';

class ShoppingListScreen extends StatefulWidget {
  const ShoppingListScreen({super.key});

  @override
  State<ShoppingListScreen> createState() => _ShoppingListScreenState();
}

class _ShoppingListScreenState extends State<ShoppingListScreen> {
  final List<ShoppingItem> _items = [
    ShoppingItem(name: 'Rice', quantity: '2', unit: 'cups', category: 'Grains'),
    ShoppingItem(name: 'Tomatoes', quantity: '4', unit: 'pieces', category: 'Vegetables'),
    ShoppingItem(name: 'Chicken', quantity: '1', unit: 'kg', category: 'Protein'),
    ShoppingItem(name: 'Onions', quantity: '3', unit: 'pieces', category: 'Vegetables'),
    ShoppingItem(name: 'Garlic', quantity: '1', unit: 'head', category: 'Vegetables'),
  ];

  final TextEditingController _itemController = TextEditingController();

  @override
  void dispose() {
    _itemController.dispose();
    super.dispose();
  }

  void _toggleItem(int index) {
    setState(() {
      _items[index].isChecked = !_items[index].isChecked;
    });
  }

  void _deleteItem(int index) {
    setState(() {
      _items.removeAt(index);
    });
  }

  void _addItem() {
    if (_itemController.text.isNotEmpty) {
      setState(() {
        _items.add(ShoppingItem(
          name: _itemController.text,
          quantity: '1',
          unit: 'item',
          category: 'Other',
        ));
        _itemController.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final groupedItems = <String, List<ShoppingItem>>{};
    for (var item in _items) {
      groupedItems.putIfAbsent(item.category, () => []).add(item);
    }

    final uncheckedCount = _items.where((item) => !item.isChecked).length;
    final checkedCount = _items.where((item) => item.isChecked).length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Shopping List'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Clear Checked Items'),
                  content: const Text('Remove all checked items from the list?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _items.removeWhere((item) => item.isChecked);
                        });
                        Navigator.pop(context);
                      },
                      child: const Text('Clear'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Progress Bar
          Container(
            padding: const EdgeInsets.all(16),
            color: Theme.of(context).colorScheme.surface,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Shopping Progress',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Text(
                      '$checkedCount / ${_items.length}',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: _items.isEmpty ? 0 : checkedCount / _items.length,
                  minHeight: 8,
                  borderRadius: BorderRadius.circular(4),
                ),
              ],
            ),
          ),

          // Add Item
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _itemController,
                    decoration: const InputDecoration(
                      hintText: 'Add item to shopping list...',
                      prefixIcon: Icon(Icons.add_shopping_cart),
                    ),
                    onSubmitted: (_) => _addItem(),
                  ),
                ),
                const SizedBox(width: 8),
                FloatingActionButton.small(
                  onPressed: _addItem,
                  child: const Icon(Icons.add),
                ),
              ],
            ),
          ),

          // Shopping List
          Expanded(
            child: _items.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.shopping_cart_outlined,
                          size: 100,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Your shopping list is empty',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Add items or generate from meal plans',
                        ),
                      ],
                    ),
                  )
                : ListView(
                    children: groupedItems.entries.map((entry) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                            child: Text(
                              entry.key,
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ),
                          ...entry.value.asMap().entries.map((itemEntry) {
                            final item = itemEntry.value;
                            final index = _items.indexOf(item);

                            return Dismissible(
                              key: Key(item.name + index.toString()),
                              background: Container(
                                color: Colors.red,
                                alignment: Alignment.centerRight,
                                padding: const EdgeInsets.only(right: 16),
                                child: const Icon(Icons.delete, color: Colors.white),
                              ),
                              direction: DismissDirection.endToStart,
                              onDismissed: (_) => _deleteItem(index),
                              child: CheckboxListTile(
                                value: item.isChecked,
                                onChanged: (_) => _toggleItem(index),
                                title: Text(
                                  item.name,
                                  style: TextStyle(
                                    decoration: item.isChecked
                                        ? TextDecoration.lineThrough
                                        : null,
                                  ),
                                ),
                                subtitle: Text('${item.quantity} ${item.unit}'),
                                secondary: Icon(
                                  _getCategoryIcon(item.category),
                                  color: Colors.grey[600],
                                ),
                              ),
                            );
                          }).toList(),
                        ],
                      );
                    }).toList(),
                  ),
          ),
        ],
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'vegetables':
        return Icons.eco;
      case 'protein':
        return Icons.egg;
      case 'grains':
        return Icons.grain;
      case 'dairy':
        return Icons.water_drop;
      default:
        return Icons.shopping_bag;
    }
  }
}

class ShoppingItem {
  final String name;
  final String quantity;
  final String unit;
  final String category;
  bool isChecked;

  ShoppingItem({
    required this.name,
    required this.quantity,
    required this.unit,
    required this.category,
    this.isChecked = false,
  });
}
