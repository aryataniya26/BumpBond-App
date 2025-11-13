import 'dart:convert';
import 'package:http/http.dart' as http;

class StatePolicyService {
  final String apiKey = "YOUR_OPENAI_API_KEY";

  Future<List<Map<String, String>>> fetchPolicies(String state) async {
    final prompt = """
You are an assistant that lists Indian Government pregnancy and maternity schemes.
List 3–5 current government policies for pregnant women and new mothers in $state, India.
For each scheme, provide:
- scheme: name of scheme
- description: short summary
- benefits: main benefits
- howToApply: short guide
- link: official govt. URL
""";

    final response = await http.post(
      Uri.parse("https://api.openai.com/v1/chat/completions"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $apiKey",
      },
      body: jsonEncode({
        "model": "gpt-4o-mini", // fast, low-cost model
        "messages": [
          {"role": "user", "content": prompt}
        ]
      }),
    );

    final data = jsonDecode(response.body);
    final text = data['choices'][0]['message']['content'] as String;

    // 👇 Convert text into list of schemes (simple parsing)
    final List<Map<String, String>> schemes = [];
    final lines = text.split('\n').where((line) => line.trim().isNotEmpty);

    Map<String, String> current = {};
    for (var line in lines) {
      if (line.startsWith('- scheme:')) {
        if (current.isNotEmpty) schemes.add(current);
        current = {'scheme': line.replaceFirst('- scheme:', '').trim()};
      } else if (line.contains(':')) {
        final parts = line.split(':');
        current[parts[0].trim()] = parts.sublist(1).join(':').trim();
      }
    }
    if (current.isNotEmpty) schemes.add(current);

    return schemes;
  }
}
