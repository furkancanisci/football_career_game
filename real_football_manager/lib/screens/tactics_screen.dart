import 'package:flutter/material.dart';
// Projenin gerçek dosya yolları:
import '../models/player.dart';
import '../models/team.dart'; 
import '../models/club.dart'; // Eğer Club kullanıyorsan
import '../services/data_service.dart'; // Veya game_data_service.dart

class TacticsScreen extends StatefulWidget {
  const TacticsScreen({Key? key}) : super(key: key);

  @override
  _TacticsScreenState createState() => _TacticsScreenState();
}

class _TacticsScreenState extends State<TacticsScreen> {
  // 11 Kişilik Kadro (null olabilir, boş koltuk demek)
  List<Player?> startingXI = List.filled(11, null);
  List<Player> subs = [];
  
  String currentFormation = "4-2-3-1";
  double teamChemistry = 0.0;
  bool isLoading = true;

  // Formasyon Koordinatları (Dikey Saha: X=0 sol, X=1 sağ, Y=0 üst/rakip, Y=1 alt/kalemiz)
  // GK her zaman index 0
  final Map<String, List<Alignment>> formations = {
    "4-2-3-1": [
      Alignment(0.0, 0.9),  // GK
      Alignment(-0.8, 0.7), // LB
      Alignment(-0.3, 0.75),// CB
      Alignment(0.3, 0.75), // CB
      Alignment(0.8, 0.7),  // RB
      Alignment(-0.35, 0.4),// CDM
      Alignment(0.35, 0.4), // CDM
      Alignment(-0.8, 0.15),// LW
      Alignment(0.0, 0.25), // CAM
      Alignment(0.8, 0.15), // RW
      Alignment(0.0, -0.1), // ST
    ],
    "4-4-2": [
      Alignment(0.0, 0.9),  // GK
      Alignment(-0.8, 0.7), // LB
      Alignment(-0.3, 0.75),// CB
      Alignment(0.3, 0.75), // CB
      Alignment(0.8, 0.7),  // RB
      Alignment(-0.8, 0.3), // LM
      Alignment(-0.25, 0.4),// CM
      Alignment(0.25, 0.4), // CM
      Alignment(0.8, 0.3),  // RM
      Alignment(-0.25, -0.1),// ST
      Alignment(0.25, -0.1), // ST
    ],
    "4-3-3": [
      Alignment(0.0, 0.9),  // GK
      Alignment(-0.8, 0.7), // LB
      Alignment(-0.3, 0.75),// CB
      Alignment(0.3, 0.75), // CB
      Alignment(0.8, 0.7),  // RB
      Alignment(0.0, 0.5),  // CDM
      Alignment(-0.4, 0.3), // CM
      Alignment(0.4, 0.3),  // CM
      Alignment(-0.8, -0.05),// LW
      Alignment(0.8, -0.05), // RW
      Alignment(0.0, -0.1), // ST
    ]
  };

  @override
  void initState() {
    super.initState();
    _loadSquad();
  }

  // GERÇEK VERİ SERVİSİNDEN YÜKLEME
  Future<void> _loadSquad() async {
    // DataService'den seçili takımı alıyoruz (Club veya Team modeline göre ayarla)
    var selectedTeam = DataService.getSelectedTeam(); 
    
    if (selectedTeam != null) {
      try {
        // Eğer DataService.getTeamSquad asenkron ise await kullan
        List<Player> allPlayers = await DataService.getTeamSquad(selectedTeam.id);
        
        setState(() {
          // İlk 11'i doldur (Eğer yeterli oyuncu varsa)
          for(int i = 0; i < 11; i++) {
            if (i < allPlayers.length) {
              startingXI[i] = allPlayers[i];
            }
          }
          // Kalanları yedeğe at
          if (allPlayers.length > 11) {
            subs = allPlayers.sublist(11);
          }
          
          _calculateChemistry();
          isLoading = false;
        });
      } catch (e) {
        debugPrint("Kadro yüklenirken hata: $e");
        setState(() => isLoading = false);
      }
    } else {
       setState(() => isLoading = false);
    }
  }

