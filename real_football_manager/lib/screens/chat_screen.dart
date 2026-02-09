import 'package:flutter/material.dart';
import '../models/player.dart';
import '../services/ai_service.dart';

class ChatScreen extends StatefulWidget {
  final Player player;

  const ChatScreen({Key? key, required this.player}) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final AIService _aiService = AIService();
  
  final List<Map<String, dynamic>> _messages = [];
  bool _isTyping = false;

  @override
  void initState() {
    super.initState();
    _addMessage(false, "Hocam beni çağırmışsınız? Bir sorun mu var?");
  }

  void _addMessage(bool isMe, String text) {
    setState(() {
      _messages.add({"isMe": isMe, "text": text, "time": DateTime.now()});
    });

    // Otomatik Scroll
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _sendMessage() async {
    if (_controller.text.trim().isEmpty) return;

    String userText = _controller.text;
    _controller.clear();
    _addMessage(true, userText);

    setState(() => _isTyping = true);

    try {
      String response = await _aiService.getPlayerChatResponse(
        widget.player.name,
        widget.player.ego, // Modelinizde yoksa skill kullanın
        widget.player.status, 
        "Takımda işler karışık", 
        userText
      );

      if (mounted) {
        setState(() => _isTyping = false);
        _addMessage(false, response);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isTyping = false);
        _addMessage(false, "Şu an konuşmak istemiyorum hocam. (Hata)");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E12),
      appBar: AppBar(
        backgroundColor: const Color(0xFF161B22),
        elevation: 1,
        titleSpacing: 0,
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: _getSkillColor(widget.player.skill),
              child: Text(widget.player.name.substring(0, 1), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.player.name, style: const TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold)),
                Text(_isTyping ? "Yazıyor..." : "Çevrimiçi", style: TextStyle(fontSize: 12, color: _isTyping ? Colors.greenAccent : Colors.grey)),
              ],
            ),
          ],
        ),
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => Navigator.pop(context)),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                return _buildMessageBubble(msg['text'], msg['isMe']);
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: const BoxDecoration(color: Color(0xFF161B22), border: Border(top: BorderSide(color: Colors.white10))),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: "Mesajını yaz...",
                        hintStyle: TextStyle(color: Colors.grey[500]),
                        filled: true,
                        fillColor: const Color(0xFF0A0E12),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        isDense: true,
                      ),
                      onSubmitted: (_) => _sendMessage(),
                      textInputAction: TextInputAction.send,
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: _sendMessage,
                    child: CircleAvatar(backgroundColor: Colors.green[700], radius: 22, child: const Icon(Icons.send, color: Colors.white, size: 20)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(String text, bool isMe) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        decoration: BoxDecoration(
          color: isMe ? Colors.green[800] : const Color(0xFF2C333D),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: isMe ? const Radius.circular(16) : const Radius.circular(4),
            bottomRight: isMe ? const Radius.circular(4) : const Radius.circular(16),
          ),
        ),
        child: Text(text, style: const TextStyle(color: Colors.white, fontSize: 14, height: 1.4)),
      ),
    );
  }

  Color _getSkillColor(int skill) {
    if (skill >= 85) return Colors.red;
    if (skill >= 75) return Colors.orange;
    if (skill >= 65) return Colors.yellow;
    return Colors.green;
  }
}