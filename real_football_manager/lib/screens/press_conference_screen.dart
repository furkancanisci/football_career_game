import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import '../services/ai_service.dart'; // AI Servisini import et

class PressConferenceScreen extends StatefulWidget {
  final String result; // "Win", "Loss", "Draw"
  final int homeScore;
  final int awayScore;

  PressConferenceScreen({required this.result, required this.homeScore, required this.awayScore});

  @override
  _PressConferenceScreenState createState() => _PressConferenceScreenState();
}

class _PressConferenceScreenState extends State<PressConferenceScreen> {
  final AIService _aiService = AIService();
  
  // AI'dan gelecek veriyi beklerken loading göstereceğiz
  bool isLoading = true;
  Map<String, dynamic>? currentQuestion;
  
  // Etkiler
  double boardTrust = 50;
  double mediaLove = 50;
  
  // Efektler
  bool showFlash = false;
  Timer? flashTimer;

  @override
  void initState() {
    super.initState();
    _fetchAIQuestion();
    _startFlashEffect();
  }

  // --- REAL AI ENTEGRASYONU ---
  Future<void> _fetchAIQuestion() async {
    try {
      // Llama 3.3'e maçı anlatıp soru istiyoruz
      final questionData = await _aiService.generatePressQuestion(
        widget.result, 
        widget.homeScore, 
        widget.awayScore
      );

      if (mounted) {
        setState(() {
          currentQuestion = questionData;
          isLoading = false;
        });
      }
    } catch (e) {
      print("AI Hatası: $e");
    }
  }

  void _startFlashEffect() {
    flashTimer = Timer.periodic(Duration(milliseconds: 1500), (timer) {
      if (Random().nextBool()) {
        if (mounted) {
          setState(() => showFlash = true);
          Future.delayed(Duration(milliseconds: 100), () {
            if (mounted) setState(() => showFlash = false);
          });
        }
      }
    });
  }

  @override
  void dispose() {
    flashTimer?.cancel();
    super.dispose();
  }

  void _answerQuestion(Map<String, dynamic> answer) {
    // Etkileri uygula (API'den gelen int değerler)
    setState(() {
      boardTrust += (answer['board_effect'] as num).toDouble();
      mediaLove += (answer['media_effect'] as num).toDouble();
      _showHeadlineDialog();
    });
  }

  void _showHeadlineDialog() {
    flashTimer?.cancel();
    
    // Basit bir manşet mantığı (İstersen burayı da AI'ya yazdırabiliriz)
    String headline = widget.result == "Loss" 
        ? "HOCA TERLEDİ!" 
        : "ZAFER SARHOŞLUĞU!";
        
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        title: Text("YARININ MANŞETİ", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(border: Border.all(color: Colors.black, width: 3)),
              child: Column(
                children: [
                  Text("FUTBOL GAZETESİ", style: TextStyle(color: Colors.red, fontWeight: FontWeight.w900)),
                  Divider(color: Colors.black),
                  Text(headline, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                ],
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
            onPressed: () {
              Navigator.pop(ctx); 
              Navigator.pop(context); // Maçtan çık
            },
            child: Text("Tamam", style: TextStyle(color: Colors.white)),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1A1F26),
      body: Stack(
        children: [
          // Flaş Efekti
          if (showFlash) Positioned.fill(child: Container(color: Colors.white.withOpacity(0.1))),

          SafeArea(
            child: isLoading 
            ? Center(child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Colors.white),
                  SizedBox(height: 10),
                  Text("Gazeteciler yerini alıyor...", style: TextStyle(color: Colors.white54))
                ],
              ))
            : Column(
              children: [
                // 1. GAZETECİ ALANI
                Expanded(
                  flex: 4,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          radius: 40,
                          backgroundColor: Colors.grey[800],
                          child: Icon(Icons.mic, size: 40, color: Colors.white),
                        ),
                        SizedBox(height: 16),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          color: Colors.red[900],
                          child: Text(
                            currentQuestion!['media'].toString().toUpperCase(), 
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(currentQuestion!['journalist'], style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic)),
                        SizedBox(height: 24),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 24),
                          child: Text(
                            "\"${currentQuestion!['text']}\"",
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold, height: 1.3),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // 2. CEVAP SEÇENEKLERİ
                Expanded(
                  flex: 3,
                  child: Container(
                    padding: EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Color(0xFF0A0E12),
                      borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                    ),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text("CEVABINIZ:", style: TextStyle(color: Colors.grey, fontSize: 12, letterSpacing: 2)),
                          SizedBox(height: 16),
                          // API'den gelen cevap listesini döngüye sokuyoruz
                          ...(currentQuestion!['answers'] as List).map((ans) {
                            return Padding(
                              padding: EdgeInsets.only(bottom: 12),
                              child: InkWell(
                                onTap: () => _answerQuestion(ans),
                                child: Container(
                                  padding: EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.blueGrey),
                                    borderRadius: BorderRadius.circular(12),
                                    color: Colors.blueGrey.withOpacity(0.1),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(Icons.chat_bubble_outline, color: Colors.white70, size: 20),
                                      SizedBox(width: 12),
                                      Expanded(
                                        child: Text(ans['text'], style: TextStyle(color: Colors.white, fontSize: 14)),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