  void _calculateChemistry() {
    // Basit mantık: Oyuncu sayısı ve skill ortalaması (Player modelinde 'skill' veya 'overall' ne ise onu kullan)
    double total = 0;
    int count = 0;
    for(var p in startingXI) {
      if(p != null) { 
        total += p.skill; // Player modelinde 'skill' alanı olduğunu varsayıyorum
        count++; 
      }
    }
    setState(() {
      teamChemistry = count == 11 ? (total / 11) : 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E12),
      appBar: AppBar(
        backgroundColor: const Color(0xFF161B22),
        elevation: 0,
        title: const Text("TAKTİK TAHTASI", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.0, color: Colors.white)),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
           // Formasyon Seçici
           Theme(
             data: Theme.of(context).copyWith(canvasColor: const Color(0xFF1E252F)),
             child: DropdownButtonHideUnderline(
               child: DropdownButton<String>(
                value: currentFormation,
                icon: const Icon(Icons.arrow_drop_down, color: Colors.greenAccent),
                style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                items: formations.keys.map((String value) {
                  return DropdownMenuItem<String>(value: value, child: Text(value));
                }).toList(),
                onChanged: (val) => setState(() => currentFormation = val!),
               ),
             ),
           ),
           const SizedBox(width: 12),
        ],
      ),
      body: isLoading 
        ? const Center(child: CircularProgressIndicator(color: Colors.green))
        : Column(
        children: [
          // 1. ÜST BİLGİ BAR (Kimya & Güç)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            color: const Color(0xFF151920),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("TAKIM GÜCÜ", style: TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold)),
                          Text("${teamChemistry.toStringAsFixed(0)}", style: const TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold, fontSize: 14)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(2),
                        child: LinearProgressIndicator(
                          value: teamChemistry / 100,
                          backgroundColor: Colors.white10,
                          color: _getChemistryColor(teamChemistry),
                          minHeight: 4,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 20),
                // Taktik Mentalite
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.blueAccent.withOpacity(0.5)),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text("HÜCUM AĞIRLIKLI", style: TextStyle(color: Colors.blueAccent, fontSize: 10, fontWeight: FontWeight.bold)),
                )
              ],
            ),
          ),

          // 2. DİKEY SAHA (Vertical Pitch)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  double w = constraints.maxWidth;
                  double h = constraints.maxHeight;
                  
                  return Container(
                    width: w,
                    height: h,
                    decoration: BoxDecoration(
                      color: const Color(0xFF2E7D32),
                      borderRadius: BorderRadius.circular(8),
                      // Dikey Çim Deseni
                      gradient: const LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        stops: [0.1, 0.1, 0.2, 0.2, 0.3, 0.3, 0.4, 0.4, 0.5, 0.5, 0.6, 0.6, 0.7, 0.7, 0.8, 0.8, 0.9, 0.9],
                        colors: [
                          Color(0xFF2E7D32), Color(0xFF286E2C),
                          Color(0xFF2E7D32), Color(0xFF286E2C),
                          Color(0xFF2E7D32), Color(0xFF286E2C),
                          Color(0xFF2E7D32), Color(0xFF286E2C),
                          Color(0xFF2E7D32), Color(0xFF286E2C),
                          Color(0xFF2E7D32), Color(0xFF286E2C),
                          Color(0xFF2E7D32), Color(0xFF286E2C),
                          Color(0xFF2E7D32), Color(0xFF286E2C),
                          Color(0xFF2E7D32), Color(0xFF286E2C),
                        ],
                      ),
                      border: Border.all(color: Colors.white24, width: 3),
                      boxShadow: const [BoxShadow(color: Colors.black54, blurRadius: 10, offset: Offset(0, 5))],
                    ),
                    child: Stack(
                      children: [
                        // Saha Çizgileri
                        _buildPitchLines(),
                        
                        // OYUNCULAR (11 Kişi)
                        ...List.generate(11, (index) {
                          final align = formations[currentFormation]![index];
                          final player = startingXI[index];

                          return AnimatedAlign(
                            duration: const Duration(milliseconds: 400),
                            curve: Curves.easeInOut,
                            alignment: align,
                            child: DragTarget<Player>(
                              onWillAccept: (data) => true,
                              onAccept: (droppedPlayer) {
                                setState(() {
                                  // Yedekten geldiyse:
                                  if (subs.contains(droppedPlayer)) {
                                    subs.remove(droppedPlayer);
                                    if (startingXI[index] != null) subs.add(startingXI[index]!); // Eskiyi yedeğe at
                                    startingXI[index] = droppedPlayer;
                                  } 
                                  // Saha içindeyse (Swap):
                                  else if (startingXI.contains(droppedPlayer)) {
                                    int oldIndex = startingXI.indexOf(droppedPlayer);
                                    startingXI[oldIndex] = startingXI[index];
                                    startingXI[index] = droppedPlayer;
                                  }
                                  _calculateChemistry();
                                });
                              },
                              builder: (context, candidateData, rejectedData) {
                                return _buildDraggablePitchPlayer(player, index);
                              },
                            ),
                          );
                        }),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),

          // 3. YEDEKLER (Draggable List)
          Container(
            height: 90, 
            color: const Color(0xFF161B22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(left: 12, top: 8, bottom: 4),
                  child: Text("YEDEKLER", style: TextStyle(color: Colors.white54, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
                ),
                Expanded(
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    itemCount: subs.length,
                    itemBuilder: (context, index) {
                      final player = subs[index];
                      return Draggable<Player>(
                        data: player,
                        feedback: _buildPlayerToken(player, scale: 1.1), 
                        childWhenDragging: Opacity(opacity: 0.3, child: _buildSubItem(player)),
                        child: _buildSubItem(player),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- WIDGET HELPERLAR ---

  // Saha Çizgileri
  Widget _buildPitchLines() {
    return Stack(
      children: [
        // Orta Çizgi
        Center(child: Container(width: double.infinity, height: 2, color: Colors.white24)),
        // Orta Yuvarlak
        Center(child: Container(width: 80, height: 80, decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.white24, width: 2)))),
        // Ceza Sahası (Üst - Rakip)
        Align(alignment: Alignment.topCenter, child: Container(width: 150, height: 60, decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.white24, width: 2), left: BorderSide(color: Colors.white24, width: 2), right: BorderSide(color: Colors.white24, width: 2))))),
        // Ceza Sahası (Alt - Bizim)
        Align(alignment: Alignment.bottomCenter, child: Container(width: 150, height: 60, decoration: BoxDecoration(border: Border(top: BorderSide(color: Colors.white24, width: 2), left: BorderSide(color: Colors.white24, width: 2), right: BorderSide(color: Colors.white24, width: 2))))),
      ],
    );
  }

  // Saha İçindeki Oyuncu
  Widget _buildDraggablePitchPlayer(Player? player, int index) {
    if (player == null) {
      return Container(
        width: 30, height: 30,
        decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.white24, width: 2), color: Colors.black12),
      );
    }
    
    return Draggable<Player>(
      data: player,
      feedback: _buildPlayerToken(player, scale: 1.1),
      childWhenDragging: Opacity(opacity: 0.3, child: _buildPlayerToken(player)),
      child: _buildPlayerToken(player),
    );
  }

  // Oyuncu Simgesi (Token)
  Widget _buildPlayerToken(Player player, {double scale = 1.0}) {
    // Modelinde skill veya overall hangisi varsa onu kullan
    int skillVal = player.skill; 
    
    Color ringColor = skillVal >= 85 ? Colors.amber : (skillVal >= 80 ? Colors.green : Colors.grey);
    
    return Transform.scale(
      scale: scale,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 32, 
            height: 32,
            decoration: BoxDecoration(
              color: const Color(0xFF1E252F),
              shape: BoxShape.circle,
              border: Border.all(color: ringColor, width: 2),
              boxShadow: const [BoxShadow(color: Colors.black45, blurRadius: 4)],
            ),
            child: Center(
              child: Text(
                "$skillVal",
                style: TextStyle(color: ringColor, fontWeight: FontWeight.bold, fontSize: 11),
              ),
            ),
          ),
          const SizedBox(height: 2),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.6),
              borderRadius: BorderRadius.circular(4)
            ),
            child: Text(
              player.name, 
              style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
              maxLines: 1, 
              overflow: TextOverflow.ellipsis
            ),
          )
        ],
      ),
    );
  }

  // Yedek Kulübesi Kartı
  Widget _buildSubItem(Player player) {
    int skillVal = player.skill;

    return Container(
      width: 50,
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF1E252F),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 24, height: 24,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.black26,
              border: Border.all(color: _getOverallColor(skillVal), width: 1.5)
            ),
            child: Text("$skillVal", style: TextStyle(color: _getOverallColor(skillVal), fontSize: 9, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 4),
          Text(player.name, style: const TextStyle(color: Colors.white70, fontSize: 8), maxLines: 1, overflow: TextOverflow.ellipsis),
          Text(player.position, style: const TextStyle(color: Colors.blueGrey, fontSize: 7, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Color _getOverallColor(int ovr) {
    if(ovr >= 85) return Colors.amber;
    if(ovr >= 80) return Colors.green;
    return Colors.white54;
  }

  Color _getChemistryColor(double val) {
    if(val >= 80) return Colors.greenAccent;
    if(val >= 50) return Colors.amber;
    return Colors.redAccent;
  }
}