class Player {
  final String name;
  final String team;
  final int age;
  final String position;
  
  // Teknik Özellikler (0-100)
  int overall;
  int fitness; // Kondisyon
  
  // Psikolojik & Kaos Özellikleri (0-100) - Oyunun Farkı Burada!
  int ego;         // Yüksekse yedek kalınca sorun çıkarır.
  int ambition;    // Yüksekse sürekli büyük kulübe gitmek ister.
  int discipline;  // Düşükse antrenmanı kaçırabilir, gece hayatı haberi çıkar.
  int loyalty;     // Yüksekse kulübü satmaz.
  int leadership;  // Kaptanlık etkisi.
  
  // Oyun içi durum
  String status; // "Happy", "Angry", "Unrest", "Injured"
  int consecutiveBench; // Arka arkaya yedek kalma sayısı

  Player({
    required this.name,
    required this.team,
    required this.age,
    required this.position,
    this.overall = 75,
    this.fitness = 100,
    this.ego = 50,
    this.ambition = 50,
    this.discipline = 80,
    this.loyalty = 50,
    this.leadership = 40,
    this.status = "Happy",
    this.consecutiveBench = 0,
  });

  // JSON'dan Player oluşturma
  factory Player.fromJson(Map<String, dynamic> json) {
    return Player(
      name: json['name'],
      team: json['team'] ?? '',
      age: json['age'],
      position: json['pos'],
      overall: json['ovr'],
      ego: json['ego'] ?? 50,
      ambition: json['ambition'] ?? 50,
      discipline: json['discipline'] ?? 80,
      loyalty: json['loyalty'] ?? 50,
      leadership: json['leadership'] ?? 40,
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
      // Ego yüksekse ve 2+ maç yedek kalınca öfkelen
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
}
