import 'dart:typed_data';

import 'package:google_generative_ai/google_generative_ai.dart';

// ──────────────────────────────────────────────
//  GeminiService
//  Smart AI note assistant — understands whether
//  voice input is new content or a command.
//
//  API key is read at compile-time via:
//    --dart-define=GEMINI_API_KEY=<your_key>
// ──────────────────────────────────────────────

/// The action the editor should take with the returned text.
enum VoiceAction { append, replace }

/// Holds the result of a smart voice processing call.
class VoiceResult {
  const VoiceResult({required this.action, required this.text});
  final VoiceAction action;
  final String text;
}

class GeminiService {
  static const _apiKey = String.fromEnvironment('GEMINI_API_KEY');
  static const _model = 'gemini-3.5-flash';

  GenerativeModel get _gemini {
    if (_apiKey.isEmpty) {
      throw const GeminiServiceException(
        'GEMINI_API_KEY is not set. '
        'Pass it via --dart-define=GEMINI_API_KEY=<key> when running the app.',
      );
    }
    return GenerativeModel(model: _model, apiKey: _apiKey);
  }

  // ── Smart voice processing ─────────────────────

  /// Processes voice audio intelligently by determining whether the user is
  /// dictating new content or giving a command about existing content.
  ///
  /// Returns a [VoiceResult] with:
  /// - [VoiceAction.append] + transcribed text if the user dictated new content
  /// - [VoiceAction.replace] + transformed text if the user gave a command
  ///
  /// [existingContent] is the current text in the editor (can be empty).
  /// Throws [GeminiServiceException] on error or empty response.
  Future<VoiceResult> processVoiceInput(
    List<int> audioBytes, {
    String mimeType = 'audio/mp4',
    String existingContent = '',
  }) async {
    try {
      final hasExistingContent = existingContent.trim().isNotEmpty;

      final prompt = StringBuffer()
        ..writeln('You are a smart AI note-taking assistant inside a personal notes app.')
        ..writeln()
        ..writeln('The user just spoke into their microphone. Your job is to figure out WHAT they want:')
        ..writeln()
        ..writeln('CASE 1 — DICTATION (new content to write down):')
        ..writeln('The user is dictating tasks, notes, ideas, reminders, or any content they want captured.')
        ..writeln('→ Transcribe it cleanly. Fix grammar. Preserve every detail and deadline mentioned.')
        ..writeln('→ Format action items as: [ ] <task> — <deadline/timing if mentioned>')
        ..writeln('→ Start your response with exactly: ACTION:APPEND')
        ..writeln('→ Then on the next line, output ONLY the clean transcribed content.')
        ..writeln()
        ..writeln('CASE 2 — COMMAND (instruction to transform existing content):')
        ..writeln('The user is giving you an instruction about the note — e.g. "organize this",')
        ..writeln('"make a to-do list", "prioritize these", "summarize", "rewrite this",')
        ..writeln('"add priorities", "sort by deadline", etc.')
        ..writeln('→ Apply their instruction to the existing note content below.')
        ..writeln('→ Start your response with exactly: ACTION:REPLACE')
        ..writeln('→ Then on the next line, output the FULL transformed note content.');

      if (hasExistingContent) {
        prompt
          ..writeln()
          ..writeln('═══ EXISTING NOTE CONTENT ═══')
          ..writeln(existingContent)
          ..writeln('═══ END OF NOTE ═══');
      } else {
        prompt
          ..writeln()
          ..writeln('(The note is currently empty — so this is almost certainly CASE 1, new content.)');
      }

      prompt
        ..writeln()
        ..writeln('RULES:')
        ..writeln('• Your response MUST start with ACTION:APPEND or ACTION:REPLACE on its own line.')
        ..writeln('• Do NOT include any intro sentences, explanations, or commentary.')
        ..writeln('• Do NOT echo back the action line in the content itself.')
        ..writeln('• If the note is empty and the user gives a command like "organize this", just say ACTION:APPEND and note that there is nothing to organize.');

      final audioPart = DataPart(mimeType, Uint8List.fromList(audioBytes));
      final content = Content.multi([TextPart(prompt.toString()), audioPart]);

      final response = await _gemini.generateContent([content]);
      final raw = response.text?.trim();

      if (raw == null || raw.isEmpty) {
        throw const GeminiServiceException(
          'Gemini returned an empty response.',
        );
      }

      // Parse the ACTION: header
      final lines = raw.split('\n');
      final firstLine = lines.first.trim().toUpperCase();

      if (firstLine == 'ACTION:REPLACE' && hasExistingContent) {
        final text = lines.skip(1).join('\n').trim();
        return VoiceResult(
          action: VoiceAction.replace,
          text: text.isEmpty ? existingContent : text,
        );
      } else {
        // Default to APPEND — safe fallback
        final text = firstLine.startsWith('ACTION:')
            ? lines.skip(1).join('\n').trim()
            : raw; // If Gemini didn't follow format, use full response
        return VoiceResult(action: VoiceAction.append, text: text);
      }
    } on GeminiServiceException {
      rethrow;
    } catch (e) {
      throw GeminiServiceException('Voice processing failed: $e');
    }
  }

  // ── Image OCR / extraction ────────────────────

  /// Sends [imageBytes] to Gemini and returns structured text extracted from the image.
  ///
  /// Supported MIME types: `image/jpeg`, `image/png`, `image/webp`, etc.
  /// Throws [GeminiServiceException] on error or empty response.
  Future<String> extractTextFromImage(
    List<int> imageBytes, {
    String mimeType = 'image/jpeg',
  }) async {
    try {
      const prompt =
          'Extract ALL text, tasks, data, and information visible in this image — do not skip anything. '
          'Structure the output as a clean personal note:\n\n'
          '• If there are action items or tasks, list them as:\n'
          '  [ ] <task> — <any date or context visible>\n'
          '• If there is general text or data (names, numbers, addresses, etc.), format it in clear labeled sections.\n'
          '• Preserve the original meaning and all details exactly.\n'
          '• Do not add commentary, summaries, or explanations — output only the extracted content.';

      final imagePart = DataPart(mimeType, Uint8List.fromList(imageBytes));
      final content = Content.multi([TextPart(prompt), imagePart]);

      final response = await _gemini.generateContent([content]);
      final text = response.text?.trim();

      if (text == null || text.isEmpty) {
        throw const GeminiServiceException(
          'Gemini returned no text from the image.',
        );
      }

      return text;
    } on GeminiServiceException {
      rethrow;
    } catch (e) {
      throw GeminiServiceException('Image text extraction failed: $e');
    }
  }
}

// ── Typed exception ───────────────────────────

class GeminiServiceException implements Exception {
  const GeminiServiceException(this.message);

  final String message;

  @override
  String toString() => 'GeminiServiceException: $message';
}
