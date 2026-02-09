import 'game_state.dart';

class SimulationResult {
  final List<String> news;
  final List<EmailEvent> emails;
  final RandomEvent? randomEvent;
  final Map<String, dynamic> teamEffects;
  
  SimulationResult({
    required this.news,
    required this.emails,
    this.randomEvent,
    required this.teamEffects,
  });
  
  factory SimulationResult.fromJson(Map<String, dynamic> json) {
    return SimulationResult(
      news: List<String>.from(json['news']),
      emails: (json['emails'] as List)
          .map((email) => EmailEvent.fromJson(email))
          .toList(),
      randomEvent: json['random_event'] != null 
          ? RandomEvent.fromJson(json['random_event'])
          : null,
      teamEffects: Map<String, dynamic>.from(json['team_effects'] ?? {}),
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'news': news,
      'emails': emails.map((email) => email.toJson()).toList(),
      'random_event': randomEvent?.toJson(),
      'team_effects': teamEffects,
    };
  }
}

class RandomEvent {
  final String type;
  final String description;
  final String effect;
  final List<String> involvedPlayers;
  
  RandomEvent({
    required this.type,
    required this.description,
    required this.effect,
    this.involvedPlayers = const [],
  });
  
  factory RandomEvent.fromJson(Map<String, dynamic> json) {
    return RandomEvent(
      type: json['type'],
      description: json['description'],
      effect: json['effect'],
      involvedPlayers: List<String>.from(json['involved_players'] ?? []),
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'description': description,
      'effect': effect,
      'involved_players': involvedPlayers,
    };
  }
}
