import 'package:flutter/material.dart';
import '../models/player.dart';
import 'chat_screen.dart'; // ChatScreen import edildi

class PlayerDetailScreen extends StatelessWidget {
  final Player player;

  const PlayerDetailScreen({Key? key, required this.player}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Color accentColor = _getSkillColor(player.skill);
    final Color cardColor = const Color(0xFF1A1F26);

    return Scaffold(
      backgroundColor: const Color(0xFF0F1318),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F1318),
        elevation: 0,
        toolbarHeight: 40,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white70, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(player.name.toUpperCase(), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Column(
          children: [
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // SOL SÜTUN: KİMLİK
                  Expanded(
                    flex: 4,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [cardColor, cardColor.withOpacity(0.8)]),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: accentColor.withOpacity(0.3)),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 70, height: 70, alignment: Alignment.center,
                            decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: accentColor, width: 3), color: Colors.black26),
                            child: Text("${player.skill}", style: TextStyle(color: accentColor, fontSize: 28, fontWeight: FontWeight.bold)),
                          ),
                          const SizedBox(height: 12),
                          Text(player.position, style: TextStyle(color: accentColor, fontSize: 16, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Text(player.name.split(" ").last, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900), maxLines: 1, overflow: TextOverflow.ellipsis),
                          const SizedBox(height: 4),
                          Text("${player.age} Yaş", style: TextStyle(color: Colors.grey[400], fontSize: 10)),
                          const Divider(color: Colors.white10, height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _buildMiniStatus(Icons.trending_up, "Form", "7.8", Colors.green),
                              _buildMiniStatus(Icons.sentiment_satisfied, "Moral", "İyi", Colors.blue),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // SAĞ SÜTUN: VERİLER
                  Expanded(
                    flex: 6,
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(12)),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text("TEKNİK", style: TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
                              const SizedBox(height: 8),
                              _buildStatRowCompact("Hız", 85, "Dribling", 82),
                              _buildStatRowCompact("Şut", 88, "Defans", 45),
                              _buildStatRowCompact("Pas", 76, "Fizik", 78),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(12)),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text("MENTAL", style: TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
                                const SizedBox(height: 8),
                                _buildMentalBar("Ego", player.ego, Colors.purpleAccent),
                                _buildMentalBar("Hırs", player.ambition, Colors.orangeAccent),
                                _buildMentalBar("Disiplin", player.discipline, Colors.blueAccent),
                                _buildMentalBar("Sadakat", player.loyalty, Colors.greenAccent),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Container(
              height: 60,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white10)),
              child: Row(
                children: [
                  Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text("Değer", style: TextStyle(color: Colors.grey[500], fontSize: 9)),
                    const Text("18.5 M€", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                  ]),
                  const SizedBox(width: 20),
                  Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text("Sözleşme", style: TextStyle(color: Colors.grey[500], fontSize: 9)),
                    const Text("2027", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                  ]),
                  const Spacer(),
                  // CHAT BUTONU
                  IconButton(
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ChatScreen(player: player))),
                    icon: const Icon(Icons.chat_bubble, color: Colors.blueAccent),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(backgroundColor: accentColor, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)), padding: const EdgeInsets.symmetric(horizontal: 16), minimumSize: const Size(0, 36)),
                    child: const Text("TEKLİF YAP", style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper Widgets
  Widget _buildMiniStatus(IconData icon, String label, String value, Color color) {
    return Column(children: [Icon(icon, color: color, size: 18), const SizedBox(height: 2), Text(value, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12)), Text(label, style: TextStyle(color: Colors.grey[500], fontSize: 9))]);
  }
  Widget _buildStatRowCompact(String label1, int val1, String label2, int val2) {
    return Padding(padding: const EdgeInsets.only(bottom: 8.0), child: Row(children: [_buildSingleStat(label1, val1), const SizedBox(width: 12), Container(width: 1, height: 20, color: Colors.white10), const SizedBox(width: 12), _buildSingleStat(label2, val2)]));
  }
  Widget _buildSingleStat(String label, int val) {
    Color color = val >= 80 ? Colors.greenAccent : (val >= 60 ? Colors.white : Colors.orange);
    return Expanded(child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(label, style: const TextStyle(color: Colors.white70, fontSize: 11)), Text("$val", style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 13))]));
  }
  Widget _buildMentalBar(String label, int value, Color color) {
    return Padding(padding: const EdgeInsets.only(bottom: 8.0), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(label, style: const TextStyle(color: Colors.white70, fontSize: 10)), Text("$value", style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold))]), const SizedBox(height: 3), ClipRRect(borderRadius: BorderRadius.circular(2), child: LinearProgressIndicator(value: value / 100, backgroundColor: Colors.white10, color: color, minHeight: 4))]));
  }
  Color _getSkillColor(int skill) {
    if (skill >= 85) return const Color(0xFFDC2626);
    if (skill >= 75) return const Color(0xFFD97706);
    if (skill >= 65) return const Color(0xFF2563EB);
    return const Color(0xFF10B981);
  }
}