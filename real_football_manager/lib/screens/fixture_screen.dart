import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class FixtureScreen extends StatefulWidget {
  const FixtureScreen({Key? key}) : super(key: key);

  @override
  State<FixtureScreen> createState() => _FixtureScreenState();
}

class _FixtureScreenState extends State<FixtureScreen> {
  List<Map<String, dynamic>> fixtureData = [];
  int currentWeekIndex = 0;
  bool isLoading = true;

  // Takım ID'lerinden isimlere çevirme map'i
  final Map<String, String> teamNames = {
    'GS': 'Galatasaray',
    'FB': 'Fenerbahçe',
    'BJK': 'Beşiktaş',
    'TS': 'Trabzonspor',
    'EYUP': 'Eyüpspor',
    'IBFK': 'Başakşehir',
    'GOZ': 'Göztepe',
    'SAM': 'Samsunspor',
    'ANT': 'Antalyaspor',
    'KON': 'Konyaspor',
    'ALA': 'Alanyaspor',
    'RIZ': 'Rizespor',
    'KAY': 'Kayserispor',
    'BOD': 'Bodrumspor',
    'ADS': 'Adana Demirspor',
    'HAT': 'Hatayspor',
    'GAZ': 'Gaziantep FK',
    'SIV': 'Sivasspor',
    'KAS': 'Kasımpaşa'
  };

  @override
  void initState() {
    super.initState();
    loadFixtureData();
  }

  Future<void> loadFixtureData() async {
    try {
      final String jsonString = await rootBundle.loadString('assets/data/fixture_data.json');
      final List<dynamic> jsonList = json.decode(jsonString);

      setState(() {
        fixtureData = jsonList.cast<Map<String, dynamic>>();
        isLoading = false;
      });
    } catch (e) {
      debugPrint('Fikstür verisi yüklenirken hata: $e');
      setState(() => isLoading = false);
    }
  }

  void changeWeek(int direction) {
    final newIndex = currentWeekIndex + direction;
    if (newIndex >= 0 && newIndex < fixtureData.length) {
      setState(() => currentWeekIndex = newIndex);
    }
  }

