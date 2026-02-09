import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/player.dart';
import '../models/club.dart';

class DataService {
  static Club? _selectedTeam;
  static List<Player> _teamSquad = [];
  
  // Seçili takımı ayarla
  static void setSelectedTeam(Club team) {
    _selectedTeam = team;
  }
  
  // Seçili takımı al
  static Club? getSelectedTeam() {
    return _selectedTeam;
  }
  
  // Takım kadrosunu JSON'dan yükle
  static Future<List<Player>> getTeamSquad(String teamId) async {
    try {
      final String jsonString = await rootBundle.loadString('assets/data/super_lig_data.json');
      final data = jsonDecode(jsonString);
      
      final clubs = data['clubs'] as List;
      final team = clubs.firstWhere((club) => club['id'] == teamId, orElse: () => {});
      final squadData = team['squad'] as List;
      
      final squad = squadData.map((playerData) {
        // JSON'daki oyuncu verilerini Player modeline çevir
        return Player.fromJson({
          'id': playerData['name']?.toString().replaceAll(' ', '_').toLowerCase() ?? '',
          'name': playerData['name'],
          'age': 25, // Varsayılan yaş
          'role': playerData['role'],
          'skill': playerData['skill'],
          'ego': _calculateEgo(playerData['traits']),
          'ambition': _calculateAmbition(playerData['traits']),
          'discipline': _calculateDiscipline(playerData['traits']),
          'loyalty': _calculateLoyalty(playerData['traits']),
          'leadership': _calculateLeadership(playerData['traits']),
          'traits': List<String>.from(playerData['traits'] ?? []),
          'chaos_trigger': playerData['chaos_trigger'],
        });
      }).toList();
      
      _teamSquad = squad;
      return squad;
      
    } catch (e) {
      print('Takım kadrosu yüklenemedi: $e');
      return [];
    }
  }
  
  // Traits'den psikolojik değerleri hesapla
  static int _calculateEgo(List<dynamic>? traits) {
    if (traits == null) return 50;
    
    if (traits.contains('Ego') || traits.contains('Temperamental')) return 85;
    if (traits.contains('Hot Headed')) return 80;
    if (traits.contains('Showman')) return 75;
    if (traits.contains('Star')) return 70;
    if (traits.contains('Leader')) return 60;
    
    return 50;
  }
  
  static int _calculateAmbition(List<dynamic>? traits) {
    if (traits == null) return 50;
    
    if (traits.contains('Ambitious')) return 85;
    if (traits.contains('Young Talent')) return 75;
    if (traits.contains('Wonderkid')) return 80;
    if (traits.contains('Prospect')) return 70;
    
    return 50;
  }
  
  static int _calculateDiscipline(List<dynamic>? traits) {
    if (traits == null) return 80;
    
    if (traits.contains('Warrior')) return 90;
    if (traits.contains('Reliable')) return 85;
    if (traits.contains('Experienced')) return 85;
    if (traits.contains('Professional')) return 80;
    if (traits.contains('Fighter')) return 75;
    
    return 80;
  }
  
  static int _calculateLoyalty(List<dynamic>? traits) {
    if (traits == null) return 50;
    
    if (traits.contains('Loyal')) return 90;
    if (traits.contains('Local')) return 85;
    if (traits.contains('Club Legend')) return 95;
    if (traits.contains('Captain')) return 80;
    
    return 50;
  }
  
  static int _calculateLeadership(List<dynamic>? traits) {
    if (traits == null) return 40;
    
    if (traits.contains('Leader')) return 90;
    if (traits.contains('Captain')) return 85;
    if (traits.contains('Veteran')) return 70;
    if (traits.contains('Experienced')) return 60;
    
    return 40;
  }
  
  // Tüm kulüpleri al
  static Future<List<Club>> getAllClubs() async {
    try {
      final String jsonString = await rootBundle.loadString('assets/data/super_lig_data.json');
      final data = jsonDecode(jsonString);
      
      final clubs = data['clubs'] as List;
      return clubs.map((clubData) {
        return Club.fromJson(clubData);
      }).toList();
      
    } catch (e) {
      print('Kulüpler yüklenemedi: $e');
      return [];
    }
  }
  
  // Mevcut kadroyu al
  static List<Player> getCurrentSquad() {
    return _teamSquad;
  }
  
  // Oyuncuyu ID ile bul
  static Player? findPlayerById(String playerId) {
    try {
      return _teamSquad.firstWhere((player) => player.id == playerId);
    } catch (e) {
      return null;
    }
  }
}
