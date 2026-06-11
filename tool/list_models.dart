// Run with: dart tool/list_models.dart YOUR_API_KEY
// Lists all Gemini models available for a given API key.
import 'dart:convert';
import 'dart:io';

Future<void> main(List<String> args) async {
  if (args.isEmpty) {
    print('Usage: dart tool/list_models.dart <API_KEY>');
    exit(1);
  }
  final key = args[0].trim();

  final client = HttpClient();
  final uri = Uri.parse(
    'https://generativelanguage.googleapis.com/v1beta/models?key=$key&pageSize=100',
  );

  try {
    final request = await client.getUrl(uri);
    final response = await request.close();
    final body = await response.transform(utf8.decoder).join();

    if (response.statusCode != 200) {
      print('HTTP ${response.statusCode}: $body');
      exit(1);
    }

    final data = jsonDecode(body) as Map<String, dynamic>;
    final models = (data['models'] as List<dynamic>? ?? []);

    print('\n====== AVAILABLE GEMINI MODELS (${models.length} total) ======\n');
    final generateContentModels = <String>[];

    for (final m in models) {
      final name = (m['name'] as String).replaceFirst('models/', '');
      final methods = (m['supportedGenerationMethods'] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toList();
      final supportsGenerate = methods.contains('generateContent');
      final displayName = m['displayName'] ?? name;

      if (supportsGenerate) generateContentModels.add(name);

      final prefix = supportsGenerate ? '✓' : '✗';
      print('$prefix  $name');
      print('   Display: $displayName');
      print('   Methods: $methods\n');
    }

    print('\n====== MODELS SUPPORTING generateContent ======');
    for (final m in generateContentModels) {
      print("  '$m',");
    }
    print('');
  } finally {
    client.close();
  }
}