  void simulateWeek() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Hafta ${currentWeekIndex + 1} simüle ediliyor...'),
        backgroundColor: Colors.green[700],
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // Takım rengini belirleyen basit bir yardımcı fonksiyon
  Color _getTeamColor(String teamId) {
    if (['GS', 'KAY', 'GOZ'].contains(teamId)) return Colors.red;
    if (['FB', 'ADS', 'KAS'].contains(teamId)) return Colors.blue[800]!;
    if (['BJK', 'ALT'].contains(teamId)) return Colors.white; // Siyah arka planda beyaz
    if (['TS', 'RIZ'].contains(teamId)) return Colors.blueAccent;
    if (['KON', 'BOD', 'SAK'].contains(teamId)) return Colors.green;
    return Colors.grey;
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFF0A0E12),
        body: Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.green))),
      );
    }

    if (fixtureData.isEmpty) {
      return Scaffold(
        backgroundColor: const Color(0xFF0A0E12),
        appBar: AppBar(backgroundColor: Colors.transparent, iconTheme: const IconThemeData(color: Colors.white)),
        body: const Center(child: Text('Fikstür bulunamadı', style: TextStyle(color: Colors.white))),
      );
    }

    final weekData = fixtureData[currentWeekIndex];
    final byeTeamKey = weekData['bye_team'];
    final byeTeam = (byeTeamKey != null && teamNames.containsKey(byeTeamKey)) ? teamNames[byeTeamKey]! : null;
    final matches = List<Map<String, dynamic>>.from(weekData['matches']);

    return Scaffold(
      backgroundColor: const Color(0xFF0A0E12),
      body: SafeArea(
        child: Column(
          children: [
            // --- KOMPAKT HEADER ---
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
              decoration: const BoxDecoration(
                color: Color(0xFF151920),
                border: Border(bottom: BorderSide(color: Colors.white10)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  
                  // Hafta Seçici (Ortada)
                  Row(
                    children: [
                      IconButton(
                        onPressed: currentWeekIndex > 0 ? () => changeWeek(-1) : null,
                        icon: Icon(Icons.chevron_left, color: currentWeekIndex > 0 ? Colors.white : Colors.white24),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 12),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF059669).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFF059669).withOpacity(0.5)),
                        ),
                        child: Text(
                          'HAFTA ${weekData['week']}',
                          style: const TextStyle(color: Color(0xFF34D399), fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 1),
                        ),
                      ),
                      IconButton(
                        onPressed: currentWeekIndex < fixtureData.length - 1 ? () => changeWeek(1) : null,
                        icon: Icon(Icons.chevron_right, color: currentWeekIndex < fixtureData.length - 1 ? Colors.white : Colors.white24),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                  
                  // Dengelemek için boşluk
                  const SizedBox(width: 20),
                ],
              ),
            ),

            // --- BAY GEÇEN TAKIM (İnce Banner) ---
            if (byeTeam != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 6),
                color: Colors.amber.withOpacity(0.1),
                child: Text(
                  'BAY GEÇEN: $byeTeam',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.amber, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1),
                ),
              ),

            // --- MAÇ LİSTESİ (LISTVIEW) ---
            Expanded(
              child: ListView.separated(
                padding: EdgeInsets.zero,
                itemCount: matches.length,
                separatorBuilder: (context, index) => const Divider(height: 1, color: Colors.white10),
                itemBuilder: (context, index) {
                  final match = matches[index];
                  final homeId = match['home'];
                  final awayId = match['away'];
                  final homeName = teamNames[homeId] ?? homeId;
                  final awayName = teamNames[awayId] ?? awayId;
                  final score = match['score'];
                  final time = match['time'] ?? 'VS';

                  return Container(
                    color: const Color(0xFF0A0E12), // Arka plan
                    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                    child: Row(
                      children: [
                        // EV SAHİBİ (Sağa dayalı text)
                        Expanded(
                          flex: 4,
                          child: Text(
                            homeName,
                            textAlign: TextAlign.right,
                            style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        
                        // EV SAHİBİ LOGO (Küçük daire)
                        const SizedBox(width: 8),
                        _buildTeamAvatar(homeId),

                        // SKOR / SAAT (Ortada)
                        Container(
                          width: 50,
                          alignment: Alignment.center,
                          margin: const EdgeInsets.symmetric(horizontal: 8),
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          decoration: BoxDecoration(
                            color: score != null ? Colors.transparent : Colors.grey[900],
                            borderRadius: BorderRadius.circular(4),
                            border: score != null ? null : Border.all(color: Colors.white10),
                          ),
                          child: Text(
                            score ?? time,
                            style: TextStyle(
                              color: score != null ? Colors.white : Colors.greenAccent,
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),

                        // DEPLASMAN LOGO
                        _buildTeamAvatar(awayId),
                        const SizedBox(width: 8),

                        // DEPLASMAN (Sola dayalı text)
                        Expanded(
                          flex: 4,
                          child: Text(
                            awayName,
                            textAlign: TextAlign.left,
                            style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // --- ALT BAR (BUTON) ---
            Container(
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(
                color: Color(0xFF151920),
                border: Border(top: BorderSide(color: Colors.white10)),
              ),
              child: SizedBox(
                width: double.infinity,
                height: 44, // Daha ince buton
                child: ElevatedButton(
                  onPressed: simulateWeek,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF059669),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    elevation: 0,
                  ),
                  child: const Text(
                    'HAFTAYI SİMÜLE ET',
                    style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Takım logosu yerine geçen küçük renkli daire
  Widget _buildTeamAvatar(String teamId) {
    return Container(
      width: 24,
      height: 24,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: _getTeamColor(teamId).withOpacity(0.2),
        shape: BoxShape.circle,
        border: Border.all(color: _getTeamColor(teamId).withOpacity(0.6), width: 1),
      ),
      child: Text(
        teamId.substring(0, 1), // İlk harf
        style: TextStyle(color: _getTeamColor(teamId), fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }
}