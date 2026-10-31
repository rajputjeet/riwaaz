import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import '../../data/api_provider/notification_api_provider.dart';
import '../../features/notifications/customer_notifications_screen.dart';
import '../../features/vendor_panel/vendor_notifications_screen.dart';
import '../../utils/helper/storage_helper.dart';

/// FCM transport and presentation. The REST notification inbox remains the
/// source of truth; tapping a push opens the appropriate inbox for the account.
class FcmNotificationService {
  FcmNotificationService._();

  static final FcmNotificationService instance = FcmNotificationService._();

  static const _channelId = 'wedora_high_importance_channel';
  static const _channelName = 'Widoora notifications';
  static const _channelDescription = 'Booking and account notifications';

  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  bool _initialized = false;
  RemoteMessage? _initialMessage;
  Stream<String>? _tokenRefreshStream;
  Future<void> _tokenRegistrationQueue = Future<void>.value();
  String? _lastRegisteredToken;
  String? _lastRegisteredUserId;

  bool get isInitialized => _initialized;
  Stream<String>? get tokenRefreshStream => _tokenRefreshStream;

  Future<void> initialize() async {
    if (_initialized || Firebase.apps.isEmpty) return;

    try {
      const initializationSettings = InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        ),
      );
      await _localNotifications.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: _onLocalNotificationTap,
      );

      final androidNotifications = _localNotifications
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      await androidNotifications?.createNotificationChannel(
        const AndroidNotificationChannel(
          _channelId,
          _channelName,
          description: _channelDescription,
          importance: Importance.high,
        ),
      );

      await FirebaseMessaging.instance
          .setForegroundNotificationPresentationOptions(
            alert: true,
            badge: true,
            sound: true,
          );

      FirebaseMessaging.onMessage.listen(_showForegroundMessage);
      FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageTap);
      _initialMessage = await FirebaseMessaging.instance.getInitialMessage();
      _tokenRefreshStream = FirebaseMessaging.instance.onTokenRefresh;
      _tokenRefreshStream!.listen((token) => _queueTokenRegistration(token));
      _initialized = true;
    } catch (error, stackTrace) {
      // Keep app startup available when Firebase credentials have not yet
      // been added for this Widoora app.
      debugPrint('FCM initialization unavailable: $error');
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  /// Request permission on the authenticated home screen, then register the
  /// device token through the notifications API.
  Future<String?> requestPermissionAndGetToken() async {
    if (!_initialized || !StorageHelper().getIsLoggedIn()) return null;
    try {
      final token = await requestPermissionAndGetTokenForAuth();
      if (token != null && token.isNotEmpty) {
        await _queueTokenRegistration(token);
      }
      return token;
    } catch (error) {
      debugPrint('Unable to request push permission or token: $error');
      return null;
    }
  }

  /// Requests permission from signup/login and returns the token for those
  /// request bodies. It does not require an existing authenticated session.
  Future<String?> requestPermissionAndGetTokenForAuth() async {
    if (!_initialized) return null;
    try {
      final settings = await FirebaseMessaging.instance.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
      final allowed =
          settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional;
      if (!allowed) return null;
      return getTokenIfPermissionGranted();
    } catch (error) {
      debugPrint('Unable to request notification permission: $error');
      return null;
    }
  }

  /// Reads the device token only when notification permission is granted.
  Future<String?> getTokenIfPermissionGranted() async {
    if (!_initialized) return null;
    try {
      final permission = await FirebaseMessaging.instance
          .getNotificationSettings();
      final allowed =
          permission.authorizationStatus == AuthorizationStatus.authorized ||
          permission.authorizationStatus == AuthorizationStatus.provisional;
      if (!allowed) return null;

      if (Platform.isIOS) {
        await FirebaseMessaging.instance.getAPNSToken();
      }
      final token = await FirebaseMessaging.instance.getToken();
      if (token != null && token.isNotEmpty) {
        await StorageHelper().saveFcmToken(token);
      }
      return token;
    } catch (error) {
      debugPrint('Unable to read the permitted FCM token: $error');
      return null;
    }
  }

  Future<void> _queueTokenRegistration(String token) {
    final task = _tokenRegistrationQueue.then((_) async {
      final storage = StorageHelper();
      if (!storage.getIsLoggedIn()) return;
      final permission = await FirebaseMessaging.instance
          .getNotificationSettings();
      final notificationsAllowed =
          permission.authorizationStatus == AuthorizationStatus.authorized ||
          permission.authorizationStatus == AuthorizationStatus.provisional;
      if (!notificationsAllowed) return;
      final userId = storage.getUserId();
      if (_lastRegisteredToken == token && _lastRegisteredUserId == userId) {
        return;
      }

      final deviceId = await _getOrCreateDeviceId();
      final result = await NotificationApiProvider().registerDeviceToken(
        token: token,
        deviceId: deviceId,
        platform: Platform.isIOS ? 'ios' : 'android',
        appVersion: '1.0.0',
      );
      if (result.isSuccess != true) {
        debugPrint('Unable to register FCM token: ${result.message}');
        return;
      }

      await storage.saveFcmToken(token);
      _lastRegisteredToken = token;
      _lastRegisteredUserId = userId;
    });
    _tokenRegistrationQueue = task.catchError((Object error) {
      debugPrint('FCM token registration failed: $error');
    });
    return task;
  }

  Future<void> removeTokenFromServer() async {
    final storage = StorageHelper();
    if (!_initialized || !storage.getIsLoggedIn()) return;
    try {
      final token =
          storage.getFcmToken() ?? await FirebaseMessaging.instance.getToken();
      if (token == null || token.isEmpty) return;
      final deviceId = await _getOrCreateDeviceId();
      await NotificationApiProvider().removeDeviceToken(
        token: token,
        deviceId: deviceId,
      );
      _lastRegisteredToken = null;
      _lastRegisteredUserId = null;
      await storage.saveFcmToken(null);
    } catch (error) {
      // Logout must continue even if the network or push service is unavailable.
      debugPrint('Unable to remove FCM token during logout: $error');
    }
  }

  Future<String> _getOrCreateDeviceId() async {
    final storage = StorageHelper();
    final savedDeviceId = storage.getFcmDeviceId();
    if (savedDeviceId != null && savedDeviceId.isNotEmpty) return savedDeviceId;

    final random = Random.secure();
    final deviceId = List.generate(
      16,
      (_) => random.nextInt(256).toRadixString(16).padLeft(2, '0'),
    ).join();
    await storage.saveFcmDeviceId(deviceId);
    return deviceId;
  }

  Future<void> handleInitialMessageAfterShellReady() async {
    final message = _initialMessage;
    _initialMessage = null;
    if (message != null) _handleMessageTap(message);
  }

  Future<void> _showForegroundMessage(RemoteMessage message) async {
    // iOS displays foreground notification payloads using Apple's presentation
    // options above. Android needs a local notification while the app is open.
    if (Platform.isIOS || !StorageHelper().getIsLoggedIn()) return;

    final title =
        message.notification?.title ??
        _firstValue(message.data, const ['title', 'notificationTitle']) ??
        'Widoora';
    final body =
        message.notification?.body ??
        _firstValue(message.data, const ['body', 'message', 'description']) ??
        'You have a new notification.';
    final payload = jsonEncode(message.data);

    await _localNotifications.show(
      message.hashCode & 0x7fffffff,
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          channelDescription: _channelDescription,
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
      ),
      payload: payload,
    );
  }

  void _onLocalNotificationTap(NotificationResponse response) {
    final payload = response.payload;
    if (payload == null || payload.isEmpty) {
      _openInbox();
      return;
    }
    try {
      final decoded = jsonDecode(payload);
      if (decoded is Map) {
        _handleMessageTap(
          RemoteMessage(data: Map<String, dynamic>.from(decoded)),
        );
        return;
      }
    } catch (error) {
      debugPrint('Unable to read push notification payload: $error');
    }
    _openInbox();
  }

  void _handleMessageTap(RemoteMessage message) {
    if (!StorageHelper().getIsLoggedIn()) return;
    _openInbox();
  }

  void _openInbox() {
    if (Get.key.currentState == null) return;
    final roleId = StorageHelper().getRoleId();
    Get.to(
      () => roleId == 3 || roleId == 4
          ? const VendorNotificationsScreen()
          : const CustomerNotificationsScreen(),
    );
  }

  String? _firstValue(Map<String, dynamic> data, List<String> keys) {
    for (final key in keys) {
      final value = data[key]?.toString().trim();
      if (value != null && value.isNotEmpty) return value;
    }
    return null;
  }
}

@pragma('vm:entry-point')
Future<void> handleFcmBackgroundMessage(RemoteMessage message) async {
  // Notification payloads are displayed by the platform when backgrounded.
  // This handler is registered for data messages and kept top-level for the
  // Android background isolate and release-mode tree shaking.
  try {
    if (Firebase.apps.isEmpty) await Firebase.initializeApp();
    debugPrint('Received background push message: ${message.messageId ?? ''}');
  } catch (error) {
    debugPrint('Background FCM is not configured: $error');
  }
}
