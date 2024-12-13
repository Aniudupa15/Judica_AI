import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Import shared_preferences // Import share package
import 'dart:convert';

import '../common_pages/lawgpt_service.dart'; // For encoding/decoding chat history to/from JSON

class ChatScreenJudge extends StatefulWidget {
  const ChatScreenJudge({super.key});

  @override
  _ChatScreenJudgeState createState() => _ChatScreenJudgeState();
}

class _ChatScreenJudgeState extends State<ChatScreenJudge> {
  final LawGPTService service = LawGPTService();
  final TextEditingController controller = TextEditingController();
  bool isLoading = false; // Indicate loading state
  List<Map<String, String>> chatHistory = []; // Store as question-answer pairs

  @override
  void initState() {
    super.initState();
    _loadChatHistory(); // Load chat history when the screen is initialized
  }

  // Load the chat history from SharedPreferences
  Future<void> _loadChatHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final String? savedHistory = prefs.getString('chat_history');
    if (savedHistory != null) {
      final List<dynamic> decodedHistory = json.decode(savedHistory);
      setState(() {
        chatHistory = decodedHistory
            .map((item) => Map<String, String>.from(item))
            .toList();
      });
    }
  }

  // Save the chat history to SharedPreferences
  Future<void> _saveChatHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final String encodedHistory = json.encode(chatHistory);
    prefs.setString('chat_history', encodedHistory);
  }

  // Ask a question and get an answer
  void askQuestion() async {
    if (controller.text.trim().isEmpty) return; // Prevent empty questions

    setState(() {
      isLoading = true;
    });

    try {
      final question = controller.text;
      final answer = await service.askQuestion(
        question,
        chatHistory.map((entry) => entry["question"]!).toList(),
      );

      setState(() {
        chatHistory.add({"question": question, "answer": answer});
      });
      controller.clear();

      // Save updated chat history
      await _saveChatHistory();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  // Delete a chat entry
  void deleteMessage(int index) async {
    setState(() {
      chatHistory.removeAt(index);
    });

    // Save updated chat history after deletion
    await _saveChatHistory();
  }

  // Share a chat message
  void shareMessage(int index) {
    final entry = chatHistory[index];
    final message = "You: ${entry['question']}\nLawGPT: ${entry['answer']}";
    Share.share(message); // Now properly importing and using share functionality
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background image
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/ChatBotBackground.jpg"), // Replace with your image path
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Chat content
          Column(
            children: [
              // Chat history display
              Expanded(
                child: ListView.builder(
                  itemCount: chatHistory.length,
                  itemBuilder: (context, index) {
                    final entry = chatHistory[index];
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ListTile(
                          title: Text(
                            "You: ${entry['question']}",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          tileColor: Colors.grey[300]?.withOpacity(0.8), // Semi-transparent
                          trailing: PopupMenuButton<String>(
                            onSelected: (value) {
                              if (value == 'delete') {
                                deleteMessage(index);
                              } else if (value == 'share') {
                                shareMessage(index);
                              }
                            },
                            itemBuilder: (BuildContext context) => [
                              const PopupMenuItem<String>(
                                value: 'delete',
                                child: Text('Delete Message'),
                              ),
                              const PopupMenuItem<String>(
                                value: 'share',
                                child: Text('Share'),
                              ),
                            ],
                          ),
                        ),
                        ListTile(
                          title: Text(
                            "LawGPT: ${entry['answer']}",
                            style: const TextStyle(color: Colors.black),
                          ),
                          tileColor: Colors.white.withOpacity(0.8), // Semi-transparent
                        ),
                      ],
                    );
                  },
                ),
              ),
              // Loading indicator
              if (isLoading)
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: CircularProgressIndicator(),
                ),
              // Input field
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: controller,
                        decoration: InputDecoration(
                          hintText: "Ask a question...",
                          hintStyle: const TextStyle(color: Colors.black54),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.8),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onSubmitted: (value) {
                          askQuestion();
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.send),
                      color: Theme.of(context).primaryColor,
                      onPressed: askQuestion,
                    ),
                  ],
                ),
              ),

            ],
          ),
        ],
      ),
    );
  }
}
