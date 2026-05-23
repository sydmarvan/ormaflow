import 'package:google_generative_ai/google_generative_ai.dart';

void main() async {
  const apiKey = 'AIzaSyD_Bje3o-bTTJZvPjxo7HxHdfXf7zXDFPI';
  final model = GenerativeModel(model: 'gemini-flash-latest', apiKey: apiKey);
  
  try {
    final content = Content.text('Test message');
    final response = await model.generateContent([content]);
    print('gemini-flash-latest response: ${response.text}');
  } catch (e) {
    print('gemini-flash-latest failed: $e');
  }
}
