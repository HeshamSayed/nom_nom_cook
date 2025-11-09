import 'recipe_model.dart';
import 'user_model.dart';

class ChallengeModel {
  final int id;
  final String title;
  final String? titleAr;
  final String description;
  final String? descriptionAr;
  final String theme;
  final String? themeAr;
  final DateTime startDate;
  final DateTime endDate;
  final DateTime votingEndDate;
  final String status; // upcoming, active, voting, completed
  final RecipeModel? winnerRecipe;
  final int participantsCount;
  final int totalVotes;
  final int maxEntriesPerUser;
  final bool isPremiumOnly;
  final String? prizeDescription;
  final String? prizeDescriptionAr;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isUserParticipating;
  final int? userVote; // entry_id if user has voted
  final TimeRemaining? timeRemaining;

  ChallengeModel({
    required this.id,
    required this.title,
    this.titleAr,
    required this.description,
    this.descriptionAr,
    required this.theme,
    this.themeAr,
    required this.startDate,
    required this.endDate,
    required this.votingEndDate,
    required this.status,
    this.winnerRecipe,
    required this.participantsCount,
    required this.totalVotes,
    required this.maxEntriesPerUser,
    required this.isPremiumOnly,
    this.prizeDescription,
    this.prizeDescriptionAr,
    required this.createdAt,
    required this.updatedAt,
    required this.isUserParticipating,
    this.userVote,
    this.timeRemaining,
  });

  factory ChallengeModel.fromJson(Map<String, dynamic> json) {
    return ChallengeModel(
      id: json['id'],
      title: json['title'],
      titleAr: json['title_ar'],
      description: json['description'],
      descriptionAr: json['description_ar'],
      theme: json['theme'],
      themeAr: json['theme_ar'],
      startDate: DateTime.parse(json['start_date']),
      endDate: DateTime.parse(json['end_date']),
      votingEndDate: DateTime.parse(json['voting_end_date']),
      status: json['status'],
      winnerRecipe: json['winner_recipe'] != null
          ? RecipeModel.fromJson(json['winner_recipe'])
          : null,
      participantsCount: json['participants_count'],
      totalVotes: json['total_votes'],
      maxEntriesPerUser: json['max_entries_per_user'],
      isPremiumOnly: json['is_premium_only'],
      prizeDescription: json['prize_description'],
      prizeDescriptionAr: json['prize_description_ar'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      isUserParticipating: json['is_user_participating'] ?? false,
      userVote: json['user_vote'],
      timeRemaining: json['time_remaining'] != null
          ? TimeRemaining.fromJson(json['time_remaining'])
          : null,
    );
  }
}

class TimeRemaining {
  final int days;
  final int hours;

  TimeRemaining({required this.days, required this.hours});

  factory TimeRemaining.fromJson(Map<String, dynamic> json) {
    return TimeRemaining(
      days: json['days'],
      hours: json['hours'],
    );
  }

  String toDisplayString() {
    if (days > 0) {
      return '$days day${days > 1 ? 's' : ''} ${hours}h';
    } else {
      return '${hours}h';
    }
  }
}

class ChallengeEntryModel {
  final int id;
  final int challengeId;
  final RecipeModel recipe;
  final UserModel user;
  final int votesCount;
  final int? ranking;
  final String? submissionNotes;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool hasVoted;

  ChallengeEntryModel({
    required this.id,
    required this.challengeId,
    required this.recipe,
    required this.user,
    required this.votesCount,
    this.ranking,
    this.submissionNotes,
    required this.createdAt,
    required this.updatedAt,
    required this.hasVoted,
  });

  factory ChallengeEntryModel.fromJson(Map<String, dynamic> json) {
    return ChallengeEntryModel(
      id: json['id'],
      challengeId: json['challenge'],
      recipe: RecipeModel.fromJson(json['recipe']),
      user: UserModel.fromJson(json['user']),
      votesCount: json['votes_count'],
      ranking: json['ranking'],
      submissionNotes: json['submission_notes'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      hasVoted: json['has_voted'] ?? false,
    );
  }
}

class RecipeVoteModel {
  final int id;
  final int challengeId;
  final int entryId;
  final UserModel user;
  final DateTime createdAt;

  RecipeVoteModel({
    required this.id,
    required this.challengeId,
    required this.entryId,
    required this.user,
    required this.createdAt,
  });

  factory RecipeVoteModel.fromJson(Map<String, dynamic> json) {
    return RecipeVoteModel(
      id: json['id'],
      challengeId: json['challenge'],
      entryId: json['entry'],
      user: UserModel.fromJson(json['user']),
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}
