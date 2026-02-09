import 'package:flutter/material.dart';
import '../services/data_service.dart';
import '../models/club.dart';
import '../models/player.dart';
import 'player_detail_screen.dart';

class SquadScreen extends StatefulWidget {
  const SquadScreen({Key? key}) : super(key: key);

  @override
  _SquadScreenState createState() => _SquadScreenState();
}

class _SquadScreenState extends State<SquadScreen> {
  Club? selectedClub;
  List<Player> squad = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  void _initializeData() {
    selectedClub = DataService.getSelectedTeam();
    _loadSquad();
  }

  Future<void> _loadSquad() async {
    if (selectedClub == null) {
      setState(() => isLoading = false);
      return;
    }

    try {
      final clubSquad = await DataService.getTeamSquad(selectedClub!.id);
      setState(() {
        squad = clubSquad;
        isLoading = false;
      });
    } catch (e) {
      debugPrint('Kadro yüklenemedi: $e');
      setState(() => isLoading = false);
    }
  }

  String _calculateAverageSkill() {
    if (squad.isEmpty) return "0";
    double sum = squad.fold(0, (previousValue, element) => previousValue + element.skill);
    double average = sum / squad.length;
    return average.toStringAsFixed(1);
  }

  Color _getSkillColor(int skill) {
    if (skill >= 85) return Colors.redAccent;
    if (skill >= 75) return Colors.orange;
    if (skill >= 65) return Colors.yellow;
    if (skill >= 55) return Colors.green;
    return Colors.grey;
  }

  Color _getPositionColor(String position) {
    switch (position) {
      case "GK": return Colors.yellow[700]!;
      case "CB": return Colors.blue;
      case "RB":
      case "LB": return Colors.lightBlue;
      case "CDM":
      case "CM":
      case "CAM": return Colors.purple;
      case "RW":
      case "LW":
      case "ST": return Colors.red;
      default: return Colors.grey;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case "Happy": return Colors.green;
      case "Angry": return Colors.red;
      case "Unrest": return Colors.orange;
      case "Injured": return Colors.brown;
      default: return Colors.grey;
    }
  }

  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E12),
      // AppBar yüksekliğini biraz kıstım (toolbarHeight)
      appBar: AppBar(
        toolbarHeight: 50, 
        title: const Text("KADRO", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: 1.0, color: Colors.white)),
        backgroundColor: const Color(0xFF1A1F26),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.green)))
          : Column(
              children: [
                // --- ÜST BİLGİ PANELİ (DAHA KOMPAKT) ---
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10), // Padding azaltıldı
                  decoration: const BoxDecoration(
                    color: Color(0xFF151920), // Biraz daha koyu
                    border: Border(bottom: BorderSide(color: Colors.white10)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          // Takım İsmi ve Bütçe yan yana
                          Text(
                            selectedClub?.name ?? "Takım Yok",
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                          const SizedBox(width: 8),
                          Container(width: 1, height: 14, color: Colors.grey),
                          const SizedBox(width: 8),
                          Text(
                            "${(selectedClub?.finances['transfer_budget_euro'] ?? 0) / 1000000}M €",
                            style: const TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Text(
                            "Ort: ${_calculateAverageSkill()}",
                            style: const TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            "(${squad.length})",
                            style: TextStyle(color: Colors.grey[500], fontSize: 12),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                // --- KOMPAKT OYUNCU LİSTESİ ---
                Expanded(
                  child: squad.isEmpty
                      ? const Center(child: Text('Kadro bulunamadı.', style: TextStyle(color: Colors.white70)))
                      : ListView.separated(
                          // Padding kaldırıldı, tam ekran
                          padding: EdgeInsets.zero,
                          itemCount: squad.length,
                          separatorBuilder: (context, index) => const Divider(height: 1, color: Colors.white10),
                          itemBuilder: (context, index) {
                            final player = squad[index];
                            return InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => PlayerDetailScreen(player: player),
                                  ),
                                );
                              },
                              child: Container(
                                // Margin YOK. Flat tasarım.
                                color: const Color(0xFF0A0E12), 
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), // Dikey boşluk azaldı
                                child: Row(
                                  children: [
                                    // 1. Numara (Daha küçük avatar)
                                    Container(
                                      width: 30, // 36'dan 30'a indi
                                      height: 30,
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        color: _getSkillColor(player.skill).withOpacity(0.15),
                                        shape: BoxShape.circle,
                                        border: Border.all(color: _getSkillColor(player.skill).withOpacity(0.6), width: 1),
                                      ),
                                      child: Text(
                                        player.jerseyNumber.toString(),
                                        style: TextStyle(
                                          color: _getSkillColor(player.skill),
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12, // Font küçüldü
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    
                                    // 2. İsim ve Mevki (Daha sıkışık)
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            player.name,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w600,
                                              fontSize: 14, // 15'ten 14'e indi
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 2), // Boşluk azaldı
                                          Row(
                                            children: [
                                              // Mevki (Badge daha küçük)
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                                decoration: BoxDecoration(
                                                  color: _getPositionColor(player.position).withOpacity(0.2),
                                                  borderRadius: BorderRadius.circular(3),
                                                ),
                                                child: Text(
                                                  player.position,
                                                  style: TextStyle(
                                                    color: _getPositionColor(player.position),
                                                    fontSize: 9, // Font küçüldü
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 6),
                                              // Yaş Bilgisi Eklendi (Boşluk dolsun)
                                              Text(
                                                "${player.age} yaş",
                                                style: TextStyle(color: Colors.grey[600], fontSize: 10),
                                              ),
                                              const SizedBox(width: 6),
                                              if (player.status == "Injured")
                                                const Icon(Icons.medical_services, size: 12, color: Colors.brown),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),

                                    // 3. Sağ Taraf: Skill (Tek satırda)
                                    Row(
                                      children: [
                                        if (player.traits.contains('Captain'))
                                          const Padding(
                                            padding: EdgeInsets.only(right: 6),
                                            child: Icon(Icons.copyright, color: Colors.blue, size: 14),
                                          ),
                                        Text(
                                          "${player.skill}",
                                          style: TextStyle(
                                            color: _getSkillColor(player.skill),
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16, // Biraz küçüldü ama hala vurgulu
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }
}