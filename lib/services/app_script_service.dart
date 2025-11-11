// import 'dart:convert';
// import 'package:http/http.dart' as http;

// /// Apps Script Web App URL (/exec) — latest deployment
// const String kWebAppUrl =
//     'https://script.google.com/macros/s/AKfycbyNXqlkROXWdfqTp6q1OiySahH-SYpU1B9H1VmIqk_X14it3MJO1UViF3TWAfX-vt-c/exec';

// Future<bool> postToAppsScript(Map<String, String> payload) async {
//   try {
//     final uri = Uri.parse(kWebAppUrl);
//     final body = Uri(queryParameters: payload).query;
//     final res = await http.post(
//       uri,
//       headers: {
//         'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8',
//       },
//       body: body,
//     );
//     if (res.statusCode == 200) {
//       try {
//         final data = jsonDecode(res.body);
//         return data is Map && data['ok'] == true;
//       } catch (_) {
//         return true;
//       }
//     }
//   } catch (_) {}
//   return false;
// }

import 'dart:convert';
import 'package:http/http.dart' as http;

/// Apps Script Web App URL (/exec) — latest deployment
const String kWebAppUrl =
    'https://script.google.com/macros/s/AKfycbzZSlZ0FLy27f_ybWxEffrqIcqY7tOQJcJf723TPSgmQuPUQd87WuWY9ZeIKIyF6nUR/exec';
// 'https://script.google.com/macros/s/AKfycbzv6DW_GTdPcH5-a1nZAazXtAs5ZYoZPqwAB8LeNQsb9siOheWP8csQTWBkGUgfU9xfiA/exec';

Future<bool> postToAppsScript(Map<String, String> payload) async {
  try {
    final uri = Uri.parse(kWebAppUrl);
    final body = Uri(queryParameters: payload).query;

    final res = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8',
      },
      body: body,
    );

    if (res.statusCode == 200) {
      try {
        final data = jsonDecode(res.body);
        return data is Map && data['ok'] == true;
      } catch (_) {
        // Some deployments return plain text; treat 200 as success.
        return true;
      }
    }
  } catch (_) {
    // Swallow to keep UI smooth; we also write to Firestore anyway.
  }
  return false;
}
