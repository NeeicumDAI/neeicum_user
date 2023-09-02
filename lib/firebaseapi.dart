import 'package:firebase_messaging/firebase_messaging.dart';
import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';

Future<void> handleBackgroundMessage(RemoteMessage message) async {
  print('Title: ${message.notification?.title}');
  print('Body: ${message.notification?.body}');
  print('Paylod: ${message.data}');
}

class FirebaseApi {
  final _firebaseMessaging = FirebaseMessaging.instance;

  Future<void> initNotifications() async {
    await _firebaseMessaging.requestPermission();
    final fCMToken = await _firebaseMessaging.getToken();
    print('Token: $fCMToken');
    setToken(fCMToken);
    FirebaseMessaging.onBackgroundMessage(handleBackgroundMessage);
  }

  void setToken(final fCMToken) async {
    String? uid = FirebaseAuth.instance.currentUser?.uid.trim();
    final ref =
        FirebaseDatabase.instance.ref().child('users').child(uid.toString());

    final snap = await ref.get();
    if (!(snap.exists)) {
      print('OLA');
      ref.update({'token': fCMToken.toString()});
    }
  }
}
