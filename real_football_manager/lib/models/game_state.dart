class GameState {
  final DateTime currentDate;
  final List<Email> inbox;
  final List<String> news;
  final Map<String, dynamic> teamStats;
  final int currentWeek;

  GameState({
    required this.currentDate,
    required this.inbox,
    required this.news,
    required this.teamStats,
    required this.currentWeek,
  });

  GameState copyWith({
    DateTime? currentDate,
    List<Email>? inbox,
    List<String>? news,
    Map<String, dynamic>? teamStats,
    int? currentWeek,
  }) {
    return GameState(
      currentDate: currentDate ?? this.currentDate,
      inbox: inbox ?? this.inbox,
      news: news ?? this.news,
      teamStats: teamStats ?? this.teamStats,
      currentWeek: currentWeek ?? this.currentWeek,
    );
  }
}

class Email {
  final String subject;
  final String body;
  final bool actionNeeded;

  Email(this.subject, this.body, this.actionNeeded);
}