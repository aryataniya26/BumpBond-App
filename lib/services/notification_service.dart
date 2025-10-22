import 'dart:convert';
import 'package:http/http.dart' as http;

class NotificationService {
  final String token;

  NotificationService({required this.token});
  Future<void> sendTestNotification(String token) async {
    final url = "https://us-central1-ai-life-manager-b2556.cloudfunctions.net/sendNotification"; // अपना deployed function URL डालो

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          "token": token,
          "title": "Test Notification",
          "message": "This is a test message from Flutter!"
        }),
      );

      if (response.statusCode == 200) {
        print("Notification sent successfully!");
      } else {
        print("Failed to send notification: ${response.body}");
      }
    } catch (e) {
      print("Error sending notification: $e");
    }
  }

  // Replace this with your deployed Firebase Function URL
  final String _functionUrl = "https://<YOUR_REGION>-<YOUR_PROJECT_ID>.cloudfunctions.net/sendNotification";

  Future<List<Map<String, String>>> fetchNotifications() async {
    try {
      // For demo, sending a test notification request to the function
      final response = await http.post(
        Uri.parse(_functionUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "token": token,
          "title": "Hello!",
          "body": "This is a test notification"
        }),
      );

      if (response.statusCode == 200) {
        // Here we mock notifications list since function sends notification directly
        return [
          {
            "title": "Hello!",
            "message": "This is a test notification",
            "time": DateTime.now().toString()
          }
        ];
      } else {
        print("Error sending notification: ${response.statusCode}");
        return [];
      }
    } catch (e) {
      print("Exception: $e");
      return [];
    }
  }
}
