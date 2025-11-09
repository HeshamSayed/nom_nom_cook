import 'package:flutter/foundation.dart';
import '../services/api_service.dart';

class SubscriptionModel {
  final int id;
  final String planType;
  final String status;
  final DateTime startDate;
  final DateTime endDate;
  final DateTime? trialEndDate;
  final bool autoRenew;

  SubscriptionModel({
    required this.id,
    required this.planType,
    required this.status,
    required this.startDate,
    required this.endDate,
    this.trialEndDate,
    required this.autoRenew,
  });

  factory SubscriptionModel.fromJson(Map<String, dynamic> json) {
    return SubscriptionModel(
      id: json['id'],
      planType: json['plan']['plan_type'],
      status: json['status'],
      startDate: DateTime.parse(json['start_date']),
      endDate: DateTime.parse(json['end_date']),
      trialEndDate: json['trial_end_date'] != null
          ? DateTime.parse(json['trial_end_date'])
          : null,
      autoRenew: json['auto_renew'],
    );
  }

  bool get isTrialing => status == 'trialing';
  bool get isActive => status == 'active';

  int get daysRemaining {
    if (isTrialing && trialEndDate != null) {
      return trialEndDate!.difference(DateTime.now()).inDays;
    }
    return endDate.difference(DateTime.now()).inDays;
  }
}

class SubscriptionPlanModel {
  final int id;
  final String name;
  final String nameAr;
  final String planType;
  final double priceEgp;
  final int trialPeriodDays;
  final bool isAdFree;
  final bool hasExclusiveContent;
  final int maxFamilyMembers;

  SubscriptionPlanModel({
    required this.id,
    required this.name,
    required this.nameAr,
    required this.planType,
    required this.priceEgp,
    required this.trialPeriodDays,
    required this.isAdFree,
    required this.hasExclusiveContent,
    required this.maxFamilyMembers,
  });

  factory SubscriptionPlanModel.fromJson(Map<String, dynamic> json) {
    return SubscriptionPlanModel(
      id: json['id'],
      name: json['name'],
      nameAr: json['name_ar'],
      planType: json['plan_type'],
      priceEgp: double.parse(json['price_egp'].toString()),
      trialPeriodDays: json['trial_period_days'] ?? 60,
      isAdFree: json['is_ad_free'] ?? true,
      hasExclusiveContent: json['has_exclusive_content'] ?? true,
      maxFamilyMembers: json['max_family_members'] ?? 1,
    );
  }
}

class SubscriptionProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<SubscriptionPlanModel> _plans = [];
  SubscriptionModel? _currentSubscription;
  bool _isLoading = false;
  String? _error;

  List<SubscriptionPlanModel> get plans => _plans;
  SubscriptionModel? get currentSubscription => _currentSubscription;
  bool get isLoading => _isLoading;
  String? get error => _error;

  bool get isPremium => _currentSubscription != null &&
      (_currentSubscription!.isActive || _currentSubscription!.isTrialing);

  // Fetch subscription plans
  Future<void> fetchPlans() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final data = await _apiService.get('/subscriptions/plans/', requiresAuth: false);
      _plans = (data as List)
          .map((json) => SubscriptionPlanModel.fromJson(json))
          .toList();
      _error = null;
    } catch (e) {
      _error = e.toString();
      debugPrint('Error fetching subscription plans: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Fetch current subscription
  Future<void> fetchCurrentSubscription() async {
    try {
      final data = await _apiService.get('/subscriptions/subscriptions/current/');
      _currentSubscription = SubscriptionModel.fromJson(data);
      notifyListeners();
    } catch (e) {
      // No active subscription - this is okay
      _currentSubscription = null;
      notifyListeners();
    }
  }

  // Subscribe to a plan
  Future<bool> subscribe(int planId, {String? couponCode}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final payload = {
        'plan_id': planId,
        if (couponCode != null) 'coupon_code': couponCode,
      };

      final data = await _apiService.post(
        '/subscriptions/subscriptions/subscribe/',
        payload,
      );

      _currentSubscription = SubscriptionModel.fromJson(data['subscription']);
      _error = null;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      debugPrint('Error subscribing: $e');
      return false;
    }
  }

  // Cancel subscription
  Future<bool> cancelSubscription() async {
    if (_currentSubscription == null) return false;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _apiService.post(
        '/subscriptions/subscriptions/${_currentSubscription!.id}/cancel/',
        {},
      );

      // Refresh current subscription
      await fetchCurrentSubscription();

      _error = null;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      debugPrint('Error canceling subscription: $e');
      return false;
    }
  }

  // Validate coupon
  Future<Map<String, dynamic>?> validateCoupon(String code, int planId) async {
    try {
      final data = await _apiService.post(
        '/subscriptions/coupons/validate/',
        {
          'code': code,
          'plan_id': planId,
        },
      );
      return data;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
