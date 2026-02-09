import 'player.dart';

class Team {
  final String name;
  final int budget;
  final int reputation;
  List<Player> players;
  
  // Takım istatistikleri
  int wins = 0;
  int draws = 0;
  int losses = 0;
  int goalsFor = 0;
  int goalsAgainst = 0;
  int points = 0;
  int position = 1;

  Team({
    required this.name,
    required this.budget,
    required this.reputation,
    required this.players,
  });

  // JSON'dan Team oluşturma
  factory Team.fromJson(Map<String, dynamic> json) {
    var playersList = json['players'] as List;
    List<Player> players = playersList.map((i) => Player.fromJson(i)).toList();
    
    return Team(
      name: json['name'],
      budget: json['budget'],
      reputation: json['reputation'],
      players: players,
    );
  }

  // Takımın ortalama overall değeri
  double get averageOverall {
    if (players.isEmpty) return 0;
    return players.map((p) => p.overall).reduce((a, b) => a + b) / players.length;
  }

  // Takımdaki öfkeli oyuncu sayısı
  int get angryPlayersCount {
    return players.where((p) => p.status == "Angry" || p.status == "Unrest").length;
  }

  // Takım moral durumu
  String get teamMorale {
    int angryCount = angryPlayersCount;
    if (angryCount == 0) return "Harika";
    if (angryCount <= 2) return "İyi";
    if (angryCount <= 4) return "Orta";
    return "Kötü";
  }

  // Maç sonucunu güncelle
  void updateMatchResult(int goalsScored, int goalsConceded) {
    goalsFor += goalsScored;
    goalsAgainst += goalsConceded;
    
    if (goalsScored > goalsConceded) {
      wins++;
      points += 3;
    } else if (goalsScored == goalsConceded) {
      draws++;
      points += 1;
    } else {
      losses++;
    }
  }
}
