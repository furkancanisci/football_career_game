import 'dart:async';

class AIService {
  final String chatModel = "llama-3.3-70b-versatile";
  
  // Bu fonksiyon Llama 3.3'e gidecek olan promptu simüle eder
  Future<String> getPlayerResponse(String playerName, int ego, String context, String userMessage) async {
    
    // Ağ gecikmesi simülasyonu (Gerçekçilik için)
    await Future.delayed(Duration(seconds: 2));

    // --- BURASI İLERİDE LLAMA API'YE BAĞLANACAK ---
    // Şimdilik basit bir mantık (Rule-based) ile AI taklidi yapıyoruz:

    // Senaryo 1: Yüksek Egolu Oyuncu (Örn: Icardi)
    if (ego > 80) {
      if (userMessage.toLowerCase().contains("özür")) {
        return "Bakarız hocam. Ama bir daha olmasın, taraftar beni sahada görmek istiyor. 😉";
      } else if (userMessage.toLowerCase().contains("taktik")) {
        return "Taktik maktik yok hocam, topu bana atın gol olsun. Bu kadar basit.";
      } else if (userMessage.toLowerCase().contains("neden")) {
        return "Neden mi hocam? Beni yedek mi bıraktınız? Bunu hak etmiyorum.";
      } else {
        return "Hocam şu an pek konuşasım yok. Menajerimle görüşürsünüz.";
      }
    } 
    
    // Senaryo 2: Düşük Egolu / Genç Oyuncu (Örn: Semih)
    else {
      if (userMessage.toLowerCase().contains("aferin")) {
        return "Teşekkürler hocam! Daha çok çalışacağım. 💪";
      } else if (userMessage.toLowerCase().contains("güvendiğim")) {
        return "Sadece size güveniyorum hocam. Sözünüzü yerime getireceğim.";
      } else {
        return "Tamam hocam, siz nasıl derseniz. Formayı kapmak için her şeyi yapacağım.";
      }
    }
  }

  // Bu fonksiyon ileride gerçek API'ye bağlanacak
  Future<String> generatePlayerMessage(String playerName, String mood, String context) async {
    // SİMÜLASYON: Llama 3.3'e şu prompt gidiyor gibi düşün:
    // "Sen [playerName]. Şu an modun [mood]. Olay: [context]. Menajerine kısa, imalı bir mesaj at."
    
    await Future.delayed(Duration(seconds: 1)); // Ağ gecikmesi simülasyonu

    if (mood == "Angry") {
      return "Hocam, dünkü maçta beni 85. dakikada oyuna alman şaka mıydı? Menajerimle konuşacağım.";
    } else if (mood == "Happy") {
      return "Patron! Takım harika gidiyor, moralim tavan. Haftaya formayı bana ver, pişman etmem.";
    } else {
      return "Hocam, antrenman programı biraz ağır mı geldi ne? Bacaklar bitik.";
    }
  }

  // Haber başlığı üretme
  Future<String> generateNewsHeadline(String teamName) async {
    return "$teamName kampında şok! Antrenmanda gergin anlar..."; 
  }
}
