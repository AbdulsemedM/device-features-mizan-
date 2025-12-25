import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

class PushNotification extends StatefulWidget {
  const PushNotification({super.key});

  @override
  State<PushNotification> createState() => _PushNotificationState();
}

class _PushNotificationState extends State<PushNotification> {
  String? token;
  String? errorMessage;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    initFCM();
  }

  Future<void> initFCM() async {
    try {
      // Ensure Firebase is initialized
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp();
      }

      // Request permission first
      NotificationSettings settings = await FirebaseMessaging.instance
          .requestPermission(
            alert: true,
            badge: true,
            sound: true,
            provisional: false,
          );

      if (settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional) {
        // Wait a bit to ensure Firebase is fully ready
        await Future.delayed(const Duration(milliseconds: 500));

        // Get token with retry logic
        token = await _getTokenWithRetry();
      } else {
        errorMessage = 'Notification permission denied';
      }
    } catch (e) {
      errorMessage = 'Error initializing FCM: $e';
      print('FCM Error: $e');
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<String?> _getTokenWithRetry({int maxRetries = 3}) async {
    for (int i = 0; i < maxRetries; i++) {
      try {
        final token = await FirebaseMessaging.instance.getToken();
        print('FCM Token: $token');
        if (token != null) {
          return token;
        }
      } catch (e) {
        print('Attempt ${i + 1} failed: $e');
        if (i < maxRetries - 1) {
          // Wait before retrying (exponential backoff)
          await Future.delayed(Duration(seconds: (i + 1) * 2));
        } else {
          rethrow;
        }
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Push Notification')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : errorMessage != null
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    errorMessage!,
                    style: const TextStyle(fontSize: 16, color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        isLoading = true;
                        errorMessage = null;
                        token = null;
                      });
                      initFCM();
                    },
                    child: const Text('Retry'),
                  ),
                ],
              )
            : token != null
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Your device token:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  SelectableText(token!, style: const TextStyle(fontSize: 14)),
                ],
              )
            : const Text('No token available', style: TextStyle(fontSize: 16)),
      ),
    );
  }
}
