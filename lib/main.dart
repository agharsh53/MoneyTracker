import 'package:flutter/material.dart';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'package:workmanager/workmanager.dart';

import 'package:money_tracker/repository/screen/splash_screen.dart';

import 'package:money_tracker/database/local/database_helper.dart'; // Corrected import path

import 'package:money_tracker/common/color/colors.dart';

import 'package:permission_handler/permission_handler.dart'; // Import permission_handler for runtime permission

// --- Important: This must be a top-level function for background execution ---

@pragma('vm:entry-point') // Required for Workmanager to find this entry point

void callbackDispatcher() {
  Workmanager().executeTask((taskName, inputData) async {
    final dbHelper = DatabaseHelper();

    final FlutterLocalNotificationsPlugin notifications =
        FlutterLocalNotificationsPlugin();

// 1. Initialize FlutterLocalNotificationsPlugin in the background isolate

    const AndroidInitializationSettings androidInit =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initSettings =
        InitializationSettings(android: androidInit);

    await notifications.initialize(
        initSettings); // No onDidReceive... callbacks here for background

// 2. Ensure Notification Channel is created (Crucial for Android 8.0+)

    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'daily_expense_summary_channel', // A unique ID for your channel

      'Daily Expense Summary', // User-visible name

      description:
          'Provides a daily summary of your expenses.', // User-visible description

      importance: Importance.max, // Max importance for heads-up notifications

// No 'priority' parameter here for AndroidNotificationChannel
    );

    await notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    if (taskName == "expenseSummaryTask") {
      final today = DateTime.now();

      final allItems = await dbHelper.getAllDataItems();

      final todayItems = allItems
          .where((item) =>
              item.dateTime.year == today.year &&
              item.dateTime.month == today.month &&
              item.dateTime.day == today.day)
          .toList();

      if (todayItems.isNotEmpty) {
// Calculate min and max amounts

        double minAmount =
            todayItems.map((e) => e.amount).reduce((a, b) => a < b ? a : b);

        double maxAmount =
            todayItems.map((e) => e.amount).reduce((a, b) => a > b ? a : b);

// Show notification

        await notifications.show(
          0, // Notification ID

          "Daily Expense Summary 💸",

          "Min: ₹${minAmount.toStringAsFixed(2)} | Max: ₹${maxAmount.toStringAsFixed(2)}",

          NotificationDetails(
            // Use the defined channel

            android: AndroidNotificationDetails(
              channel.id, // Use the channel ID

              channel.name, // Use the channel name

              channelDescription: channel.description,

              importance: channel.importance, // Use channel's importance

              priority: Priority
                  .high, // Set priority here for the specific notification

              icon:
                  '@mipmap/ic_launcher', // Ensure icon is set for background notifications

              ticker: 'Daily Expense Summary',
            ),
          ),

          payload: 'daily_summary',
        );

        debugPrint("Daily Expense Summary Notification sent.");
      } else {
        debugPrint("No transactions for today. No summary notification sent.");
      }
    }

    return Future.value(true); // Indicate task success
  });
}

// --- Top-level function for background notification taps (required by flutter_local_notifications) ---

@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse notificationResponse) {
  debugPrint(
      'Notification tapped in background (terminated app): ${notificationResponse.payload}');

// You can navigate here using a GlobalKey<NavigatorState> if needed,

// or perform other background processing based on the payload.

// Note: This function runs in a separate isolate, so it cannot access the main UI's context directly.
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Always call this first

// Request notification permission for Android 13+

  await _requestNotificationPermission();

// --- Foreground Notification Setup (for immediate use and tap handling) ---

  final FlutterLocalNotificationsPlugin foregroundNotifications =
      FlutterLocalNotificationsPlugin();

  const AndroidInitializationSettings foregroundAndroidInit =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  const InitializationSettings foregroundInitSettings =
      InitializationSettings(android: foregroundAndroidInit);

  await foregroundNotifications.initialize(
    foregroundInitSettings,

    onDidReceiveNotificationResponse: (NotificationResponse response) {
      debugPrint('Foreground notification tapped: ${response.payload}');

// Handle foreground notification tap here (e.g., navigate to a specific screen)

// Example: Navigator.pushNamed(context, '/your_target_route', arguments: response.payload);
    },

    onDidReceiveBackgroundNotificationResponse:
        notificationTapBackground, // Corrected: Pass the dedicated background tap handler
  );

// --- WorkManager Setup ---

  await Workmanager().initialize(
    callbackDispatcher, // Your entry point for background tasks

    isInDebugMode: true, // Set to false for release builds
  );

// Register periodic task for daily summary

  Workmanager().registerPeriodicTask(
    "moneyTracker_expenseSummaryTask",

    "expenseSummaryTask",

    frequency: const Duration(hours: 12), // Run once every 24 hours

    initialDelay: const Duration(seconds: 30),

    constraints: Constraints(
      networkType: NetworkType.not_required,

      requiresBatteryNotLow:
          false, // Set to true if you want to delay execution when battery is low

      requiresCharging: false,

      requiresDeviceIdle: false,

      requiresStorageNotLow: false,
    ),

    tag: "daily_summary_tag",
  );

  debugPrint("Workmanager task 'expenseSummaryTask' registered.");

  runApp(const MyApp());
}

// Helper function to request notification permission for Android 13+

Future<void> _requestNotificationPermission() async {
  final status = await Permission.notification.status;

  if (status.isDenied || status.isPermanentlyDenied) {
    final result = await Permission.notification.request();

    if (result.isGranted) {
      debugPrint('Notification permission granted.');
    } else if (result.isDenied) {
      debugPrint('Notification permission denied by user.');
    } else if (result.isPermanentlyDenied) {
      debugPrint(
          'Notification permission permanently denied. Opening app settings.');

      openAppSettings();
    }
  } else if (status.isGranted) {
    debugPrint('Notification permission already granted.');
  }
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
