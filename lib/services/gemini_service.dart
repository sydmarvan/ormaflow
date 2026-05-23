import 'dart:typed_data';
import 'package:google_generative_ai/google_generative_ai.dart';

class GeminiService {
  static const _apiKey = 'AIzaSyD_Bje3o-bTTJZvPjxo7HxHdfXf7zXDFPI';
  GeminiService();

  Future<GenerateContentResponse> _generateWithFallback(List<Content> content) async {
    final models = ['gemini-flash-latest', 'gemini-2.5-flash', 'gemini-3.1-flash-lite'];
    Exception? lastError;

    for (final modelName in models) {
      try {
        final model = GenerativeModel(model: modelName, apiKey: _apiKey);
        return await model.generateContent(content);
      } catch (e) {
        lastError = Exception('Gemini API Error with $modelName: $e');
        if (e.toString().contains('503') || e.toString().contains('demand')) {
          print('Model $modelName busy (503). Falling back to next model...');
          continue; // Try next model
        } else {
          rethrow; // Break out if it's a non-503 error
        }
      }
    }
    throw lastError!;
  }

  /// Transcribes raw audio bytes into a clean, structured personal note.
  Future<String?> transcribeAudio(List<int> audioBytes, {String mimeType = 'audio/mp4'}) async {
    try {
      final prompt = '''
Transcribe this audio into a clean, structured personal note. Fix any grammar issues.
IMPORTANT RULES:
1. If the audio is completely silent, or only contains background noise with no human speech, you MUST respond with exactly the word "SILENT_AUDIO" and nothing else. Do not hallucinate or guess words.
2. Output in plain text ONLY. Do not use any Markdown formatting (no asterisks, hash tags, or underscores). Use simple dashes (-) for bullet points if needed.
''';
      final audioPart = DataPart(mimeType, Uint8List.fromList(audioBytes));
      
      final content = Content.multi([
        TextPart(prompt),
        audioPart,
      ]);

      final response = await _generateWithFallback([content]);
      final text = response.text?.trim() ?? '';
      
      if (text.contains('SILENT_AUDIO') || text.isEmpty) {
        return null;
      }
      
      return text;
    } catch (e) {
      throw Exception('Gemini API Error: $e');
    }
  }

  /// Analyzes an image to extract text or identify objects, converting them into a note.
  Future<String?> analyzeImage(List<int> imageBytes, {String mimeType = 'image/jpeg'}) async {
    try {
      final prompt = '''
Analyze this image and create a structured personal note based on its contents. 
- If the image contains readable text (like a document, sign, or screenshot), extract and format the text cleanly.
- If the image contains objects, items, or a scene (like groceries, a room, or products), identify them and create a useful, descriptive list or summary.
- If it's a mix of both, provide the extracted text and describe the key objects.

IMPORTANT RULES:
1. Format the output as a clear, well-structured plain-text note. 
2. Do NOT use any Markdown formatting (no asterisks **, no hash tags #, no underscores). 
3. Use simple dashes (-) for bullet points, and use ALL CAPS for section headers if necessary.
4. Do not describe the image artificially (e.g. "This is an image of..."); just provide the useful information directly.
''';
      final imagePart = DataPart(mimeType, Uint8List.fromList(imageBytes));

      final content = Content.multi([
        TextPart(prompt),
        imagePart,
      ]);

      final response = await _generateWithFallback([content]);
      return response.text;
    } catch (e) {
      throw Exception('Gemini API Error: $e');
    }
  }
}
