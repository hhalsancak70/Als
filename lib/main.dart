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
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:flutter/foundation.dart';
import 'package:hobby/Screens/SignIn.dart';
import 'package:hobby/Screens/Register.dart';

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

  // Firebase'i başlat
  await Firebase.initializeApp();

  // Debug modunda App Check'i yapılandır
  if (kDebugMode) {
    await FirebaseAppCheck.instance.activate(
      androidProvider: AndroidProvider.debug,
    );
  } else {
    await FirebaseAppCheck.instance.activate(
      androidProvider: AndroidProvider.playIntegrity,
    );
  }

  // Firestore önbellek ayarları
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
    cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
  );

  // FCM arka plan işleyicisini ayarla
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // Bildirim izinlerini iste
  final messaging = FirebaseMessaging.instance;
  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    badge: true,
    sound: true,
    provisional: false,
    announcement: true,
    carPlay: true,
    criticalAlert: true,
  );

  print('Kullanıcı izin durumu: ${settings.authorizationStatus}');

  // FCM token'ı al ve Firestore'a kaydet
  String? token = await messaging.getToken();
  if (token != null) {
    print('FCM Token: $token'); // Debug için token'ı yazdır

    // Token'ı Firestore'a kaydet
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({
        'fcmToken': token,
        'lastTokenUpdate': FieldValue.serverTimestamp(),
      });
    }
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
          initialRoute: '/',
          routes: {
            '/': (context) => StreamBuilder<User?>(
                  stream: FirebaseAuth.instance.authStateChanges(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasData) {
                      return const BottomBar();
                    }
                    return const IntroPage();
                  },
                ),
            '/login': (context) => const SignIn(),
            '/register': (context) => const RegisterScreen(),
            '/home': (context) => const BottomBar(),
          },
          theme: ThemeData(
            // Ana renkler
            primarySwatch: Colors.deepPurple,
            primaryColor: Colors.deepPurple,
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.deepPurple,
              primary: Colors.deepPurple,
              secondary: Colors.deepOrange,
              background: Colors.grey[50]!,
            ),

            // AppBar teması
            appBarTheme: AppBarTheme(
              backgroundColor: Colors.deepPurple.shade50,
              foregroundColor: Colors.deepPurple,
              elevation: 0,
              iconTheme: const IconThemeData(color: Colors.deepPurple),
            ),

            // Bottom Navigation teması
            bottomNavigationBarTheme: BottomNavigationBarThemeData(
              backgroundColor: Colors.deepPurple.shade50,
              selectedItemColor: Colors.deepOrange,
              unselectedItemColor: Colors.deepPurple,
            ),

            // FloatingActionButton teması
            floatingActionButtonTheme: const FloatingActionButtonThemeData(
              backgroundColor: Colors.deepPurple,
              foregroundColor: Colors.white,
            ),

            // Card teması
            cardTheme: CardTheme(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),

            // Buton teması
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),

            // Chip teması
            chipTheme: ChipThemeData(
              backgroundColor: Colors.deepPurple.shade50,
              selectedColor: Colors.deepPurple.shade200,
              labelStyle: const TextStyle(color: Colors.deepPurple),
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
