import 'dart:convert';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../../features/study/domain/models/note.dart';
import 'package:uuid/uuid.dart';

class GeminiService {
  final String apiKey;
  late final GenerativeModel model;

  GeminiService(this.apiKey) {
    model = GenerativeModel(model: 'gemini-2.0-flash', apiKey: apiKey);
  }

  Future<Note> generateNoteFromText(String text, String subjectId) async {
    final prompt =
        '''
    Analyze the following lecture text and provide a comprehensive structured study note.
    Your response MUST be in RAW JSON format with the following keys:
    1. "title": A descriptive, specific title reflecting the main topic (max 8 words).
    2. "summary_points": A list of 8-12 detailed, summarized bullet points that cover all key info.
    3. "key_concepts": A list of 5-7 technical terms or key definitions.
    4. "quick_review": A 2-sentence highly focused review for quick exam prep.

    IMPORTANT: 
    - Output ONLY raw JSON.
    - Do NOT use markdown symbols (like *, **, #, -) inside JSON strings. 
    - Provide deep, summarized value rather than generic responses.
    - Ensure bullet points are distinct and educational.

    Lecture Text:
    $text
    ''';

    try {
      final content = [Content.text(prompt)];
      final response = await model.generateContent(content);

      final resultText = response.text ?? "{}";

      // Clean up markdown block markers if present
      final cleanedJson = resultText
          .replaceAll('```json', '')
          .replaceAll('```', '')
          .trim();
      final Map<String, dynamic> data = jsonDecode(cleanedJson);

      return Note(
        id: const Uuid().v4(),
        subjectId: subjectId,
        title:
            data['title'] ??
            "Lecture Note - ${DateTime.now().hour}:${DateTime.now().minute}",
        content:
            (data['summary_points'] as List<dynamic>?)?.join('\n') ??
            "No summary points provided.",
        keyConcepts:
            (data['key_concepts'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList() ??
            ["General Concept"],
        quickReview:
            data['quick_review'] ??
            "Review this note to reinforce your understanding.",
        createdAt: DateTime.now(),
      );
    } catch (e) {
      print('Gemini Integration Error: $e');
      return Note(
        id: const Uuid().v4(),
        subjectId: subjectId,
        title:
            "Lecture Summary - ${DateTime.now().month}/${DateTime.now().day}",
        content:
            "The AI could not parse the response. Please provide more detailed lecture text to get better results.",
        keyConcepts: ["Analysis Error"],
        quickReview:
            "We encountered an issue while summarizing this specific text.",
        createdAt: DateTime.now(),
      );
    }
  }
}
