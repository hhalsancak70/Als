import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:hobby/Screens/Intro.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hobby/Screens/BottomBar.dart';
import 'dart:io';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:provider/provider.dart';
import 'package:hobby/Model/theme_notifier.dart';

// Global değişkenler
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

// Bildirim kanalı
const AndroidNotificationChannel channel = AndroidNotificationChannel(
  'high_importance_channel',
  'Yüksek Önemli Bildirimler',
  description: 'Bu kanal önemli bildirimleri gösterir',
  importance: Importance.high,
);

// Arka plan mesaj işleyici
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('Arka plan mesajı alındı: ${message.messageId}');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Yerel bildirimleri başlat
  await flutterLocalNotificationsPlugin.initialize(
    const InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(),
    ),
  );

  // Android için bildirim kanalını oluştur
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  // Firebase'i başlat
  await Firebase.initializeApp();

  // FCM arka plan işleyicisini ayarla
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // Bildirim izinlerini iste
  final messaging = FirebaseMessaging.instance;
  await messaging.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );

  // FCM token'ı al ve Firestore'a kaydet
  String? token = await messaging.getToken();
  if (token != null) {
    await FirebaseFirestore.instance.collection('fcm_tokens').doc(token).set({
      'token': token,
      'createdAt': FieldValue.serverTimestamp(),
      'platform': Platform.operatingSystem,
    });
  }

  // Token yenilendiğinde güncelle
  messaging.onTokenRefresh.listen((String newToken) async {
    await FirebaseFirestore.instance
        .collection('fcm_tokens')
        .doc(newToken)
        .set({
      'token': newToken,
      'updatedAt': FieldValue.serverTimestamp(),
      'platform': Platform.operatingSystem,
    });
  });

  // Ön plandaki mesajları dinle
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    print('Ön plan mesajı alındı: ${message.notification?.title}');
    if (message.notification != null) {
      flutterLocalNotificationsPlugin.show(
        message.hashCode,
        message.notification?.title,
        message.notification?.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            channel.id,
            channel.name,
            channelDescription: channel.description,
            icon: 'launch_background',
            importance: Importance.high,
          ),
          iOS: const DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
      );
    }
  });

  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeNotifier(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeNotifier>(
      builder: (context, themeNotifier, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Hobby',
          theme: ThemeData(
            primarySwatch: Colors.deepPurple,
            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.deepPurple,
              foregroundColor: Colors.white,
            ),
            bottomAppBarTheme: const BottomAppBarTheme(
              color: Colors.deepPurple,
            ),
          ),
          darkTheme: ThemeData.dark().copyWith(
            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
            ),
            bottomAppBarTheme: const BottomAppBarTheme(
              color: Colors.black,
            ),
          ),
          themeMode:
              themeNotifier.isDarkMode ? ThemeMode.dark : ThemeMode.light,
          home: StreamBuilder<User?>(
            stream: FirebaseAuth.instance.authStateChanges(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              // Kullanıcı oturum açmışsa
              if (snapshot.hasData) {
                return const BottomBar(); // BottomBar yapısını koruyoruz
              }

              // Kullanıcı oturum açmamışsa
              return const IntroPage();
            },
          ),
        );
      },
    );
  }
}

// Yerel bildirim gösterme fonksiyonu
void showFlutterNotification(RemoteMessage message) {
  flutterLocalNotificationsPlugin.show(
    message.hashCode,
    message.notification?.title,
    message.notification?.body,
    NotificationDetails(
      android: AndroidNotificationDetails(
        channel.id,
        channel.name,
        channelDescription: channel.description,
        icon: 'launch_background',
      ),
      iOS: const DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    ),
  );
}
