import 'package:flutter/material.dart';
import '../services/data_service.dart';
import '../models/club.dart';

class LeagueTableScreen extends StatefulWidget {
  @override
  _LeagueTableScreenState createState() => _LeagueTableScreenState();
}

class _LeagueTableScreenState extends State<LeagueTableScreen> {
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
      print('Takımlar yüklenemedi: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E12),
      appBar: AppBar(
        title: const Text("PUAN DURUMU", style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2)),
        backgroundColor: const Color(0xFF1A1F26),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Sezon Bilgisi
          Container(
            padding: const EdgeInsets.all(16),
            color: const Color(0xFF1A1F26),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Trendyol Süper Lig 2025/26",
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
                Text(
                  "Tarih: ${DateTime.now().day}.${DateTime.now().month}.${DateTime.now().year}",
                  style: TextStyle(color: Colors.grey[400]),
                ),
              ],
            ),
          ),
          
          // Tablo Başlıkları
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: const Color(0xFF252B33),
            child: Row(
              children: [
                Expanded(flex: 1, child: Text("#", style: TextStyle(color: Colors.grey[400], fontWeight: FontWeight.bold))),
                Expanded(flex: 4, child: Text("TAKIM", style: TextStyle(color: Colors.grey[400], fontWeight: FontWeight.bold))),
                Expanded(flex: 1, child: Text("O", style: TextStyle(color: Colors.grey[400], fontWeight: FontWeight.bold), textAlign: TextAlign.center)),
                Expanded(flex: 1, child: Text("G", style: TextStyle(color: Colors.grey[400], fontWeight: FontWeight.bold), textAlign: TextAlign.center)),
                Expanded(flex: 1, child: Text("B", style: TextStyle(color: Colors.grey[400], fontWeight: FontWeight.bold), textAlign: TextAlign.center)),
                Expanded(flex: 1, child: Text("M", style: TextStyle(color: Colors.grey[400], fontWeight: FontWeight.bold), textAlign: TextAlign.center)),
                Expanded(flex: 1, child: Text("A", style: TextStyle(color: Colors.grey[400], fontWeight: FontWeight.bold), textAlign: TextAlign.center)),
                Expanded(flex: 1, child: Text("AVG", style: TextStyle(color: Colors.grey[400], fontWeight: FontWeight.bold), textAlign: TextAlign.center)),
              ],
            ),
          ),
          
          // Takımlar Listesi
          Expanded(
            child: isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                    ),
                  )
                : clubs.isEmpty
                    ? const Center(
                        child: Text(
                          'Takım verisi yükleniyor...',
                          style: TextStyle(color: Colors.white70),
                        ),
                      )
                    : ListView.builder(
                        itemCount: clubs.length,
                        itemBuilder: (context, index) {
                          final club = clubs[index];
                          return Container(
                            decoration: BoxDecoration(
                              color: index % 2 == 0 ? const Color(0xFF1A1F26) : const Color(0xFF252B33),
                              border: Border(bottom: BorderSide(color: Colors.grey[800]!)),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 1,
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Text(
                                      "${index + 1}",
                                      style: TextStyle(
                                        color: _getPositionColor(index + 1),
                                        fontWeight: FontWeight.bold,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 4,
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Row(
                                      children: [
                                        CircleAvatar(
                                          backgroundColor: _getPrestigeColor(club.prestige),
                                          radius: 16,
                                          child: Text(
                                            club.name.substring(0, 1).toUpperCase(),
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            club.name,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: Text(
                                    "0",
                                    style: TextStyle(color: Colors.grey[300]),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: Text(
                                    "0",
                                    style: TextStyle(color: Colors.grey[300]),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: Text(
                                    "0",
                                    style: TextStyle(color: Colors.grey[300]),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: Text(
                                    "0",
                                    style: TextStyle(color: Colors.grey[300]),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: Text(
                                    "0-0",
                                    style: TextStyle(color: Colors.grey[300]),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: Text(
                                    "0",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.center,
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
    );
  }

  Color _getPrestigeColor(int prestige) {
    if (prestige >= 90) return Colors.red;
    if (prestige >= 75) return Colors.orange;
    if (prestige >= 60) return Colors.yellow;
    if (prestige >= 45) return Colors.green;
    return Colors.grey;
  }

  Color _getPositionColor(int position) {
    if (position == 1) return Colors.yellow; // Şampiyonlar Ligi
    if (position <= 4) return Colors.green; // Avrupa Kupaları
    if (position >= 16) return Colors.red; // Düşme Hattı
    return Colors.grey[300]!; // Orta sıra
  }
}
