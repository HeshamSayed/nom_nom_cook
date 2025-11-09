import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/subscription_provider.dart';
import 'payment_screen.dart';

class SubscriptionPlansScreen extends StatefulWidget {
  const SubscriptionPlansScreen({super.key});

  @override
  State<SubscriptionPlansScreen> createState() => _SubscriptionPlansScreenState();
}

class _SubscriptionPlansScreenState extends State<SubscriptionPlansScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch plans and current subscription
    Future.microtask(() {
      final provider = context.read<SubscriptionProvider>();
      provider.fetchPlans();
      provider.fetchCurrentSubscription();
    });
  }

  @override
  Widget build(BuildContext context) {
    final subscriptionProvider = Provider.of<SubscriptionProvider>(context);
    final currentPlan = subscriptionProvider.currentSubscription;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Subscription Plans'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Current Plan Status
            if (currentPlan != null) ...[
              Card(
                color: Theme.of(context).colorScheme.primaryContainer,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(
                        Icons.star,
                        color: Theme.of(context).colorScheme.primary,
                        size: 32,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Current Plan: ${_getPlanName(currentPlan.planType)}',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Expires: ${_formatDate(currentPlan.endDate)}',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],

            // Premium Benefits
            Text(
              'Premium Benefits',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildBenefitItem(
              context,
              Icons.block,
              'Ad-Free Experience',
              'Enjoy recipes without interruptions',
            ),
            _buildBenefitItem(
              context,
              Icons.folder_special,
              'Advanced Organization',
              'Unlimited folders and collections',
            ),
            _buildBenefitItem(
              context,
              Icons.calendar_month,
              'Unlimited Meal Planning',
              'Plan meals for months ahead',
            ),
            _buildBenefitItem(
              context,
              Icons.shopping_cart,
              'Smart Shopping Lists',
              'Auto-generate from meal plans',
            ),
            _buildBenefitItem(
              context,
              Icons.workspace_premium,
              'Exclusive Content',
              'Access premium recipes and tips',
            ),
            _buildBenefitItem(
              context,
              Icons.support_agent,
              'Priority Support',
              '24/7 customer support',
            ),
            _buildBenefitItem(
              context,
              Icons.download,
              'Offline Access',
              'Download recipes for offline use',
            ),

            const SizedBox(height: 32),

            // Free Trial Banner
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).colorScheme.primary,
                    Theme.of(context).colorScheme.secondary,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.celebration,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '🎉 2 MONTHS FREE TRIAL',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Try all premium features free for 60 days!',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Subscription Plans
            Text(
              'Choose Your Plan',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // Dynamic Plan Cards from Backend
            if (subscriptionProvider.isLoading)
              const Center(child: CircularProgressIndicator())
            else if (subscriptionProvider.plans.isEmpty)
              const Center(child: Text('No plans available'))
            else
              ...subscriptionProvider.plans.map((plan) {
                final isRecommended = plan.planType == 'individual';
                final trialText = plan.trialPeriodDays > 0
                    ? '${(plan.trialPeriodDays / 30).round()} months FREE'
                    : null;

                final features = <String>[
                  if (plan.trialPeriodDays > 0)
                    '${(plan.trialPeriodDays / 30).round()} months FREE trial',
                  'All premium features',
                  if (plan.maxFamilyMembers == 1)
                    '1 user account'
                  else
                    'Up to ${plan.maxFamilyMembers} family members',
                  'Unlimited recipes',
                  if (plan.isAdFree) 'Ad-free experience',
                  if (plan.hasExclusiveContent) 'Exclusive content',
                  'Priority support',
                  if (plan.maxFamilyMembers > 1) ...[
                    'Shared meal plans',
                    'Combined shopping lists',
                    'Family recipe collections',
                  ],
                ];

                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: _buildPlanCard(
                    context,
                    planId: plan.id,
                    planType: plan.planType,
                    title: plan.name,
                    price: 'EGP ${plan.priceEgp.toStringAsFixed(0)}',
                    period: '/month',
                    trialText: trialText,
                    features: features,
                    isRecommended: isRecommended,
                    currentPlan: currentPlan?.planType,
                  ),
                );
              }).toList(),

            const SizedBox(height: 24),

            // Terms
            Center(
              child: TextButton(
                onPressed: () {
                  // TODO: Show terms and conditions
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Terms & Conditions'),
                      content: const SingleChildScrollView(
                        child: Text(
                          'Subscription Terms:\n\n'
                          '• New users get 2 months FREE trial\n'
                          '• Trial starts immediately upon subscription\n'
                          '• No payment required during trial period\n'
                          '• Cancel anytime during trial - no charges\n'
                          '• After trial, EGP 29/month (Individual) or EGP 79/month (Family)\n'
                          '• Subscriptions automatically renew unless cancelled\n'
                          '• Cancel anytime from your account settings\n'
                          '• Refunds available within 7 days of purchase\n'
                          '• Premium features accessible during active subscription\n'
                          '• Payment processed securely through Stripe\n\n'
                          'For full terms, visit our website.',
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Close'),
                        ),
                      ],
                    ),
                  );
                },
                child: const Text('Terms & Conditions'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBenefitItem(
    BuildContext context,
    IconData icon,
    String title,
    String description,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanCard(
    BuildContext context, {
    required int planId,
    required String planType,
    required String title,
    required String price,
    required String period,
    String? trialText,
    required List<String> features,
    required bool isRecommended,
    required String? currentPlan,
  }) {
    final isCurrentPlan = currentPlan == planType;

    return Card(
      elevation: isRecommended ? 8 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: isRecommended
            ? BorderSide(
                color: Theme.of(context).colorScheme.primary,
                width: 2,
              )
            : BorderSide.none,
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (isCurrentPlan)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'ACTIVE',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 16),

                // Trial Badge
                if (trialText != null && !isCurrentPlan) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.green.shade400,
                          Colors.green.shade600,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.card_giftcard,
                          color: Colors.white,
                          size: 16,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          trialText,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                ],

                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (!isCurrentPlan && trialText != null) ...[
                      Text(
                        'Then ',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey[600],
                        ),
                      ),
                    ],
                    Text(
                      price,
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    Text(
                      period,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                ...features.map((feature) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        children: [
                          Icon(
                            Icons.check_circle,
                            color: Theme.of(context).colorScheme.primary,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(feature),
                          ),
                        ],
                      ),
                    )),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isCurrentPlan
                        ? null
                        : () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PaymentScreen(
                                  planId: planId,
                                  planType: planType,
                                  planTitle: title,
                                  price: price,
                                ),
                              ),
                            );
                          },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      isCurrentPlan
                        ? 'Current Plan'
                        : (trialText != null ? 'Start Free Trial' : 'Subscribe Now'),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (isRecommended)
            Positioned(
              top: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(16),
                    bottomLeft: Radius.circular(16),
                  ),
                ),
                child: const Text(
                  'RECOMMENDED',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _getPlanName(String planType) {
    switch (planType) {
      case 'individual':
        return 'Individual';
      case 'family':
        return 'Family';
      default:
        return planType;
    }
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}
