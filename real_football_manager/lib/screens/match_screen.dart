import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import '../models/team.dart';
import '../models/player.dart';
import 'press_conference_screen.dart';

class MatchScreen extends StatefulWidget {
  final Team homeTeam;
  final Team awayTeam;

  MatchScreen({required this.homeTeam, required this.awayTeam});

  @override
  _MatchScreenState createState() => _MatchScreenState();
}

class _MatchScreenState extends State<MatchScreen> {
  // Maç Durumu
  int homeScore = 0;
  int awayScore = 0;
  int currentMinute = 0;
  bool isPaused = true;
  int speedMultiplier = 1; // 1x, 2x, 4x
  
  // Olay Akışı (Commentary)
  List<Map<String, dynamic>> events = [];
  final ScrollController _scrollController = ScrollController();
  
  Timer? _timer;
  final Random _random = Random();

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  // --- SİMÜLASYON MOTORU ---
  void _toggleMatch() {
    setState(() {
      isPaused = !isPaused;
    });

    if (isPaused) {
      _timer?.cancel();
    } else {
      _startTimer();
    }
  }

  void _changeSpeed(int speed) {
    setState(() {
      speedMultiplier = speed;
    });
    // Hız değişince timer'ı resetle
    if (!isPaused) {
      _timer?.cancel();
      _startTimer();
    }
  }

