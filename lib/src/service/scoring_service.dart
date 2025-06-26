import 'dart:convert';
import 'package:dio/dio.dart';

class ScoringService {
  static const String _apiKey = 'AIzaSyCcKx8Hx_xynfpRLBpMM3lMqj_2vZjQvEE';
  static const String _endpoint =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash-lite-preview-06-17:generateContent';

  static final Dio _dio = Dio(
    BaseOptions(headers: {'Content-Type': 'application/json'}),
  );

  static Future<int?> sendToGemini(String base64Image, String title) async {
    final uri = '$_endpoint?key=$_apiKey';

    final body = {
      "system_instruction": {
        "parts": [
          {
            "text":
                "Đây là bức vẽ tay của trẻ em. Hãy chấm điểm từ 1 đến 10 dựa trên độ giống $title nhất (ưu tiên). Trả lời chỉ bằng một con số.",
          },
        ],
      },
      "contents": [
        {
          "parts": [
            {"text": "Đây là bức vẽ tay của trẻ em. Hãy chấm điểm từ 1 đến 10 dựa trên độ giống $title nhất (ưu tiên). Trả lời chỉ bằng một con số."},
            {
              "inlineData": {"mimeType": "image/png", "data": base64Image},
            },
          ],
        },
      ],
    };

    try {
      final response = await _dio.post(uri, data: jsonEncode(body));
      final data = response.data;
      final text = data['candidates']?[0]?['content']?['parts']?[0]?['text'];
      final score = int.tryParse(text?.replaceAll(RegExp(r'[^\d]'), '') ?? '');
      return score;
    } catch (e) {
      print("Gemini API error: $e");
      return null;
    }
  }
}
