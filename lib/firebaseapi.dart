import 'package:firebase_messaging/firebase_messaging.dart';
import 'dart:async';

Future<void> handleBackgroundMessage(RemoteMessage message) async {
  print('Title: ${message.notification?.title}');
  print('Body: ${message.notification?.body}');
  print('Paylod: ${message.data}');
}

class FirebaseApi {
  final _firebaseMessaging = FirebaseMessaging.instance;
  var notificationMessage = {
    'notification': {
      'title': 'Título da Notificação',
      'body': 'Corpo da Notificação',
    },
    'tokens':
        'rWvI2u4HUle9LEzzc4JilPZ3198UofPc7Te7e5R5NO7paW02gVDxxId8BbThkt8aqrQUtcGDZF2bRGWUpXr5ZujxxZeO2zkSmSI_zae8BBzaS0', // Use a lista de tokens
  };

  Future<void> initNotifications() async {
    await _firebaseMessaging.requestPermission();
    FirebaseMessaging.onBackgroundMessage(handleBackgroundMessage);
  }
}
