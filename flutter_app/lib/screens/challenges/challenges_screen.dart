import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/challenge_model.dart';
import '../../providers/challenge_provider.dart';
import '../../widgets/custom_empty_state.dart';
import '../../widgets/animated_loading.dart';
import 'challenge_detail_screen.dart';

class ChallengesScreen extends StatefulWidget {
  const ChallengesScreen({super.key});

  @override
  State<ChallengesScreen> createState() => _ChallengesScreenState();
}

class _ChallengesScreenState extends State<ChallengesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadChallenges();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadChallenges() async {
    await context.read<ChallengeProvider>().fetchChallenges();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cooking Challenges'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(text: '🔥 Active'),
            Tab(text: '🗳️ Voting'),
            Tab(text: '📅 Upcoming'),
            Tab(text: '🏆 Completed'),
          ],
        ),
      ),
      body: Consumer<ChallengeProvider>(
        builder: (context, challengeProvider, _) {
          if (challengeProvider.isLoading && challengeProvider.challenges.isEmpty) {
            return const AnimatedLoading(message: 'Loading challenges...');
          }

          if (challengeProvider.error != null && challengeProvider.challenges.isEmpty) {
            return CustomEmptyState(
              emoji: '😞',
              title: 'Oops!',
              subtitle: challengeProvider.error!,
              actionText: 'Try Again',
              onAction: _loadChallenges,
            );
          }

          return TabBarView(
            controller: _tabController,
            children: [
              _buildChallengesList(
                challengeProvider.getChallengesByStatus('active'),
                'active',
              ),
              _buildChallengesList(
                challengeProvider.getChallengesByStatus('voting'),
                'voting',
              ),
              _buildChallengesList(
                challengeProvider.getChallengesByStatus('upcoming'),
                'upcoming',
              ),
              _buildChallengesList(
                challengeProvider.getChallengesByStatus('completed'),
                'completed',
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildChallengesList(List<ChallengeModel> challenges, String status) {
    if (challenges.isEmpty) {
      return _buildEmptyState(status);
    }

    return RefreshIndicator(
      onRefresh: _loadChallenges,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: challenges.length,
        itemBuilder: (context, index) {
          return _buildChallengeCard(challenges[index]);
        },
      ),
    );
  }

  Widget _buildEmptyState(String status) {
    String emoji, title, subtitle;

    switch (status) {
      case 'active':
        emoji = '🎯';
        title = 'No Active Challenges';
        subtitle = 'Check back soon for new cooking challenges!';
        break;
      case 'voting':
        emoji = '🗳️';
        title = 'No Voting Challenges';
        subtitle = 'No challenges are currently in voting phase';
        break;
      case 'upcoming':
        emoji = '📅';
        title = 'No Upcoming Challenges';
        subtitle = 'New challenges will be announced soon!';
        break;
      case 'completed':
        emoji = '🏆';
        title = 'No Completed Challenges';
        subtitle = 'Winners will appear here once challenges complete';
        break;
      default:
        emoji = '🔍';
        title = 'No Challenges';
        subtitle = 'Stay tuned!';
    }

    return CustomEmptyState(
      emoji: emoji,
      title: title,
      subtitle: subtitle,
    );
  }

  Widget _buildChallengeCard(ChallengeModel challenge) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChallengeDetailScreen(challenge: challenge),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: _getStatusColor(challenge.status),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text(
                        _getStatusEmoji(challenge.status),
                        style: const TextStyle(fontSize: 20),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _getStatusText(challenge.status),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  if (challenge.timeRemaining != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        challenge.timeRemaining!.toDisplayString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    challenge.title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Theme
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.restaurant, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          challenge.theme,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Description
                  Text(
                    challenge.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),

                  const SizedBox(height: 16),

                  // Stats
                  Row(
                    children: [
                      _buildStat(
                        Icons.people,
                        '${challenge.participantsCount}',
                        'Participants',
                      ),
                      const SizedBox(width: 24),
                      _buildStat(
                        Icons.how_to_vote,
                        '${challenge.totalVotes}',
                        'Votes',
                      ),
                      const Spacer(),
                      if (challenge.isUserParticipating)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Row(
                            children: [
                              Icon(
                                Icons.check_circle,
                                size: 16,
                                color: Colors.white,
                              ),
                              SizedBox(width: 4),
                              Text(
                                'Joined',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
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

  Widget _buildStat(IconData icon, String value, String label) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 4),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey[600],
              ),
            ),
          ],
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

  String _getStatusText(String status) {
    switch (status) {
      case 'active':
        return 'ACTIVE NOW';
      case 'voting':
        return 'VOTING PHASE';
      case 'upcoming':
        return 'COMING SOON';
      case 'completed':
        return 'COMPLETED';
      default:
        return status.toUpperCase();
    }
  }
}
