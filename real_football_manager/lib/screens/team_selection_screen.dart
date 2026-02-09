import 'package:flutter/material.dart';
import '../services/data_service.dart';
import '../models/club.dart';
import 'dashboard_screen.dart';

class TeamSelectionScreen extends StatefulWidget {
  const TeamSelectionScreen({Key? key}) : super(key: key);

  @override
  _TeamSelectionScreenState createState() => _TeamSelectionScreenState();
}

class _TeamSelectionScreenState extends State<TeamSelectionScreen> {
  List<Club> clubs = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadClubs();
  }

  Future<void> _loadClubs() async {
    try {
      final clubList = await DataService.getAllClubs();
      setState(() {
        clubs = clubList;
        isLoading = false;
      });
    } catch (e) {
      debugPrint('Kulüpler yüklenemedi: $e');
      setState(() => isLoading = false);
    }
  }

  void _selectClub(Club club) {
    DataService.setSelectedTeam(club);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${club.name} seçildi, kariyer başlıyor...', style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.green[700],
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
      ),
    );
    
    Future.delayed(const Duration(milliseconds: 800), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const DashboardScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E12),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- HEADER (Kompakt) ---
            Container(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              decoration: const BoxDecoration(
                color: Color(0xFF161B22),
                border: Border(bottom: BorderSide(color: Colors.white10)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "TAKIMINI SEÇ",
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 1.0),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "2025-2026 Sezonu • ${clubs.length} Kulüp",
                    style: TextStyle(color: Colors.grey[400], fontSize: 12),
                  ),
                ],
              ),
            ),

            // --- KULÜP LİSTESİ ---
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator(color: Colors.green))
                  : clubs.isEmpty
                      ? const Center(child: Text("Kulüp bulunamadı", style: TextStyle(color: Colors.grey)))
                      : ListView.separated(
                          padding: const EdgeInsets.all(12),
                          itemCount: clubs.length,
                          separatorBuilder: (ctx, index) => const SizedBox(height: 8),
                          itemBuilder: (context, index) {
                            final club = clubs[index];
                            return _buildCompactClubCard(club);
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompactClubCard(Club club) {
    final prestige = club.prestige;
    final finances = club.finances;
    final chaos = club.clubCulture['chaos_factor'] ?? 50;

    // Prestij Rengi
    Color accentColor = prestige >= 85 ? Colors.purpleAccent : (prestige >= 75 ? Colors.blueAccent : Colors.greenAccent);

    return InkWell(
      onTap: () => _selectClub(club),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF161B22),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
        ),
        child: Row(
          children: [
            // 1. Logo / Baş Harf
            Container(
              width: 40,
              height: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: accentColor.withOpacity(0.1),
                shape: BoxShape.circle,
                border: Border.all(color: accentColor.withOpacity(0.5)),
              ),
              child: Text(
                club.name.substring(0, 1),
                style: TextStyle(color: accentColor, fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ),
            
            const SizedBox(width: 12),
            
            // 2. İsim ve Detaylar
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    club.name,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      _buildMiniStat(Icons.star, "$prestige", Colors.amber, "Prestij"),
                      const SizedBox(width: 10),
                      _buildMiniStat(Icons.attach_money, "${(finances['transfer_budget_euro'] ?? 0) ~/ 1000000}M€", Colors.green, "Bütçe"),
                      const SizedBox(width: 10),
                      _buildMiniStat(Icons.flash_on, "$chaos%", Colors.redAccent, "Kaos"),
                    ],
                  ),
                ],
              ),
            ),

            // 3. Ok İkonu
            Icon(Icons.chevron_right, color: Colors.grey[600], size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniStat(IconData icon, String value, Color color, String label) {
    return Row(
      children: [
        Icon(icon, size: 12, color: color),
        const SizedBox(width: 2),
        Text(value, style: TextStyle(color: Colors.grey[300], fontSize: 11, fontWeight: FontWeight.w500)),
      ],
    );
  }
}