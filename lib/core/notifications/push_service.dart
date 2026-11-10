import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Se ejecuta cuando llega un push con la app en segundo plano o cerrada.
/// Los mensajes con "notification" los muestra el sistema Android solo.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}

/// Notificaciones push (Firebase Cloud Messaging). Solo Android.
class PushService {
  PushService._();

  /// Permite mostrar un aviso dentro de la app cuando llega un push con la app abierta.
  static final GlobalKey<ScaffoldMessengerState> messengerKey =
      GlobalKey<ScaffoldMessengerState>();

  /// Token de este dispositivo. El backend lo necesitará para enviarle pushes.
  static String? token;

  static bool get _supported =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  static Future<void> init() async {
    if (!_supported) return; // Chrome / otras plataformas: no hace nada.
    try {
      await Firebase.initializeApp();
      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

      final fm = FirebaseMessaging.instance;
      await fm.requestPermission(); // Android 13+ pregunta al usuario.

      token = await fm.getToken();
      debugPrint('FCM TOKEN: $token');
      fm.onTokenRefresh.listen((t) {
        token = t;
        debugPrint('FCM TOKEN: $t');
      });

      FirebaseMessaging.onMessage.listen(_showInApp);
    } catch (e) {
      // Si Firebase no está configurado, la app sigue funcionando sin push.
      debugPrint('Push no disponible: $e');
    }
  }

  static void _showInApp(RemoteMessage message) {
    final n = message.notification;
    if (n == null) return;
    final messenger = messengerKey.currentState;
    if (messenger == null) return;
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 6),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (n.title != null)
                Text(n.title!, style: const TextStyle(fontWeight: FontWeight.bold)),
              if (n.body != null) Text(n.body!),
            ],
          ),
        ),
      );
  }
}
