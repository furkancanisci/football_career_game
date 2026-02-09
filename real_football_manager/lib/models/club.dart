class Club {
  final String id;
  final String name;
  final int prestige;
  final Map<String, dynamic> finances;
  final Map<String, dynamic> clubCulture;
  final List<dynamic> squad;
  
  Club({
    required this.id,
    required this.name,
    required this.prestige,
    required this.finances,
    required this.clubCulture,
    required this.squad,
  });
  
  factory Club.fromJson(Map<String, dynamic> json) {
    return Club(
      id: json['id'],
      name: json['name'],
      prestige: json['prestige'] ?? 75,
      finances: Map<String, dynamic>.from(json['finances'] ?? {}),
      clubCulture: Map<String, dynamic>.from(json['club_culture'] ?? {}),
      squad: json['squad'] ?? [],
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'prestige': prestige,
      'finances': finances,
      'club_culture': clubCulture,
      'squad': squad,
    };
  }
}
