import 'dart:convert';
import 'package:http/http.dart' as http;

class LawGPTService {
  // Base URL for the server
  final String baseUrl = "https://aniudupa-ani.hf.space/"; // Use server's IP/domain in production

  /// Sends a question and chat history to the LawGPT API and retrieves the answer.
  /// [question] is the user's query.
  /// [chatHistory] is the list of previous messages for context.
  Future<String> askQuestion(String question, List<String> chatHistory, ) async {
    try {
      // Create the HTTP POST request
      final response = await http.post(
        Uri.parse("${baseUrl}chat/"), // Ensure consistent trailing slash
        headers: {"Content-Type": "application/json"}, // JSON content type
        body: jsonEncode({
          "question": question,
          "chat_history": "what is ths", // Pass chat history as a list
        }),
      );

      // Check if the response is successful
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body); // Parse JSON response
        return responseData["answer"]; // Return the answer from the response
      } else {
        // Handle error response with detailed message
        final errorData = jsonDecode(response.body);
        throw Exception(
            "Failed to get response: ${response.statusCode}, ${errorData["detail"] ?? "No additional details provided."}");
      }
    } catch (e) {
      // Catch general errors and provide detailed exception message
      throw Exception("An error occurred while connecting to LawGPT API: $e");
    }
  }
}

void main() async {
  final service = LawGPTService();

  try {
    // Example question and chat history
    final question = "What is Section 302 of IPC?";
    final chatHistory = [
      "What is Section 300 of IPC?",
      "What are the provisions under it?"
    ];

    // Get the answer from the LawGPT API
    print("Sending question to LawGPT...");
    final answer = await service.askQuestion(question, chatHistory);
    print("LawGPT Answer: $answer");
  } catch (e) {
    // Print error details if the request fails
    print("Error: $e");
  }
}