  void _startTimer() {
    // Hız çarpanına göre süreyi kısaltıyoruz (1x = 1000ms, 4x = 250ms)
    int duration = 1000 ~/ speedMultiplier; 
    
    _timer = Timer.periodic(Duration(milliseconds: duration), (timer) {
      if (currentMinute >= 90) {
        timer.cancel();
        _addEvent("MAÇ SONA ERDİ!", Colors.white, isBold: true);
        setState(() => isPaused = true);
        
        // Maç bitti, basın toplantısına git
        _goToPressConference();
        return;
      }

      setState(() {
        currentMinute++;
        _generateEvent();
      });

      // Otomatik aşağı kaydırma
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  // --- OLAY ÜRETİCİ (RNG + LOGIC) ---
  void _generateEvent() {
    // Her dakika olay olma ihtimali %15 (Daha heyecanlı olsun diye yüksek tuttum)
    if (_random.nextInt(100) > 15) return;

    int eventType = _random.nextInt(100);

    // Olay Tipleri
    // 0-10: GOL
    // 11-30: Şut / Pozisyon
    // 31-40: Kart / Faul
    // 41-50: KAOS / EGO (Real FM Farkı!)
    
    if (eventType < 5) {
      // GOL (Ev Sahibi)
      homeScore++;
      _addEvent("GOOOOL! ${widget.homeTeam.name} öne geçiyor!", Colors.greenAccent, isBold: true);
    } else if (eventType < 10) {
      // GOL (Deplasman)
      awayScore++;
      _addEvent("GOL! ${widget.awayTeam.name} deplasmanda ağları sarstı!", Colors.redAccent, isBold: true);
    } else if (eventType < 40) {
      // Normal Pozisyon
      List<String> commentary = [
        "Orta sahada sert mücadele.",
        "Kaleci harika uzadı!",
        "Direkten döndü! İnanılmaz bir an.",
        "Verkaç denemesi başarısız."
      ];
      _addEvent(commentary[_random.nextInt(commentary.length)], Colors.grey);
    } else if (eventType < 50) {
      // --- REAL FM KAOS ANLARI ---
      // Burası oyuncu karakterine göre şekillenecek
      List<String> chaosCommentary = [
        "Icardi ellerini beline koydu, koşmayı bıraktı. Menajere bakıyor.",
        "Hakem kararına itiraz eden oyuncular etrafını sardı!",
        "Yedek kulübesinde gerginlik var. Su şişesi fırlatıldı.",
        "Kaptan takımı uyarmak yerine rakiple şakalaşıyor."
      ];
      _addEvent(chaosCommentary[_random.nextInt(chaosCommentary.length)], Colors.orangeAccent);
    }
  }

  void _addEvent(String text, Color color, {bool isBold = false}) {
    events.add({
      "min": currentMinute,
      "text": text,
      "color": color,
      "isBold": isBold
    });
  }

  void _goToPressConference() {
    String result;
    if (homeScore > awayScore) {
      result = "Win";
    } else if (homeScore < awayScore) {
      result = "Loss";
    } else {
      result = "Draw";
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => PressConferenceScreen(
          result: result,
          homeScore: homeScore,
          awayScore: awayScore,
        ),
      ),
    );
  }

  // --- UI KISMI ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF0A0E12),
      appBar: AppBar(
        backgroundColor: Color(0xFF161B22),
        title: Text("CANLI ANLATIM", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back), 
          onPressed: () => Navigator.pop(context), // Maçtan çıkma (Lucien Favre stili kaçış :D)
        ),
      ),
      body: Column(
        children: [
          // 1. SKORBORD
          Container(
            padding: EdgeInsets.symmetric(vertical: 24, horizontal: 16),
            decoration: BoxDecoration(
              color: Color(0xFF1E252F),
              boxShadow: [BoxShadow(color: Colors.black54, blurRadius: 10, offset: Offset(0, 5))],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Ev Sahibi
                Expanded(child: _buildTeamInfo(widget.homeTeam.name, true)),
                
                // Skor ve Dakika
                Column(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.white10),
                      ),
                      child: Text(
                        "$homeScore - $awayScore",
                        style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold, letterSpacing: 2),
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      "$currentMinute'",
                      style: TextStyle(color: Colors.greenAccent, fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                
                // Deplasman
                Expanded(child: _buildTeamInfo(widget.awayTeam.name, false)),
              ],
            ),
          ),

          // 2. İSTATİSTİK ÇUBUĞU (Possession Bar)
          Container(
            height: 6,
            child: Row(
              children: [
                Expanded(flex: 55, child: Container(color: Colors.blue[800])), // Ev sahibi %55
                Expanded(flex: 45, child: Container(color: Colors.red[800])),  // Deplasman %45
              ],
            ),
          ),

          // 3. MAÇ AKIŞI (Canlı Anlatım)
          Expanded(
            child: Container(
              color: Color(0xFF121212),
              child: ListView.builder(
                controller: _scrollController,
                padding: EdgeInsets.all(16),
                itemCount: events.length,
                itemBuilder: (context, index) {
                  final event = events[index];
                  return Padding(
                    padding: EdgeInsets.only(bottom: 12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 30,
                          child: Text(
                            "${event['min']}'",
                            style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.bold),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            event['text'],
                            style: TextStyle(
                              color: event['color'],
                              fontWeight: event['isBold'] ? FontWeight.bold : FontWeight.normal,
                              fontSize: event['isBold'] ? 15 : 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),

          // 4. KONTROL PANELİ (Hız ve Pause)
          Container(
            padding: EdgeInsets.all(16),
            color: Color(0xFF161B22),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildSpeedButton(1),
                SizedBox(width: 12),
                _buildSpeedButton(2),
                SizedBox(width: 12),
                _buildSpeedButton(4),
                SizedBox(width: 30),
                FloatingActionButton(
                  backgroundColor: isPaused ? Colors.green : Colors.orange,
                  onPressed: _toggleMatch,
                  child: Icon(isPaused ? Icons.play_arrow : Icons.pause),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTeamInfo(String name, bool isHome) {
    return Column(
      children: [
        CircleAvatar(
          radius: 24,
          backgroundColor: isHome ? Colors.blue[900] : Colors.red[900],
          child: Text(name[0], style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20)),
        ),
        SizedBox(height: 8),
        Text(
          name,
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildSpeedButton(int speed) {
    bool isActive = speedMultiplier == speed;
    return GestureDetector(
      onTap: () => _changeSpeed(speed),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: isActive ? Colors.blueAccent : Colors.transparent,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.blueAccent),
        ),
        child: Center(
          child: Text(
            "${speed}x",
            style: TextStyle(color: isActive ? Colors.white : Colors.blueAccent, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
