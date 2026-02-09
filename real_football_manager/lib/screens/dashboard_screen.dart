import 'package:flutter/material.dart';
import '../services/data_service.dart';
import '../services/simulation_service.dart'; // Yeni servisi ekledik
import '../models/club.dart';
import '../models/game_state.dart'; 
import '../models/player.dart';

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
  final SimulationService _simulationService = SimulationService(); // Servis instance

  @override
  void initState() {
    super.initState();
    selectedClub = DataService.getSelectedTeam();
    _initializeGameState();
  }

  void _initializeGameState() {
    setState(() {
      gameState = GameState(
        currentDate: DateTime(2025, 8, 15), // Sezon başı
        inbox: [],
        news: ['2025-2026 Sezonu resmen başladı.', 'Yönetim, teknik heyete başarılar diledi.'],
        teamStats: {'morale': 80, 'energy': 100},
        currentWeek: 1,
      );
    });
  }

  // GERÇEK SİMÜLASYON FONKSİYONU
  Future<void> _simulateDay() async {
    if (gameState == null || selectedClub == null || isLoading) return;
    
    setState(() => isLoading = true);

    try {
      // 1. Simülasyon Servisini Çağır (AI ve Mantık burada çalışır)
      final simulationResult = await _simulationService.simulateDay(gameState!, selectedClub!);

      // 2. Gelen Verileri Ayrıştır
      List<String> newNews = simulationResult['news'];
      List<Email> newEmails = simulationResult['emails'];
      Map<String, dynamic> statUpdates = simulationResult['stats'];

      // 3. State'i Güncelle
      setState(() {
        // İstatistikleri birleştir (Mevcut + Değişim)
        Map<String, dynamic> updatedStats = Map.from(gameState!.teamStats);
        if(statUpdates.containsKey('morale')) updatedStats['morale'] = statUpdates['morale'];
        if(statUpdates.containsKey('energy')) updatedStats['energy'] = statUpdates['energy'];

        // Sınırları koru (0-100 arası)
        updatedStats['morale'] = (updatedStats['morale'] as int).clamp(0, 100);
        updatedStats['energy'] = (updatedStats['energy'] as int).clamp(0, 100);

        gameState = gameState!.copyWith(
          currentDate: gameState!.currentDate.add(const Duration(days: 1)),
          inbox: [...gameState!.inbox, ...newEmails], // Yeni mailler alta eklenir
          news: [...newNews, ...gameState!.news],     // Yeni haberler en üste
          teamStats: updatedStats,
        );
        isLoading = false;
      });

      // 4. Kullanıcıya Bildirim (Snackbar)
      if (newEmails.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('⚠️ ${newEmails.length} Yeni Mailin Var!'),
            backgroundColor: Colors.amber[900],
            behavior: SnackBarBehavior.floating,
          ),
        );
      }

    } catch (e) {
      setState(() => isLoading = false);
      print("Simülasyon Hatası: $e");
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Simülasyon hatası oluştu.'), backgroundColor: Colors.red));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (selectedClub == null) return const Scaffold(backgroundColor: Color(0xFF0A0E12));

    return Scaffold(
      backgroundColor: const Color(0xFF0A0E12),
      appBar: AppBar(
        toolbarHeight: 50,
        backgroundColor: const Color(0xFF161B22),
        elevation: 0,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(selectedClub!.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)), Text('2025-2026', style: TextStyle(color: Colors.grey[400], fontSize: 10))]),
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [Text('GÜN ${gameState?.currentDate.day ?? 1}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)), Text('${gameState?.currentDate.day}.${gameState?.currentDate.month}.${gameState?.currentDate.year}', style: TextStyle(color: Colors.grey[400], fontSize: 10))]),
          ],
        ),
      ),
      body: Row(
        children: [
          // SIDEBAR (140px - Eski Fit Tasarım)
          Container(
            width: 140,
            color: const Color(0xFF161B22),
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 10),
              children: [
                _buildMenuItem('TAKTİK', Icons.sports_soccer, () => Navigator.push(context, MaterialPageRoute(builder: (_) => TacticsScreen()))),
                _buildMenuItem('KADRO', Icons.group, () => Navigator.push(context, MaterialPageRoute(builder: (_) => SquadScreen()))),
                _buildMenuItem('FİKSTÜR', Icons.calendar_today, () => Navigator.push(context, MaterialPageRoute(builder: (_) => FixtureScreen()))),
                _buildMenuItem('HABERLER', Icons.article, () => Navigator.push(context, MaterialPageRoute(builder: (_) => NewsScreen()))),
                const Divider(color: Colors.white10),
                _buildMenuItem('MAİL (${gameState?.inbox.length})', Icons.email, _showInbox),
              ],
            ),
          ),
          // ANA İÇERİK
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  Row(children: [
                    Expanded(child: _buildStatusCard('Mailler', '${gameState?.inbox.length ?? 0}', Icons.email, Colors.blue)),
                    const SizedBox(width: 8),
                    Expanded(child: _buildStatusCard('Moral', '${gameState?.teamStats['morale']}%', Icons.sentiment_satisfied, _getColorByValue(gameState?.teamStats['morale'] ?? 50))),
                    const SizedBox(width: 8),
                    Expanded(child: _buildStatusCard('Enerji', '${gameState?.teamStats['energy']}%', Icons.flash_on, _getColorByValue(gameState?.teamStats['energy'] ?? 50))),
                  ]),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity, height: 40,
                    child: ElevatedButton.icon(
                      onPressed: isLoading ? null : _simulateDay,
                      icon: isLoading ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Icon(Icons.play_arrow, size: 20),
                      label: Text(isLoading ? 'HESAPLANIYOR...' : 'GÜNÜ İLERLET', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, letterSpacing: 1)),
                      style: ElevatedButton.styleFrom(backgroundColor: isLoading ? Colors.grey : const Color(0xFFdc2626), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Haber Akışı
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(color: const Color(0xFF161B22), borderRadius: BorderRadius.circular(8)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                           const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            child: Text('GÜNLÜK RAPOR', style: TextStyle(color: Colors.white54, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
                          ),
                          Expanded(
                            child: ListView.separated(
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              itemCount: gameState?.news.length ?? 0,
                              separatorBuilder: (ctx, i) => const Divider(height: 1, color: Colors.white10),
                              itemBuilder: (context, index) => Container(
                                padding: const EdgeInsets.symmetric(vertical: 8), 
                                child: Row(
                                  children: [
                                    Text(
                                      _formatTime(gameState!.currentDate, index), 
                                      style: TextStyle(color: Colors.grey[600], fontSize: 10, fontWeight: FontWeight.bold)
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(child: Text(gameState!.news[index], style: const TextStyle(color: Colors.white70, fontSize: 11))),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- HELPER METODLAR ---

  String _formatTime(DateTime date, int index) {
    // Basit bir saat simülasyonu: Her haber 1-2 saat arayla gelmiş gibi
    int hour = 9 + (index % 10); 
    return "${hour.toString().padLeft(2, '0')}:00";
  }

  Color _getColorByValue(int val) {
    if (val >= 80) return Colors.green;
    if (val >= 50) return Colors.amber;
    return Colors.red;
  }

  Widget _buildMenuItem(String title, IconData icon, VoidCallback onTap) {
    return ListTile(visualDensity: VisualDensity.compact, contentPadding: const EdgeInsets.symmetric(horizontal: 16), leading: Icon(icon, color: Colors.white70, size: 18), title: Text(title, style: const TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w500)), onTap: onTap, dense: true);
  }
  
  Widget _buildStatusCard(String title, String value, IconData icon, Color color) {
    return Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: const Color(0xFF161B22), borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.white.withOpacity(0.1))), child: Row(children: [Icon(icon, color: color, size: 14), const SizedBox(width: 4), Text(title, style: const TextStyle(color: Colors.white70, fontSize: 10)), const Spacer(), Text(value, style: TextStyle(color: color, fontSize: 14, fontWeight: FontWeight.bold))]));
  }

  void _showInbox() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1e293b),
        title: const Text('Gelen Kutusu', style: TextStyle(color: Colors.white, fontSize: 16)),
        content: SizedBox(
          width: double.maxFinite,
          height: 300,
          child: gameState?.inbox.isEmpty == true
              ? const Center(child: Text('Gelen kutunuz boş.', style: TextStyle(color: Colors.white70)))
              : ListView.separated(
                  itemCount: gameState?.inbox.length ?? 0,
                  separatorBuilder: (ctx, i) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final email = gameState!.inbox[index];
                    return Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(6), border: email.actionNeeded ? Border.all(color: Colors.redAccent.withOpacity(0.5)) : null),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(email.subject, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)), if(email.actionNeeded) const Icon(Icons.priority_high, color: Colors.red, size: 14)]),
                          const SizedBox(height: 2),
                          Text(email.body, style: const TextStyle(color: Colors.white70, fontSize: 11), maxLines: 2, overflow: TextOverflow.ellipsis),
                        ],
                      ),
                    );
                  },
                ),
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Kapat', style: TextStyle(color: Colors.blueAccent)))],
      ),
    );
  }
}