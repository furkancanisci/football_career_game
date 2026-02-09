import 'dart:math';
import '../models/game_state.dart';
import '../models/club.dart';
import 'ai_service.dart';

class SimulationService {
  final AIService _aiService = AIService();
  final Random _rng = Random();

  // Simülasyonun Ana Fonksiyonu
  Future<Map<String, dynamic>> simulateDay(GameState currentState, Club club) async {
    List<String> dailyNews = [];
    List<Email> dailyEmails = [];
    Map<String, dynamic> statChanges = {};

    // 1. Olasılık Hesaplamaları (Zar Atma)
    int chaosRoll = _rng.nextInt(100); // 0-99 arası şans
    int teamMorale = currentState.teamStats['morale'] ?? 80;

    // 2. Senaryo Üretimi
    if (chaosRoll < 10) {
      // %10 Şans: KÖTÜ BİR OLAY (Sakatlık veya Kavga)
      String prompt = "Futbol takımında antrenmanda yaşanan küçük bir kriz veya sakatlık haberi yaz. Kısa ve net olsun.";
      String aiText = await _aiService.generateDailyEventText(prompt, "Kriz");
      
      dailyNews.add("SON DAKİKA: $aiText");
      dailyEmails.add(Email("Sağlık Heyeti Raporu", "$aiText Lütfen kadroyu kontrol edin.", true));
      statChanges['morale'] = teamMorale - 5;
      
    } else if (chaosRoll > 85) {
      // %15 Şans: İYİ BİR OLAY (Sponsor veya Form)
      String prompt = "Futbol takımında moral yükselten güzel bir gelişme (sponsor veya oyuncu performansı) yaz. Kısa olsun.";
      String aiText = await _aiService.generateDailyEventText(prompt, "Pozitif");

      dailyNews.add(aiText);
      statChanges['morale'] = teamMorale + 3;
      
    } else {
      // %75 Şans: SIRADAN GÜN
      dailyNews.add("Takım günü taktik antrenmanla tamamladı.");
      // Enerji yenilenmesi
      int currentEnergy = currentState.teamStats['energy'] ?? 90;
      statChanges['energy'] = (currentEnergy + 5).clamp(0, 100); 
    }

    // 3. AI ile Dinamik Basın (Rastgele bir gazeteci yorumu)
    if (chaosRoll % 5 == 0) { // Her 5 günde bir
      String rumor = await _aiService.generateDailyEventText("Takım hakkında bir transfer dedikodusu veya taktik eleştirisi uydur.", "Medya");
      dailyNews.add("MEDYA KULİSİ: $rumor");
    }

    return {
      'news': dailyNews,
      'emails': dailyEmails,
      'stats': statChanges,
    };
  }
}