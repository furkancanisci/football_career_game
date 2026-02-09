import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AIService {
  static const String _baseUrl = 'https://api.groq.com/openai/v1/chat/completions';
  
  // Model: Groq üzerinde çalışan Llama-3 (Hızlı ve zeki)
  static const String CHAT_MODEL = "llama-3.3-70b-versatile"; 

  // --- YARDIMCI: GROQ API İSTEĞİ ---
  Future<String> _makeRequest(List<Map<String, dynamic>> messages, {bool jsonMode = false}) async {
    final apiKey = dotenv.env['GROQ_API_KEY'];
    
    if (apiKey == null) {
      return "Hata: API Key bulunamadı (.env dosyasını kontrol et).";
    }

    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode({
          'model': CHAT_MODEL,
          'messages': messages,
          'temperature': 0.7, // Yaratıcılık oranı
          'max_tokens': 1024,
          'response_format': jsonMode ? {'type': 'json_object'} : null, 
        }),
      );

      if (response.statusCode == 200) {
        // UTF8 decoding: Türkçe karakterlerin bozuk gelmesini önler
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        return data['choices'][0]['message']['content'];
      } else {
        print("API Hatası: ${response.body}");
        return "Bağlantı hatası: ${response.statusCode}";
      }
    } catch (e) {
      print("AI Servis Hatası: $e");
      return "Sunucu hatası. Lütfen internet bağlantınızı kontrol edin.";
    }
  }

  // ---------------------------------------------------------------------------
  // 1. OYUNCU SOHBETİ (CHAT SCREEN İÇİN)
  // ---------------------------------------------------------------------------
  Future<String> getPlayerChatResponse(String playerName, int ego, String mood, String context, String userMessage) async {
    final systemPrompt = """
    Sen bir futbol simülasyonunda '$playerName' adlı futbolcusun.
    Kişilik Özelliklerin:
    - Ego Seviyen (0-100): $ego.
    - Ruh Halin: $mood.
    - Güncel Durum: $context.
    
    Teknik Direktörün (kullanıcı) sana bir şey söyledi.
    Kurallar:
    1. Rol yap, AI olduğunu belli etme.
    2. Cevapların kısa ve net olsun (Max 2 cümle).
    3. Ego seviyen 80 üzerindeyse hocaya tepeden bak, 'Patron' de veya hiç hitap etme.
    4. Türkçe konuş.
    """;

    List<Map<String, dynamic>> messages = [
      {"role": "system", "content": systemPrompt},
      {"role": "user", "content": userMessage}
    ];

    return await _makeRequest(messages);
  }

  // ---------------------------------------------------------------------------
  // 2. GÜNLÜK OLAY SİMÜLASYONU (SIMULATION SERVICE İÇİN)
  // ---------------------------------------------------------------------------
  Future<String> generateDailyEventText(String context, String tone) async {
    final systemPrompt = """
    Sen bir futbol simülasyon oyununun 'Hikaye Anlatıcısı'sın.
    Görevin: Verilen bağlama ($context) ve tona ($tone) uygun, 
    gazete manşeti veya kısa kulüp raporu formatında tek cümlelik gerçekçi bir metin üretmek.
    
    Kurallar:
    1. Sadece olayı anlatan metni ver.
    2. Tırnak işareti, başlık etiketi vs. kullanma.
    3. Türkçe ve profesyonel bir dil kullan.
    """;

    List<Map<String, dynamic>> messages = [
      {"role": "system", "content": systemPrompt},
      {"role": "user", "content": "Olayı oluştur."}
    ];

    return await _makeRequest(messages);
  }

  // ---------------------------------------------------------------------------
  // 3. GÜNLÜK HABER AKIŞI (NEWS SCREEN İÇİN) - JSON LİSTE ÇIKTISI
  // ---------------------------------------------------------------------------
  Future<List<Map<String, dynamic>>> generateDailyNewsDigest(String teamName) async {
    final systemPrompt = """
    Sen Türk spor medyasının nabzını tutan bir yapay zekasın.
    Görevin: '$teamName' takımı ve Süper Lig geneli hakkında 5 adet hayali, güncel ve sansasyonel haber üretmek.
    
    Kurallar:
    1. Haberlerin en az 2 tanesi '$teamName' hakkında olsun.
    2. Diğerleri ezeli rakipler veya lig geneli hakkında olabilir.
    3. 'type' alanı şunlardan biri olmalı: 'transfer', 'match', 'crisis', 'interview', 'analysis'.
    4. Yanıtı SADECE geçerli bir JSON Array formatında ver. Başka metin yazma.
    
    JSON Formatı:
    [
      {
        "title": "Haber Başlığı (Çarpıcı)",
        "content": "Haberin detaylı içeriği (Max 2 cümle).",
        "type": "transfer",
        "date": "Bugün"
      }
    ]
    """;

    List<Map<String, dynamic>> messages = [
      {"role": "system", "content": systemPrompt},
      {"role": "user", "content": "Gündemi oluştur."}
    ];

    try {
      // jsonMode: true ile JSON formatını zorluyoruz
      String jsonResponse = await _makeRequest(messages, jsonMode: true);
      
      // Gelen veriyi parse et
      final decoded = jsonDecode(jsonResponse);
      
      // Eğer API direkt liste döndürürse:
      if (decoded is List) {
        return List<Map<String, dynamic>>.from(decoded);
      } 
      // Eğer API { "news": [...] } gibi bir obje döndürürse (Llama bazen bunu yapar):
      else if (decoded is Map && decoded.containsKey('news')) {
        return List<Map<String, dynamic>>.from(decoded['news']);
      } else if (decoded is Map && decoded.containsKey('articles')) {
        return List<Map<String, dynamic>>.from(decoded['articles']);
      }
      
      return [];
    } catch (e) {
      print("Haber Üretme Hatası: $e");
      // Hata durumunda yedek veri
      return [
        {
          "title": "Sistem Hatası",
          "content": "Haber akışı şu an güncellenemiyor.",
          "type": "crisis",
          "date": "Hata"
        }
      ];
    }
  }
}