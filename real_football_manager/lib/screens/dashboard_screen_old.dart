import 'package:flutter/material.dart';
import '../services/data_service.dart';
import '../models/club.dart';
import '../models/player.dart';
import '../models/game_state.dart';
import '../services/simulation_service.dart';
import 'squad_screen.dart';
import 'league_table_screen.dart';
import 'news_screen.dart';
import 'tactics_screen.dart';
import 'fixture_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);
  
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  Club? selectedClub;
  GameState? gameState;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    selectedClub = DataService.getSelectedTeam();
    _initializeGameState();
  }

  void _initializeGameState() {
    setState(() {
      gameState = GameState(
        currentDate: DateTime.now(),
        inbox: [],
        news: ['Sezon başladı!'],
        recentEvents: [],
        teamStats: {'morale': 85, 'energy': 90},
        currentWeek: 1,
      );
    });
  }

  Future<void> _simulateDay() async {
    if (gameState == null || selectedClub == null || isLoading) return;
    
    setState(() {
      isLoading = true;
    });

    try {
      final result = await SimulationService.simulateDay(
        gameState: gameState!,
        teamId: selectedClub!.id,
        upcomingMatch: 'Fenerbahçe (deplasman)',
      );

      setState(() {
        gameState = gameState!.copyWith(
          currentDate: gameState!.currentDate.add(const Duration(days: 1)),
          inbox: [...gameState!.inbox, ...result.emails],
          news: [...result.news, ...gameState!.news],
          recentEvents: result.news,
          teamStats: {
            ...gameState!.teamStats,
            ...result.teamEffects,
          },
        );
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gün ilerletildi: ${result.news.length} yeni olay'),
          backgroundColor: Colors.green[700],
        ),
      );
      
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Simülasyon hatası: $e'),
          backgroundColor: Colors.red[700],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (selectedClub == null) {
      return Scaffold(
        backgroundColor: const Color(0xFF0f172a),
        body: const Center(
          child: Text(
            'Takım seçilmedi',
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0f172a),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1e293b),
              Color(0xFF0f172a),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  border: Border(
                    bottom: BorderSide(
                      color: Colors.white.withOpacity(0.1),
                    ),
                  ),
                          height: 45,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [BoxShadow(color: Colors.black45, blurRadius: 5)],
                          ),
                          child: Center(
                            child: Text(
                              selectedTeam?.name.substring(0, 1).toUpperCase() ?? "R",
                              style: TextStyle(
                                color: Color(0xFF1A1F26),
                                fontWeight: FontWeight.bold,
                                fontSize: 22
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          "REAL FM",
                          style: TextStyle(
                            color: Colors.white70,
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                            letterSpacing: 1.5
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                // Menü Öğeleri
                Expanded(
                  child: ListView(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    children: [
                      _buildMenuItem(Icons.dashboard_rounded, "Dashboard", true),
                      _buildMenuItem(Icons.people_alt_rounded, "Kadro", false),
                      _buildMenuItem(Icons.shield_rounded, "Taktik", false),
                      _buildMenuItem(Icons.swap_horiz_rounded, "Transfer", false),
                      _buildMenuItem(Icons.newspaper_rounded, "Medya", false),
                      _buildMenuItem(Icons.format_list_numbered_rounded, "Lig Tablosu", false),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // ANA İÇERİK ALANI
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.only(bottom: 80), // FAB altında kalmaması için boşluk
              child: Column(
                children: [
                  // Durum Özeti (Status Bar)
                  Container(
                    padding: EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                    color: Color(0xFF1E252F), // Hafif kontrast
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatusItem("Moral", selectedTeam?.teamMorale ?? "Orta", _getMoraleColor(selectedTeam?.teamMorale ?? "Orta")),
                        _buildStatusItem("Puan", "${selectedTeam?.points ?? 0}", Colors.blueAccent),
                        _buildStatusItem("Sıra", "${selectedTeam?.position ?? 1}.", Colors.purpleAccent),
                        _buildStatusItem("Kriz", "${selectedTeam?.angryPlayersCount ?? 0}", Colors.redAccent),
                      ],
                    ),
                  ),
                  
                  // INBOX BAŞLIĞI
                  Padding(
                    padding: EdgeInsets.fromLTRB(16, 20, 16, 10),
                    child: Row(
                      children: [
                        Icon(Icons.inbox_rounded, color: Colors.blueGrey, size: 18),
                        SizedBox(width: 8),
                        Text(
                          "GELEN KUTUSU",
                          style: TextStyle(
                            color: Colors.blueGrey,
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.2
                          ),
                        ),
                        Spacer(),
                        if (inboxMessages.isNotEmpty)
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            "${inboxMessages.length} Yeni",
                            style: TextStyle(color: Colors.blue, fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // MESAJ LİSTESİ (Scroll Fix Uygulandı)
                  ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    physics: NeverScrollableScrollPhysics(), // Ana sayfa ile birlikte kayar
                    shrinkWrap: true, // İçeriği kadar yer kaplar
                    itemCount: inboxMessages.length,
                    itemBuilder: (context, index) {
                      final msg = inboxMessages[index];
                      return _buildInboxCard(msg);
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.green[700],
        onPressed: _simulateDay,
        icon: Icon(Icons.calendar_today, size: 16),
        label: Text("DEVAM ET", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String title, bool isActive) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      decoration: BoxDecoration(
        color: isActive ? Colors.blue.withOpacity(0.15) : Colors.transparent,
        borderRadius: BorderRadius.circular(6),
        border: isActive ? Border.all(color: Colors.blue.withOpacity(0.3), width: 0.5) : null,
      ),
      child: ListTile(
        dense: true, // Daha kompakt liste elemanı
        visualDensity: VisualDensity(vertical: -2), // Dikey sıkıştırma
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 0),
        leading: Icon(icon, color: isActive ? Colors.blueAccent : Colors.grey[500], size: 18),
        title: Text(
          title,
          style: TextStyle(
            color: isActive ? Colors.blueAccent : Colors.grey[400],
            fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
            fontSize: 13, // Yazı boyutu küçüldü
          ),
        ),
        onTap: () {
          // Navigasyon işlemleri...
           if (title == "Kadro") Navigator.push(context, MaterialPageRoute(builder: (context) => SquadScreen()));
           if (title == "Taktik") Navigator.push(context, MaterialPageRoute(builder: (context) => TacticsScreen()));
           if (title == "Medya") Navigator.push(context, MaterialPageRoute(builder: (context) => NewsScreen()));
           if (title == "Lig Tablosu") Navigator.push(context, MaterialPageRoute(builder: (context) => LeagueTableScreen()));
        },
      ),
    );
  }

  Widget _buildInboxCard(Map<String, String> msg) {
    bool isMedia = msg['type'] == "Media";
    bool isPlayer = msg['type'] == "Player";
    
    // Tip rengi belirleme
    Color typeColor = isMedia ? Colors.blueAccent : (isPlayer ? Colors.orangeAccent : Colors.purpleAccent);

    return Container(
      margin: EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Color(0xFF1E252F),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
        boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2))],
      ),
      child: IntrinsicHeight( // Yan çizginin boyunu içeriğe eşitlemek için
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Sol Renkli Çizgi
            Container(
              width: 4,
              decoration: BoxDecoration(
                color: typeColor,
                borderRadius: BorderRadius.only(topLeft: Radius.circular(8), bottomLeft: Radius.circular(8)),
              ),
            ),
            // İçerik
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              isMedia ? Icons.article_outlined : isPlayer ? Icons.person_outline : Icons.business,
                              color: typeColor,
                              size: 16,
                            ),
                            SizedBox(width: 8),
                            Text(
                              msg['sender']!,
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                          ],
                        ),
                        Text(
                          msg['date']!,
                          style: TextStyle(color: Colors.grey[600], fontSize: 10),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Text(
                      msg['message']!,
                      style: TextStyle(color: Colors.grey[300], fontSize: 12, height: 1.3),
                    ),
                    if (isPlayer) ...[
                      SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          _buildActionButton("Profil", Icons.person, Colors.grey, () {
                             if (msg['playerId']!.isNotEmpty) {
                                // Oyuncu bulma mantığı
                                // Navigasyon...
                             }
                          }),
                          SizedBox(width: 8),
                          _buildActionButton("Konuş", Icons.chat_bubble_outline, Colors.green, () {
                              if (msg['playerId']!.isNotEmpty) {
                                 Player? player = selectedTeam?.players.where((p) => p.name == msg['playerId']).firstOrNull;
                                 if(player != null) {
                                   Navigator.push(context, MaterialPageRoute(builder: (context) => ChatScreen(player: player)));
                                 }
                              }
                          }, isFilled: true),
                        ],
                      ),
                    ]
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(String label, IconData icon, Color color, VoidCallback onPressed, {bool isFilled = false}) {
    return SizedBox(
      height: 28, // Buton yüksekliği küçüldü
      child: isFilled 
      ? ElevatedButton.icon(
          onPressed: onPressed,
          icon: Icon(icon, size: 12),
          label: Text(label, style: TextStyle(fontSize: 11)),
          style: ElevatedButton.styleFrom(
            backgroundColor: color.withOpacity(0.8),
            padding: EdgeInsets.symmetric(horizontal: 10),
          ),
        )
      : OutlinedButton.icon(
          onPressed: onPressed,
          icon: Icon(icon, size: 12),
          label: Text(label, style: TextStyle(fontSize: 11)),
          style: OutlinedButton.styleFrom(
            foregroundColor: color,
            side: BorderSide(color: color.withOpacity(0.5)),
            padding: EdgeInsets.symmetric(horizontal: 10),
          ),
        ),
    );
  }

  Widget _buildStatusItem(String title, String value, Color color) {
    return Column(
      children: [
        Text(title, style: TextStyle(color: Colors.grey[500], fontSize: 10)),
        SizedBox(height: 2),
        Text(value, style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 14)),
      ],
    );
  }

  Color _getMoraleColor(String morale) {
    if (morale == "Harika") return Colors.greenAccent;
    if (morale == "İyi") return Colors.lightGreenAccent;
    if (morale == "Kötü") return Colors.redAccent;
    return Colors.amberAccent;
  }
}