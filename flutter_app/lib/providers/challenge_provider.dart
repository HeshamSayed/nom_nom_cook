import 'package:flutter/foundation.dart';
import '../models/challenge_model.dart';
import '../services/api_service.dart';
import '../core/app_constants.dart';

class ChallengeProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<ChallengeModel> _challenges = [];
  List<ChallengeEntryModel> _currentChallengeEntries = [];
  ChallengeModel? _selectedChallenge;
  bool _isLoading = false;
  String? _error;

  List<ChallengeModel> get challenges => _challenges;
  List<ChallengeEntryModel> get currentChallengeEntries => _currentChallengeEntries;
  ChallengeModel? get selectedChallenge => _selectedChallenge;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Filter challenges by status
  List<ChallengeModel> getChallengesByStatus(String status) {
    return _challenges.where((c) => c.status == status).toList();
  }

  // Fetch all challenges
  Future<void> fetchChallenges() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final data = await _apiService.get('/recipes/challenges/');
      _challenges = (data as List)
          .map((json) => ChallengeModel.fromJson(json))
          .toList();
      _error = null;
    } catch (e) {
      _error = e.toString();
      debugPrint('Error fetching challenges: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Fetch challenge details
  Future<void> fetchChallengeDetails(int challengeId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final data = await _apiService.get('/recipes/challenges/$challengeId/');
      _selectedChallenge = ChallengeModel.fromJson(data);
      _error = null;
    } catch (e) {
      _error = e.toString();
      debugPrint('Error fetching challenge details: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Fetch challenge entries
  Future<void> fetchChallengeEntries(int challengeId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final data = await _apiService.get('/recipes/challenges/$challengeId/entries/');
      _currentChallengeEntries = (data as List)
          .map((json) => ChallengeEntryModel.fromJson(json))
          .toList();
      _error = null;
    } catch (e) {
      _error = e.toString();
      debugPrint('Error fetching challenge entries: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Fetch challenge leaderboard
  Future<List<ChallengeEntryModel>> fetchChallengeLeaderboard(int challengeId) async {
    try {
      final data = await _apiService.get('/recipes/challenges/$challengeId/leaderboard/');
      return (data as List)
          .map((json) => ChallengeEntryModel.fromJson(json))
          .toList();
    } catch (e) {
      debugPrint('Error fetching leaderboard: $e');
      return [];
    }
  }

  // Submit recipe to challenge
  Future<bool> submitRecipeToChallenge(int challengeId, int recipeId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _apiService.post('/recipes/challenge-entries/', {
        'challenge': challengeId,
        'recipe': recipeId,
      });

      // Refresh challenge details and entries
      await fetchChallengeDetails(challengeId);
      await fetchChallengeEntries(challengeId);

      _error = null;
      return true;
    } catch (e) {
      _error = e.toString();
      debugPrint('Error submitting recipe to challenge: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Vote for an entry
  Future<bool> voteForEntry(int challengeId, int entryId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _apiService.post('/recipes/challenge-votes/', {
        'challenge': challengeId,
        'entry': entryId,
      });

      // Refresh challenge details and entries to show updated vote counts
      await fetchChallengeDetails(challengeId);
      await fetchChallengeEntries(challengeId);

      _error = null;
      return true;
    } catch (e) {
      _error = e.toString();
      debugPrint('Error voting for entry: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Delete vote (if user wants to change vote)
  Future<bool> deleteVote(int voteId) async {
    try {
      await _apiService.delete('/recipes/challenge-votes/$voteId/');
      return true;
    } catch (e) {
      debugPrint('Error deleting vote: $e');
      return false;
    }
  }

  // Clear selected challenge
  void clearSelectedChallenge() {
    _selectedChallenge = null;
    _currentChallengeEntries = [];
    notifyListeners();
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
