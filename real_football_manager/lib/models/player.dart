class Player {
  final String id;
  final String name;
  final String team;
  final int age;
  final String position;
  final String role;
  final int jerseyNumber;
  
  // Teknik Özellikler (0-100)
  int skill; // Yeni: overall yerine skill kullanıyoruz
  int fitness; // Kondisyon
  
  // Psikolojik & Kaos Özellikleri (0-100) - Oyunun Farkı Burada!
  int ego;         // Yüksekse yedek Kalınca sorun çıkarır.
  int ambition;    // Yüksekse sürekli büyük kulübe gitmek ister.
  int discipline;  // Düşükse antrenmanı kaçırabilir, gece hayatı haberi çıkar.
  int loyalty;     // Yüksekse kulübü satmaz.
  int leadership;  // Kaptanlık etkisi.
  
  // Yeni özellikler
  List<String> traits; // Örn: ["Leader", "Reliable"]
  String chaosTrigger; // Örn: "Defensive Errors"
  
  // Oyun içi durum
  String status; // "Happy", "Angry", "Unrest", "Injured"
  int consecutiveBench; // Arka arkaya yedek kalma sayısı

  Player({
    required this.id,
    required this.name,
    required this.team,
    required this.age,
    required this.position,
    required this.role,
    required this.jerseyNumber,
    this.skill = 75,
    this.fitness = 100,
    this.ego = 50,
    this.ambition = 50,
    this.discipline = 80,
    this.loyalty = 50,
    this.leadership = 40,
    this.traits = const [],
    this.chaosTrigger = "",
    this.status = "Happy",
    this.consecutiveBench = 0,
  });

  // JSON'dan Player oluşturma (yeni format)
  factory Player.fromJson(Map<String, dynamic> json) {
    return Player(
      id: json['id'] ?? '',
      name: json['name'],
      team: '', // Bu daha sonra set edilecek
      age: json['age'] ?? 25,
      position: json['role'] ?? '', // role -> position
      role: json['role'] ?? '',
      jerseyNumber: (json['name'] as String).length % 99 + 1, // Basit jersey numarası
      skill: json['skill'] ?? 75,
      ego: json['ego'] ?? 50,
      ambition: json['ambition'] ?? 50,
      discipline: json['discipline'] ?? 80,
      loyalty: json['loyalty'] ?? 50,
      leadership: json['leadership'] ?? 40,
      traits: List<String>.from(json['traits'] ?? []),
      chaosTrigger: json['chaos_trigger'] ?? '',
      status: "Happy",
      consecutiveBench: 0,
    );
  }

  // Oyuncu durumunu güncelle
  void updateStatus(bool played) {
    if (played) {
      consecutiveBench = 0;
      if (status == "Angry" || status == "Unrest") {
        status = "Happy";
      }
    } else {
      consecutiveBench++;
      // Ego yüksekse ve 2+ maç yedek Kalınca öfkelen
      if (ego > 85 && consecutiveBench >= 2) {
        status = "Angry";
      } else if (ego > 70 && consecutiveBench >= 3) {
        status = "Unrest";
      }
    }
  }

  // Team setter
  set team(String newTeam) {
    // Team field'i final olduğu için bu metod şu an kullanılmıyor
    // Gelecekte team field'ını final yapmaktan çıkarabiliriz
  }

  // Oyuncu hakkında kısa durum açıklaması
  String getStatusDescription() {
    switch (status) {
      case "Happy":
        return "Mutlu ve odaklanmış";
      case "Angry":
        return "Öfkeli - Menajerle konuşmak istiyor";
      case "Unrest":
        return "Huzursuz - Transfer talep edebilir";
      case "Injured":
        return "Sakat";
      default:
        return "Normal";
    }
  }

  // Overall getter (geriye uyumluluk için)
  int get overall => skill;
}
