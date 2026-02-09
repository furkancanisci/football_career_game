import 'package:flutter/material.dart';
import '../services/ai_service.dart';
import '../services/data_service.dart';
import '../models/club.dart';

class NewsScreen extends StatefulWidget {
  const NewsScreen({Key? key}) : super(key: key);

  @override
  _NewsScreenState createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen> {
  final AIService _aiService = AIService();
  List<Map<String, dynamic>> newsArticles = [];
  bool isLoading = true;
  Club? selectedClub;

  @override
  void initState() {
    super.initState();
    selectedClub = DataService.getSelectedTeam();
    _fetchNews();
  }

  Future<void> _fetchNews() async {
    if (selectedClub == null) return;

    try {
      // AI Servisinden haberleri çek
      final news = await _aiService.generateDailyNewsDigest(selectedClub!.name);
      
      if (mounted) {
        setState(() {
          newsArticles = news;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Haberler yüklenemedi: $e"), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E12),
      appBar: AppBar(
        title: const Text("MEDYA MERKEZİ", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: 1.0, color: Colors.white)),
        backgroundColor: const Color(0xFF161B22),
        centerTitle: true,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white70, size: 20),
            onPressed: () {
              setState(() => isLoading = true);
              _fetchNews();
            },
          )
        ],
      ),
      body: isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  CircularProgressIndicator(color: Colors.blueAccent),
                  SizedBox(height: 16),
                  Text("Gündem toparlanıyor...", style: TextStyle(color: Colors.white54, fontSize: 12)),
                ],
              ),
            )
          : newsArticles.isEmpty
              ? const Center(child: Text("Gündem sakin.", style: TextStyle(color: Colors.white54)))
              : ListView.separated(
                  padding: const EdgeInsets.all(12),
                  itemCount: newsArticles.length,
                  separatorBuilder: (ctx, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final article = newsArticles[index];
                    return _buildCompactNewsCard(article);
                  },
                ),
    );
  }

  Widget _buildCompactNewsCard(Map<String, dynamic> article) {
    final String type = article["type"] ?? "news";
    final Color typeColor = _getTypeColor(type);
    final String typeLabel = _getTypeLabel(type);

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF161B22),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Başlık ve Etiket Satırı
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.02),
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(8), topRight: Radius.circular(8)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildNewsTypeChip(typeLabel, typeColor),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    article["title"] ?? "Başlık Yok",
                    style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          
          // İçerik
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  article["content"] ?? "İçerik yüklenemedi.",
                  style: TextStyle(color: Colors.grey[400], fontSize: 12, height: 1.4),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 10),
                // Alt Bilgi (Tarih - Kaynak)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      article["date"] ?? "Bugün",
                      style: TextStyle(color: Colors.grey[600], fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                    Row(
                      children: [
                        Icon(Icons.newspaper, color: Colors.grey[600], size: 12),
                        const SizedBox(width: 4),
                        Text("Yapay Zeka Basını", style: TextStyle(color: Colors.grey[600], fontSize: 10)),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNewsTypeChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withOpacity(0.4), width: 0.5),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontSize: 9, fontWeight: FontWeight.bold),
      ),
    );
  }

  Color _getTypeColor(String type) {
    switch (type.toLowerCase()) {
      case "interview": return Colors.blueAccent;
      case "transfer": return Colors.orangeAccent;
      case "match": return Colors.greenAccent;
      case "crisis": return Colors.redAccent;
      case "analysis": return Colors.purpleAccent;
      default: return Colors.grey;
    }
  }

  String _getTypeLabel(String type) {
    switch (type.toLowerCase()) {
      case "interview": return "RÖPORTAJ";
      case "transfer": return "TRANSFER";
      case "match": return "MAÇ SONU";
      case "crisis": return "SON DAKİKA";
      case "analysis": return "ANALİZ";
      default: return "HABER";
    }
  }
}