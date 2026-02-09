import 'package:flutter/material.dart';
import '../services/game_data_service.dart';
import '../models/team.dart';
import '../models/player.dart';
import 'squad_screen.dart';
import 'league_table_screen.dart';
import 'news_screen.dart';
import 'tactics_screen.dart';

class MainGameScreen extends StatefulWidget {
  @override
  _MainGameScreenState createState() => _MainGameScreenState();
}

class _MainGameScreenState extends State<MainGameScreen> {
  List<String> newsEvents = [];

  @override
  void initState() {
    super.initState();
    _generateInitialNews();
  }

  void _generateInitialNews() {
    setState(() {
      newsEvents = [
        "${GameDataService.getFormattedDate()} - Sezon başladı! ${GameDataService.getSelectedTeam()?.name} ile şampiyonluk hedefleniyor.",
        "${GameDataService.getFormattedDate()} - Transfer penceresi kapandı. Kadro son halini aldı.",
        "${GameDataService.getFormattedDate()} - Teknik direktör ilk antrenmanı yönetti.",
      ];
    });
  }

  void _simulateDay() {
    GameDataService.nextDay();
    
    // Rastgele olaylar oluştur
    String newEvent = _generateRandomEvent();
    
    setState(() {
      newsEvents.insert(0, "${GameDataService.getFormattedDate()} - $newEvent");
      // Sadece son 20 olayı tut
      if (newsEvents.length > 20) {
        newsEvents.removeLast();
      }
    });

    // Oyuncu durumlarını güncelle (basit simülasyon)
    _updatePlayerStatuses();
  }

  String _generateRandomEvent() {
    Team? team = GameDataService.getSelectedTeam();
    if (team == null) return "Sistem hatası";

    List<String> events = [
      "${team.name} antrenmanda harika bir performans sergiledi.",
      "Taraftarlar sosyal medyada destek mesajları yayınlıyor.",
      "Medya: ${team.name} şampiyonluk adayı olarak gösteriliyor.",
      "Rakip takım teknik direktörü: ${team.name} zor bir rakip.",
    ];

    // Öfkeli oyuncu varsa özel olay
    Player? angryPlayer = team.players.firstWhere(
      (p) => p.status == "Angry",
      orElse: () => team.players.first,
    );
    
    if (angryPlayer.status == "Angry") {
      events.add("${angryPlayer.name}: Neden oynamıyorum? Sabrım kalmadı!");
    }

    events.shuffle();
    return events.first;
  }

  void _updatePlayerStatuses() {
    Team? team = GameDataService.getSelectedTeam();
    if (team == null) return;

    // Rastgele bazı oyuncuları oynat veya yedek bırak
    for (var player in team.players) {
      bool played = DateTime.now().millisecond % 3 != 0; // Rastgele
      player.updateStatus(played);
    }
  }

  @override
  Widget build(BuildContext context) {
    Team? team = GameDataService.getSelectedTeam();
    
    return Scaffold(
      backgroundColor: Color(0xFF0A0E12),
      appBar: AppBar(
        title: Column(
          children: [
            Text(
              team?.name ?? "Takım Seçilmedi",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            Text(
              GameDataService.getFormattedDate(),
              style: TextStyle(fontSize: 12, color: Colors.grey[400]),
            ),
          ],
        ),
        backgroundColor: Color(0xFF1A1F26),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Takım Durum Paneli
          if (team != null)
            Container(
              padding: EdgeInsets.all(16),
              color: Color(0xFF1A1F26),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Puan: ${team.points}",
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        "Sıra: ${team.position}",
                        style: TextStyle(color: Colors.grey[400]),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        "Takım Moral: ${team.teamMorale}",
                        style: TextStyle(
                          color: _getMoraleColor(team.teamMorale),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (team.angryPlayersCount > 0)
                        Text(
                          "${team.angryPlayersCount} öfkeli oyuncu",
                          style: TextStyle(color: Colors.redAccent, fontSize: 12),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          
          // Haberler Akışı
          Expanded(
            child: Container(
              margin: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Color(0xFF1A1F26),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[800]!),
              ),
              child: Column(
                children: [
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Color(0xFF252B33),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(8),
                        topRight: Radius.circular(8),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.article, color: Colors.blueAccent),
                        SizedBox(width: 8),
                        Text(
                          "GÜNCEL GELİŞMELER",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: newsEvents.isEmpty
                        ? Center(
                            child: Text(
                              "Henüz gelişme yok",
                              style: TextStyle(color: Colors.grey[500]),
                            ),
                          )
                        : ListView.builder(
                            padding: EdgeInsets.all(8),
                            itemCount: newsEvents.length,
                            itemBuilder: (context, index) {
                              return Container(
                                margin: EdgeInsets.only(bottom: 8),
                                padding: EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: index == 0 ? Color(0xFF2A3441) : Color(0xFF252B33),
                                  borderRadius: BorderRadius.circular(6),
                                  border: index == 0 
                                    ? Border.all(color: Colors.blueAccent.withOpacity(0.3))
                                    : null,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      newsEvents[index],
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          ),
          
          // Alt Navigasyon
          Container(
            padding: EdgeInsets.all(8),
            color: Color(0xFF1A1F26),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildNavButton("Taktik", Icons.sports_soccer, () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => TacticsScreen()),
                  );
                }),
                _buildNavButton("Kadro", Icons.group, () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SquadScreen()),
                  );
                }),
                _buildNavButton("Puan Durumu", Icons.leaderboard, () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => LeagueTableScreen()),
                  );
                }),
                _buildNavButton("Haberler", Icons.article, () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => NewsScreen()),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _simulateDay,
        backgroundColor: Colors.green[800],
        icon: Icon(Icons.play_arrow, color: Colors.white),
        label: Text("DEVAM ET", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildNavButton(String label, IconData icon, VoidCallback onPressed) {
    return InkWell(
      onTap: onPressed,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Color(0xFF252B33),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.blueAccent, size: 20),
            SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(color: Colors.grey[300], fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }

  Color _getMoraleColor(String morale) {
    switch (morale) {
      case "Harika":
        return Colors.green;
      case "İyi":
        return Colors.lightGreen;
      case "Orta":
        return Colors.yellow;
      case "Kötü":
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
