import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  final String _baseUrl =
      'http://127.0.0.1:8000/execute';

  Future<String> sendCommand(
    String command,
  ) async {
    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'prompt': command}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['message'] ??
            "Task executed, but AI provided no message.";
      }
      return "Error: Backend returned status ${response.statusCode}";
    } catch (e) {
      return "System Error: Cannot reach backend. Details: $e";
    }
  }
}
