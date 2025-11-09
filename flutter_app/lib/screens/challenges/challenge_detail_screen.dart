import 'package:flutter/material.dart';
import '../../models/challenge_model.dart';
import '../recipe/recipe_detail_screen.dart';

class ChallengeDetailScreen extends StatefulWidget {
  final ChallengeModel challenge;

  const ChallengeDetailScreen({super.key, required this.challenge});

  @override
  State<ChallengeDetailScreen> createState() => _ChallengeDetailScreenState();
}

class _ChallengeDetailScreenState extends State<ChallengeDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = false;
  List<ChallengeEntryModel> _entries = [];
  int? _userVote;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _userVote = widget.challenge.userVote;
    _loadEntries();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadEntries() async {
    setState(() {
      _isLoading = true;
    });

    // TODO: Load from API
    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App Bar with Challenge Info
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(widget.challenge.title),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      _getStatusColor(widget.challenge.status),
                      _getStatusColor(widget.challenge.status).withOpacity(0.7),
                    ],
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _getStatusEmoji(widget.challenge.status),
                        style: const TextStyle(fontSize: 48),
                      ),
                      const SizedBox(height: 8),
                      if (widget.challenge.timeRemaining != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '⏰ ${widget.challenge.timeRemaining!.toDisplayString()} remaining',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Challenge Details
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Theme
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.restaurant),
                        const SizedBox(width: 8),
                        Text(
                          widget.challenge.theme,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Description
                  Text(
                    widget.challenge.description,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),

                  const SizedBox(height: 24),

                  // Stats Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatColumn(
                        Icons.people,
                        '${widget.challenge.participantsCount}',
                        'Participants',
                      ),
                      _buildStatColumn(
                        Icons.how_to_vote,
                        '${widget.challenge.totalVotes}',
                        'Total Votes',
                      ),
                      _buildStatColumn(
                        Icons.emoji_events,
                        widget.challenge.status == 'completed' ? '1' : '-',
                        'Winner',
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Prize Description
                  if (widget.challenge.prizeDescription != null) ...[
                    Card(
                      color: Colors.amber.shade50,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.card_giftcard,
                                  color: Colors.amber,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Prize',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(widget.challenge.prizeDescription!),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Action Buttons
                  Row(
                    children: [
                      if (widget.challenge.status == 'active')
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _submitRecipe,
                            icon: const Icon(Icons.add),
                            label: Text(
                              widget.challenge.isUserParticipating
                                  ? 'Already Joined'
                                  : 'Submit Recipe',
                            ),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                          ),
                        ),
                      if (widget.challenge.status == 'voting' &&
                          _userVote == null)
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              _showVotingInfo();
                            },
                            icon: const Icon(Icons.how_to_vote),
                            label: const Text('Vote Now'),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              backgroundColor: Colors.blue,
                            ),
                          ),
                        ),
                      if (_userVote != null)
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _removeVote,
                            icon: const Icon(Icons.check_circle),
                            label: const Text('Voted'),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                          ),
                        ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Tabs
                  TabBar(
                    controller: _tabController,
                    labelColor: Theme.of(context).colorScheme.primary,
                    tabs: const [
                      Tab(text: 'All Entries'),
                      Tab(text: 'Leaderboard'),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Tab Content
          SliverFillRemaining(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildEntriesTab(),
                _buildLeaderboardTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEntriesTab() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_entries.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('📝', style: TextStyle(fontSize: 64)),
            const SizedBox(height: 16),
            Text(
              'No Entries Yet',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            const Text('Be the first to submit your recipe!'),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _entries.length,
      itemBuilder: (context, index) {
        return _buildEntryCard(_entries[index]);
      },
    );
  }

  Widget _buildLeaderboardTab() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final sortedEntries = List<ChallengeEntryModel>.from(_entries)
      ..sort((a, b) => b.votesCount.compareTo(a.votesCount));

    if (sortedEntries.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('🏆', style: TextStyle(fontSize: 64)),
            SizedBox(height: 16),
            Text('No entries yet'),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: sortedEntries.length > 10 ? 10 : sortedEntries.length,
      itemBuilder: (context, index) {
        final entry = sortedEntries[index];
        return _buildLeaderboardCard(entry, index + 1);
      },
    );
  }

  Widget _buildEntryCard(ChallengeEntryModel entry) {
    final isVoted = _userVote == entry.id;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isVoted
            ? const BorderSide(color: Colors.green, width: 2)
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => RecipeDetailScreen(recipe: entry.recipe),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Column(
          children: [
            // Recipe Image
            if (entry.recipe.mainImage != null)
              ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(12)),
                child: Image.network(
                  entry.recipe.mainImage!,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Recipe Title
                  Text(
                    entry.recipe.title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Author
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundImage: entry.user.avatar != null
                            ? NetworkImage(entry.user.avatar!)
                            : null,
                        child: entry.user.avatar == null
                            ? const Icon(Icons.person, size: 16)
                            : null,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        entry.user.username,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Votes and Vote Button
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.how_to_vote,
                                size: 16, color: Colors.blue),
                            const SizedBox(width: 4),
                            Text(
                              '${entry.votesCount} votes',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      if (widget.challenge.status == 'voting' &&
                          _userVote == null)
                        ElevatedButton.icon(
                          onPressed: () => _voteForEntry(entry),
                          icon: const Icon(Icons.thumb_up, size: 16),
                          label: const Text('Vote'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                          ),
                        ),
                      if (isVoted)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.check_circle,
                                  size: 16, color: Colors.white),
                              SizedBox(width: 4),
                              Text(
                                'Your Vote',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
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

  Widget _buildLeaderboardCard(ChallengeEntryModel entry, int rank) {
    final medalEmoji = rank == 1
        ? '🥇'
        : rank == 2
            ? '🥈'
            : rank == 3
                ? '🥉'
                : '$rank';

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: rank <= 3 ? Colors.amber : Colors.grey,
          child: Text(
            medalEmoji,
            style: const TextStyle(fontSize: 20),
          ),
        ),
        title: Text(
          entry.recipe.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(entry.user.username),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${entry.votesCount}',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Text(
              'votes',
              style: TextStyle(fontSize: 12),
            ),
          ],
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => RecipeDetailScreen(recipe: entry.recipe),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatColumn(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, size: 32, color: Theme.of(context).colorScheme.primary),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'active':
        return Colors.orange;
      case 'voting':
        return Colors.blue;
      case 'upcoming':
        return Colors.purple;
      case 'completed':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  String _getStatusEmoji(String status) {
    switch (status) {
      case 'active':
        return '🔥';
      case 'voting':
        return '🗳️';
      case 'upcoming':
        return '📅';
      case 'completed':
        return '🏆';
      default:
        return '📍';
    }
  }

  void _submitRecipe() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Submit Recipe'),
        content: const Text(
          'Select a recipe from your collection to submit to this challenge.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Navigate to recipe selection or creation
            },
            child: const Text('Select Recipe'),
          ),
        ],
      ),
    );
  }

  void _showVotingInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Voting Phase'),
        content: const Text(
          'Browse the entries below and vote for your favorite recipe! You can only vote once per challenge.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it!'),
          ),
        ],
      ),
    );
  }

  void _voteForEntry(ChallengeEntryModel entry) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cast Your Vote'),
        content: Text(
          'Vote for "${entry.recipe.title}" by ${entry.user.username}?\n\nYou can only vote once per challenge.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _userVote = entry.id;
                entry.votesCount++;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Voted for ${entry.recipe.title}!'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
            ),
            child: const Text('Vote'),
          ),
        ],
      ),
    );
  }

  void _removeVote() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Vote'),
        content: const Text('Are you sure you want to remove your vote?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _userVote = null;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Vote removed'),
                ),
              );
            },
            child: const Text(
              'Remove',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
