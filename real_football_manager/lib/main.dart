import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'services/game_data_service.dart';
import 'models/team.dart';
import 'models/player.dart';
import 'screens/team_selection_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // .env dosyasını projenin ana dizininden yükle
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    print("HATA: .env dosyası yüklenemedi: $e");
  }
  
  await GameDataService.loadInitialData();
  runApp(RealFootballManager());
}

class RealFootballManager extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Real Football Manager',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Color(0xFF0A0E12),
        primaryColor: Color(0xFF1A1F26),
        colorScheme: ColorScheme.dark(
          primary: Color(0xFF1A1F26),
          secondary: Colors.blueAccent,
        ),
        textTheme: TextTheme(
          bodyLarge: TextStyle(color: Colors.white),
          bodyMedium: TextStyle(color: Colors.grey[300]),
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: Color(0xFF1A1F26),
          elevation: 0,
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.0,
          ),
        ),
      ),
      home: TeamSelectionScreen(),
    );
  }
}
