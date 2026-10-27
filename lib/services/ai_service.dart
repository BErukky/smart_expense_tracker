import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/wish_item.dart';

class AiService {
  static final AiService _instance = AiService._internal();
  factory AiService() => _instance;
  AiService._internal();

  /// Generates a quick, punchy reality check / roast for an impulse purchase.
  /// Uses Groq or Gemini if an API key is provided, or rich offline heuristics if not.
  Future<String> getRealityCheck({
    required String title,
    required double amount,
    required String currencySymbol,
    String? category,
    DesireLevel desireLevel = DesireLevel.medium,
    double? workHours,
    String? apiKey,
    String provider = 'groq',
  }) async {
    final cleanKey = apiKey?.trim();
    if (cleanKey != null && cleanKey.isNotEmpty) {
      try {
        if (provider.toLowerCase() == 'gemini') {
          return await _callGemini(cleanKey, title, amount, currencySymbol, category, desireLevel, workHours);
        } else {
          return await _callGroq(cleanKey, title, amount, currencySymbol, category, desireLevel, workHours);
        }
      } catch (e) {
        // Fallback to offline on network/API failure
        return _getOfflineRealityCheck(title, amount, currencySymbol, category, desireLevel, workHours);
      }
    }

    return _getOfflineRealityCheck(title, amount, currencySymbol, category, desireLevel, workHours);
  }

  Future<String> _callGroq(
    String apiKey,
    String title,
    double amount,
    String currencySymbol,
    String? category,
    DesireLevel desireLevel,
    double? workHours,
  ) async {
    final url = Uri.parse('https://api.groq.com/openai/v1/chat/completions');
    final prompt = _buildPrompt(title, amount, currencySymbol, category, desireLevel, workHours);

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey',
      },
      body: jsonEncode({
        'model': 'llama-3.1-8b-instant',
        'messages': [
          {
            'role': 'system',
            'content':
                'You are an honest, witty financial anti-impulse advisor called "Impulse Control". '
                'Give a sharp, punchy 2-sentence reality check / gentle roast that makes the user question if they actually need this item or if it is just a dopamine spike. '
                'Be supportive but direct. Keep it under 45 words. No fluff.',
          },
          {'role': 'user', 'content': prompt},
        ],
        'temperature': 0.7,
        'max_tokens': 100,
      }),
    ).timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final content = data['choices']?[0]?['message']?['content'];
      if (content != null && content.isNotEmpty) {
        return content.trim();
      }
    }
    throw Exception('Groq API error: ${response.statusCode}');
  }

  Future<String> _callGemini(
    String apiKey,
    String title,
    double amount,
    String currencySymbol,
    String? category,
    DesireLevel desireLevel,
    double? workHours,
  ) async {
    final url = Uri.parse(
        'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=$apiKey');
    final prompt = _buildPrompt(title, amount, currencySymbol, category, desireLevel, workHours);

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'contents': [
          {
            'parts': [
              {
                'text':
                    'You are an honest, witty financial anti-impulse advisor called "Impulse Control". '
                    'Give a sharp, punchy 2-sentence reality check / gentle roast that makes the user question if they actually need this item or if it is just a dopamine spike. '
                    'Keep it under 45 words. No markdown bullet points. Here is the item: $prompt'
              }
            ]
          }
        ],
        'generationConfig': {
          'temperature': 0.7,
          'maxOutputTokens': 100,
        }
      }),
    ).timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final text = data['candidates']?[0]?['content']?['parts']?[0]?['text'];
      if (text != null && text.isNotEmpty) {
        return text.trim();
      }
    }
    throw Exception('Gemini API error: ${response.statusCode}');
  }

  String _buildPrompt(
    String title,
    double amount,
    String currencySymbol,
    String? category,
    DesireLevel desireLevel,
    double? workHours,
  ) {
    var p = 'Item: "$title", Price: $currencySymbol$amount, Urgency: ${desireLevel.name.toUpperCase()}';
    if (category != null && category.isNotEmpty) p += ', Category: $category';
    if (workHours != null && workHours > 0) p += ', Equals: ${workHours.toStringAsFixed(1)} hours of life at work';
    return p;
  }

  /// High quality offline roasts and reality checks tailored to the user's data
  String _getOfflineRealityCheck(
    String title,
    double amount,
    String currencySymbol,
    String? category,
    DesireLevel desireLevel,
    double? workHours,
  ) {
    final cat = (category ?? '').toLowerCase();

    if (workHours != null && workHours >= 8) {
      final days = (workHours / 8).toStringAsFixed(1);
      return 'You have to sacrifice $days whole workdays of your life for "$title". If someone handed you $currencySymbol$amount in cold hard cash right now, would you immediately trade it for this?';
    }

    if (cat.contains('tech') || cat.contains('gadget')) {
      return 'Is your current device really dead, or did an algorithm just feed your brain a dopamine craving? Wait out the cooling timer — if you still need "$title", it will still be there.';
    }

    if (cat.contains('fashion') || cat.contains('clothes')) {
      return 'That looks awesome in the photo, but how many unworn clothes are already sitting in your closet? Give "$title" 48 hours to prove it won\'t end up as shelf filler.';
    }

    if (cat.contains('food') || cat.contains('dining')) {
      return 'A 15-minute meal craving or an actual need? Keep $currencySymbol$amount in your pocket and let the initial hunger impulse cool off first.';
    }

    if (desireLevel == DesireLevel.high) {
      return 'Your urgency is set to HIGH. High urgency almost always means high dopamine talking. Let the cooling timer run down before your wallet pays for a fleeting mood.';
    }

    if (amount > 100) {
      return 'At $currencySymbol$amount, this is real money that could be compounding in your savings. Put it on ice and let your future self thank you.';
    }

    return 'Is "$title" a genuine life upgrade or just a quick 1-click impulse? Give it time in the cooling queue — you\'ll know for sure when the timer rings.';
  }
}
