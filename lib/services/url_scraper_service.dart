import 'package:http/http.dart' as http;

class ScrapedProduct {
  final String? title;
  final double? amount;
  final String? imageUrl;

  ScrapedProduct({this.title, this.amount, this.imageUrl});
}

class UrlScraperService {
  static final UrlScraperService _instance = UrlScraperService._internal();
  factory UrlScraperService() => _instance;
  UrlScraperService._internal();

  /// Scrapes basic product metadata (title, image, price) from a web store URL
  Future<ScrapedProduct?> scrapeUrl(String rawUrl) async {
    final trimmed = rawUrl.trim();
    if (!trimmed.startsWith('http://') && !trimmed.startsWith('https://')) {
      return null;
    }

    try {
      final uri = Uri.parse(trimmed);
      final response = await http.get(
        uri,
        headers: {
          'User-Agent':
              'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
          'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
        },
      ).timeout(const Duration(seconds: 6));

      if (response.statusCode != 200) return null;

      final html = response.body;

      // 1. Extract Title
      String? title = _extractMeta(html, 'og:title') ??
          _extractMeta(html, 'twitter:title') ??
          _extractTagContent(html, 'title');

      if (title != null) {
        // Clean up common suffixes like " | Amazon.com" or " - AliExpress"
        title = title.split('|').first.split(' - ').first.trim();
      }

      // 2. Extract Image
      String? imageUrl = _extractMeta(html, 'og:image') ?? _extractMeta(html, 'twitter:image');

      // 3. Extract Price
      double? amount;
      final priceStr = _extractMeta(html, 'og:price:amount') ??
          _extractMeta(html, 'product:price:amount');
      if (priceStr != null) {
        amount = double.tryParse(priceStr.replaceAll(RegExp(r'[^0-9.]'), ''));
      }

      // If price wasn't in meta, regex search in HTML
      if (amount == null) {
        final priceRegex = RegExp(r'["\x27]price["\x27]\s*:\s*["\x27]?([0-9]+(?:\.[0-9]{2})?)["\x27]?');
        final match = priceRegex.firstMatch(html);
        if (match != null && match.group(1) != null) {
          amount = double.tryParse(match.group(1)!);
        }
      }

      return ScrapedProduct(
        title: title,
        amount: amount,
        imageUrl: imageUrl,
      );
    } catch (_) {
      // Return null on network error, CORS, or invalid HTML
      return null;
    }
  }

  String? _extractMeta(String html, String property) {
    // Matches <meta property="og:title" content="..."> or <meta name="..." content="...">
    final regex = RegExp(
      '<meta\\s+(?:property|name)=["\x27]$property["\x27]\\s+content=["\x27]([^"\x27]+)["\x27]',
      caseSensitive: false,
    );
    final match = regex.firstMatch(html);
    if (match != null) return match.group(1)?.trim();

    // Inverted attribute order: content="..." property="..."
    final invertedRegex = RegExp(
      '<meta\\s+content=["\x27]([^"\x27]+)["\x27]\\s+(?:property|name)=["\x27]$property["\x27]',
      caseSensitive: false,
    );
    final invMatch = invertedRegex.firstMatch(html);
    return invMatch?.group(1)?.trim();
  }

  String? _extractTagContent(String html, String tag) {
    final regex = RegExp('<$tag[^>]*>([^<]+)<\\/$tag>', caseSensitive: false);
    final match = regex.firstMatch(html);
    return match?.group(1)?.trim();
  }
}
