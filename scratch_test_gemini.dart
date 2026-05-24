import 'package:google_generative_ai/google_generative_ai.dart';

void main() async {
  const apiKey = String.fromEnvironment('GEMINI_API_KEY');
  if (apiKey.isEmpty) {
    print('Error: GEMINI_API_KEY is not set. Run with --dart-define=GEMINI_API_KEY=<key>');
    return;
  }
  final model = GenerativeModel(model: 'gemini-3.5-flash', apiKey: apiKey);
  
  try {
    final content = Content.text('Test message');
    final response = await model.generateContent([content]);
    print('gemini-3.5-flash response: ${response.text}');
  } catch (e) {
    print('gemini-3.5-flash failed: $e');
  }
}
