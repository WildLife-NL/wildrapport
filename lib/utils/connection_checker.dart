import 'package:http/http.dart' as http;

class ConnectionChecker {
  static Future<bool> hasInternetConnection([int? amount]) async {
    try {
      final response = await http
          .get(Uri.parse('https://clients3.google.com/generate_204'))
          .timeout(Duration(seconds: amount ?? 3));
      return response.statusCode == 204;
    } catch (_) {
      return false;
    }
  }
}