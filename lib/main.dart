import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:workmanager/workmanager.dart';
import 'package:money_tracker/repository/screen/splash_screen.dart';
import 'database/local/database_helper.dart';
import 'common/color/colors.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Notification plugin init
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  const AndroidInitializationSettings androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
  const InitializationSettings initSettings = InitializationSettings(android: androidInit);
  await flutterLocalNotificationsPlugin.initialize(initSettings);

  // Android 13+ permission
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
      ?.requestPermission();

  // WorkManager init
  await Workmanager().initialize(callbackDispatcher, isInDebugMode: false);

  // Register task (trigger every 12 hours)
  Workmanager().registerPeriodicTask(
    "expenseSummaryTask",
    "expenseSummaryTask",
    frequency: const Duration(hours: 12),
    initialDelay: const Duration(seconds: 10), // for testing
  );

  runApp(const MyApp());
}

void callbackDispatcher() {
  Workmanager().executeTask((taskName, inputData) async {
    final dbHelper = DatabaseHelper();
    final notifications = FlutterLocalNotificationsPlugin();

    // Notification init for background isolate
    const AndroidInitializationSettings androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initSettings = InitializationSettings(android: androidInit);
    await notifications.initialize(initSettings);

    // Create notification channel (if not exists)
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'daily_channel',
      'Daily Expenses',
      description: 'Channel for daily expense notifications',
      importance: Importance.max,
    );
    await notifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    // Fetch today's transactions
    final today = DateTime.now();
    final allItems = await dbHelper.getAllDataItems();
    final todayItems = allItems.where((item) =>
    item.dateTime.year == today.year &&
        item.dateTime.month == today.month &&
        item.dateTime.day == today.day).toList();

    if (todayItems.isNotEmpty) {
      final minItem = todayItems.reduce((a, b) => a.amount < b.amount ? a : b);
      final maxItem = todayItems.reduce((a, b) => a.amount > b.amount ? a : b);

      // Show notification
      await notifications.show(
        0,
        "Daily Expense Summary 💸",
        "Min: ₹${minItem.amount.toStringAsFixed(2)} | Max: ₹${maxItem.amount.toStringAsFixed(2)}",
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'daily_channel',
            'Daily Expenses',
            importance: Importance.max,
            priority: Priority.high,
          ),
        ),
      );
    }

    return Future.value(true);
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Money Tracker',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Quicksand',
        primaryColor: Coloors.blueDark,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
        useMaterial3: true,
      ),
      home: SplashScreen(),
    );
  }
}
