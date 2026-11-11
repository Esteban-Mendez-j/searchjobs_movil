import 'dart:convert';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Canal de notificación de alta importancia para Android (8.0+).
/// El ID debe coincidir exactamente con el configurado en AndroidManifest.xml.
const AndroidNotificationChannel highImportanceChannel =
    AndroidNotificationChannel(
  'high_importance_channel',
  'Notificaciones SearchJobs',
  description:
      'Canal de alta importancia para ofertas de empleo, alertas y avisos.',
  importance: Importance.max,
  playSound: true,
  enableVibration: true,
);

/// Instancia global del plugin de notificaciones locales.
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

/// Handler de mensajes en segundo plano o con la app completamente cerrada.
/// Se ejecuta en un isolate separado y DEBE ser de nivel superior con @pragma('vm:entry-point').
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  debugPrint('>>> [FCM Background] Mensaje recibido ID: ${message.messageId}');

  // Si el mensaje viene con "notification", Android lo muestra por sí mismo
  // en la bandeja del sistema utilizando el canal por defecto (high_importance_channel).
  // Si viene como payload de solo datos ("data"), no se mostraría automáticamente;
  // por ello, forzamos su despliegue mediante notificaciones locales.
  if (message.notification == null && message.data.isNotEmpty) {
    final title = message.data['title']?.toString() ??
        message.data['header']?.toString() ??
        'SearchJobs Alerta';
    final body = message.data['body']?.toString() ??
        message.data['message']?.toString() ??
        '';

    await PushService.showLocalNotification(
      id: message.hashCode,
      title: title,
      body: body,
      payload: jsonEncode(message.data),
    );
  }
}

/// Servicio centralizado de notificaciones push (Firebase Cloud Messaging).
class PushService {
  PushService._();

  /// Clave para mostrar avisos / snackbars dentro del contexto visual activo de la app.
  static final GlobalKey<ScaffoldMessengerState> messengerKey =
      GlobalKey<ScaffoldMessengerState>();

  /// Token FCM del dispositivo actual (necesario para enviar pushes desde backend o Firebase Console).
  static String? token;

  static bool _initialized = false;

  static bool get _supported =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);

  /// Inicialización completa de Firebase Cloud Messaging y Local Notifications.
  /// Debe llamarse con `await` antes de `runApp()`.
  static Future<void> init() async {
    if (_initialized) return;
    if (!_supported) {
      debugPrint('>>> [FCM] Plataforma no soportada para notificaciones push.');
      return;
    }

    try {
      // 1. Inicializar Firebase Core
      await Firebase.initializeApp();

      // 2. Registrar el handler de background de Firebase antes de cualquier otra escucha
      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

      // 3. Inicializar Flutter Local Notifications (Android / iOS)
      const initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/ic_launcher');
      const initializationSettingsDarwin = DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      );

      const initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsDarwin,
      );

      await flutterLocalNotificationsPlugin.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: _onSelectNotification,
      );

      // 4. Crear el canal de alta importancia en Android (Requerido desde Android 8.0 / API 26)
      final androidPlatformPlugin = flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

      await androidPlatformPlugin
          ?.createNotificationChannel(highImportanceChannel);

      // 5. Configurar presentación en primer plano para Apple (iOS / macOS)
      await FirebaseMessaging.instance
          .setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );

      // 6. Solicitar permisos de notificación (Android 13+ y iOS)
      final messaging = FirebaseMessaging.instance;
      final settings = await messaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );
      debugPrint('>>> [FCM] Permiso de notificaciones: ${settings.authorizationStatus}');

      // Solicitar explícitamente en Android 13+ si aún no se solicitó
      await androidPlatformPlugin?.requestNotificationsPermission();

      // 7. Obtener y publicar el token FCM del dispositivo
      // ignore: deprecated_member_use
      token = await messaging.getToken();
      _printTokenBanner(token);

      // 8. Escuchar actualización del token si se renueva
      // ignore: deprecated_member_use
      messaging.onTokenRefresh.listen((newToken) {
        token = newToken;
        debugPrint('>>> [FCM] Token actualizado: $newToken');
      });

      // 9. Escuchar mensajes cuando la app está abierta en primer plano (Foreground)
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        debugPrint('>>> [FCM Foreground] Mensaje recibido ID: ${message.messageId}');
        _handleForegroundMessage(message);
      });

      // 10. Escuchar cuando el usuario toca una notificación con la app en segundo plano
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        debugPrint('>>> [FCM] Notificación abierta (Background): ${message.data}');
        _handleNotificationAction(message.data);
      });

      // 11. Revisar si la app fue abierta por toque en notificación estando cerrada (Terminated)
      final initialMessage = await messaging.getInitialMessage();
      if (initialMessage != null) {
        debugPrint('>>> [FCM] Notificación inicial (Terminated): ${initialMessage.data}');
        _handleNotificationAction(initialMessage.data);
      }

      _initialized = true;
    } catch (e, stack) {
      debugPrint('>>> [FCM Error] No se pudo inicializar PushService: $e');
      debugPrint('$stack');
    }
  }

  /// Imprime el token con formato visible en consola para pruebas con backend o consola Firebase.
  static void _printTokenBanner(String? tokenValue) {
    debugPrint('╔══════════════════════════════════════════════════════════════════════════════════╗');
    debugPrint('║                              FIREBASE FCM DEVICE TOKEN                           ║');
    debugPrint('╠══════════════════════════════════════════════════════════════════════════════════╣');
    debugPrint('║ $tokenValue');
    debugPrint('╚══════════════════════════════════════════════════════════════════════════════════╝');
  }

  /// Muestra una notificación visual local en la barra de estado del sistema.
  static Future<void> showLocalNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    final androidDetails = AndroidNotificationDetails(
      highImportanceChannel.id,
      highImportanceChannel.name,
      channelDescription: highImportanceChannel.description,
      importance: Importance.max,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      playSound: true,
      enableVibration: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await flutterLocalNotificationsPlugin.show(
      id,
      title,
      body,
      details,
      payload: payload,
    );
  }

  /// Gestiona mensajes recibidos en primer plano (Foreground).
  static void _handleForegroundMessage(RemoteMessage message) {
    final notification = message.notification;
    final title = notification?.title ??
        message.data['title']?.toString() ??
        message.data['header']?.toString();
    final body = notification?.body ??
        message.data['body']?.toString() ??
        message.data['message']?.toString();

    // 1. Desplegar notificación heads-up en la bandeja superior del sistema
    if (title != null || body != null) {
      showLocalNotification(
        id: message.hashCode,
        title: title ?? 'SearchJobs',
        body: body ?? '',
        payload: jsonEncode(message.data),
      );
    }

    // 2. Mostrar además un SnackBar visual dentro de la aplicación si el contexto está disponible
    final messenger = messengerKey.currentState;
    if (messenger != null && (title != null || body != null)) {
      messenger.hideCurrentSnackBar();
      messenger.showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 5),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (title != null)
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              if (body != null) Text(body),
            ],
          ),
        ),
      );
    }
  }

  static void _onSelectNotification(NotificationResponse response) {
    if (response.payload != null && response.payload!.isNotEmpty) {
      try {
        final data = jsonDecode(response.payload!) as Map<String, dynamic>;
        _handleNotificationAction(data);
      } catch (_) {}
    }
  }

  static void _handleNotificationAction(Map<String, dynamic> data) {
    debugPrint('>>> [FCM Action] Acción procesada con datos: $data');
  }
}
