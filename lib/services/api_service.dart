import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String _baseUrl = 'https://www.aarogyamfin.com';

  static Future<Map<String, dynamic>> createOrder(String firebaseUid, String email, {int amount = 10, String planName = 'Basic'}) async {
    try {
      final uri = Uri.parse('$_baseUrl/api/payment/create-order');
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'firebase_uid': firebaseUid, 'email': email, 'amount': amount, 'plan': planName}),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        return {'success': true, 'data': jsonDecode(response.body)};
      } else {
        return {'success': false, 'error': jsonDecode(response.body)['error'] ?? 'Error'};
      }
    } catch (e) {
      return {'success': false, 'error': 'Network error: $e'};
    }
  }

  static Future<Map<String, dynamic>> verifyPayment(String firebaseUid, String orderId, String paymentId, String signature, {String planName = 'Basic'}) async {
    try {
      final uri = Uri.parse('$_baseUrl/api/payment/verify');
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'firebase_uid': firebaseUid,
          'razorpay_order_id': orderId,
          'razorpay_payment_id': paymentId,
          'razorpay_signature': signature,
          'plan': planName,
        }),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        return {'success': true};
      } else {
        return {'success': false, 'error': jsonDecode(response.body)['error'] ?? 'Error'};
      }
    } catch (e) {
      return {'success': false, 'error': 'Network error: $e'};
    }
  }

  static Future<Map<String, dynamic>> checkPaymentStatus(String firebaseUid) async {
    try {
      final uri = Uri.parse('$_baseUrl/api/payment/status');
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'firebase_uid': firebaseUid}),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return {'has_access': false};
    } catch (e) {
      return {'has_access': false};
    }
  }

  static Future<Map<String, dynamic>> uploadChatPdf(String sessionId, String? filePath, String fileName, {List<int>? bytes}) async {
    try {
      final uri = Uri.parse('$_baseUrl/api/chat/upload');
      final request = http.MultipartRequest('POST', uri);
      request.fields['session_id'] = sessionId;

      if (bytes != null) {
        request.files.add(http.MultipartFile.fromBytes(
          'pdf_file', bytes, filename: fileName,
        ));
      } else {
        request.files.add(await http.MultipartFile.fromPath(
          'pdf_file', filePath!, filename: fileName,
        ));
      }

      final streamedResponse = await request.send().timeout(const Duration(seconds: 60));
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        return {'success': true, 'data': jsonDecode(response.body)};
      } else {
        return {'success': false, 'error': jsonDecode(response.body)['error'] ?? 'Upload failed'};
      }
    } catch (e) {
      return {'success': false, 'error': 'Network error: $e'};
    }
  }

  static Future<Map<String, dynamic>> sendChatMessage(String sessionId, String message, List<Map<String, dynamic>> history) async {
    try {
      final uri = Uri.parse('$_baseUrl/api/chat/message');
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'session_id': sessionId,
          'message': message,
          'history': history,
        }),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        return {'success': true, 'data': jsonDecode(response.body)};
      } else {
        return {'success': false, 'error': jsonDecode(response.body)['error'] ?? 'Error'};
      }
    } catch (e) {
      return {'success': false, 'error': 'Network error: $e'};
    }
  }

  static Future<Map<String, dynamic>> parsePdf(String? filePath, String fileName, {List<int>? bytes}) async {
    try {
      final uri = Uri.parse('$_baseUrl/api/parse');
      final request = http.MultipartRequest('POST', uri);

      if (bytes != null) {
        request.files.add(http.MultipartFile.fromBytes(
          'pdf_file',
          bytes,
          filename: fileName,
        ));
      } else {
        request.files.add(await http.MultipartFile.fromPath(
          'pdf_file',
          filePath!,
          filename: fileName,
        ));
      }

      final streamedResponse = await request.send().timeout(
        const Duration(seconds: 60),
      );
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {'success': true, 'data': data};
      } else {
        final error = jsonDecode(response.body);
        return {'success': false, 'error': error['error'] ?? 'Unknown error'};
      }
    } catch (e) {
      return {'success': false, 'error': 'Network error: $e'};
    }
  }
}
