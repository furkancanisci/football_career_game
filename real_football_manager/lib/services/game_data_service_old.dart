import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/team.dart';
import '../models/player.dart';

class GameDataService {
  static List<Team> allTeams = [];
  static Team? selectedTeam;
  static DateTime currentDate = DateTime(2025, 8, 1); // Sezon başlangıcı
  
  // Uygulama açılışında JSON'u yükle
  static Future<void> loadInitialData() async {
    try {
      final String response = await rootBundle.loadString('assets/data/super_lig_data.json');
      final data = await json.decode(response);
      
      List<dynamic> teamsList = data['leagues'][0]['teams'];
      allTeams = teamsList.map((teamJson) => Team.fromJson(teamJson)).toList();
      
      print('Veri yüklendi: ${allTeams.length} takım');
    } catch (e) {
      print('Veri yükleme hatası: $e');
    }
  }
  
  // Takım seçimi
  static void selectTeam(Team team) {
    selectedTeam = team;
    // Seçilen takımın oyuncularının team bilgisini güncelle
    for (var player in team.players) {
      player.team = team.name;
    }
  }
  
  // Tüm takımları getir
  static List<Team> getAllTeams() {
    return allTeams;
  }
  
  // Seçili takımı getir
  static Team? getSelectedTeam() {
    return selectedTeam;
  }
  
  // Tarihi bir gün ilerlet
  static void nextDay() {
    currentDate = currentDate.add(Duration(days: 1));
  }
  
  // Tarih formatı
  static String getFormattedDate() {
    return "${currentDate.day}/${currentDate.month}/${currentDate.year}";
  }
  
  // Lig tablosunu oluştur (sıralı)
  static List<Team> getLeagueTable() {
    List<Team> sortedTeams = List.from(allTeams);
    sortedTeams.sort((a, b) {
      if (b.points != a.points) {
        return b.points.compareTo(a.points);
      }
      // Puan eşitse averaja göre
      int aGoalDiff = a.goalsFor - a.goalsAgainst;
      int bGoalDiff = b.goalsFor - b.goalsAgainst;
      return bGoalDiff.compareTo(aGoalDiff);
    });
    
    // Pozisyonları güncelle
    for (int i = 0; i < sortedTeams.length; i++) {
      sortedTeams[i].position = i + 1;
    }
    
    return sortedTeams;
  }
}
