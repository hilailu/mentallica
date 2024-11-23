import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../auth/auth.dart';

Future<void> handleBgMessage(RemoteMessage message) async {
  print('${message.notification?.title}');
  print('${message.notification?.body}');
  print('${message.data}');
}

class FirebaseApi {
  final _firebaseMessaging = FirebaseMessaging.instance;
  final _firestore = FirebaseFirestore.instance;

  Future<void> updateNotificationToken(String? token) async {
    try {
      final userId = Auth().userId;
      if (token != null) {
        await _firestore.collection('users').doc(userId).update({
          'notificationToken': token,
        });
        print('Notification token updated: $token');
      }
    } catch (e) {
      print('Failed to update notification token: $e');
    }
  }

  final _androidChannel = const AndroidNotificationChannel(
    'high_importance_channel',
    'High Importance Notifications',
    description: 'This channel is used for important notifications',
    importance: Importance.defaultImportance,
  );

  final _localNotifs = FlutterLocalNotificationsPlugin();

  void handleMessage(RemoteMessage? message) {
    if (message == null) return;

    // navigate to notifs screen
  }

  Future initLocalNotifications() async {
    const android = AndroidInitializationSettings('@drawable/ic_launcher');
    const settings = InitializationSettings(android: android);
    
    await _localNotifs.initialize(settings);
    final platform = _localNotifs.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    await platform?.createNotificationChannel(_androidChannel);
  }

  Future initPushNotifications() async {
    await _firebaseMessaging.setForegroundNotificationPresentationOptions(alert: true, badge: true, sound: true);

    _firebaseMessaging.onTokenRefresh.listen((newToken) {
      updateNotificationToken(Auth().userId);
    });

    _firebaseMessaging.getInitialMessage().then(handleMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(handleMessage);
    FirebaseMessaging.onBackgroundMessage(handleBgMessage);
    FirebaseMessaging.onMessage.listen((message) {
      final notif = message.notification;
      if (notif == null) return;

      _localNotifs.show(notif.hashCode, notif.title, notif.body,
        NotificationDetails(android: AndroidNotificationDetails(
            _androidChannel.id, _androidChannel.name,
            channelDescription: _androidChannel.description,
            icon: '@drawable/ic_launcher')),
        payload: jsonEncode(message.toMap()),);
    });
  }

  Future<void> initNotifications() async {
    await _firebaseMessaging.requestPermission();
    final token = await _firebaseMessaging.getToken();
    print('Token: $token');
    updateNotificationToken(token);
    initPushNotifications();
    initLocalNotifications();
  }
}