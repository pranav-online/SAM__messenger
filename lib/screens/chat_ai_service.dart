import 'dart:convert';
import 'package:http/http.dart' as http;

class ChatAIService {
  static const String _apiUrl =
      'http://localhost:11434/api/generate'; // Ollama server

  /// Generates a friendly reply using Ollama's model (e.g., llama2)
  static Future<String?> generateReply(String prompt) async {
    try {
      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'model': 'llama2', // Update if you use a different model
          'prompt': 'Reply like a friendly person to: $prompt',
          'stream': true, // Set to false if you prefer single response
        }),
      );

      if (response.statusCode == 200) {
        final lines = response.body.split('\n');
        String fullReply = '';

        for (final line in lines) {
          if (line.trim().isEmpty) continue;
          final jsonLine = jsonDecode(line);
          fullReply += jsonLine['response'] ?? '';
        }

        return fullReply.trim();
      } else {
        print('❌ Ollama Error: ${response.statusCode} => ${response.body}');
        return null;
      }
    } catch (e) {
      print('❌ Exception while contacting Ollama: $e');
      return null;
    }
  }
}
