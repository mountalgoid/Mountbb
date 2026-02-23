import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../models/mindmap_model.dart';
import '../models/node_model.dart';

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;

    tz.initializeTimeZones();

    const androidSettings = AndroidInitializationSettings('@mipmap/launcher_icon');
    const iosSettings = DarwinInitializationSettings();

    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _plugin.initialize(settings);

    final androidImpl = _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    await androidImpl?.requestNotificationsPermission();

    final iosImpl = _plugin.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();
    await iosImpl?.requestPermissions(alert: true, badge: true, sound: true);

    _initialized = true;
  }

  int notificationIdForNode(String nodeId) => nodeId.hashCode.abs() % 2147483647;

  Future<void> scheduleNodeAlert(NodeModel node, {String? assetTitle}) async {
    await initialize();

    final int id = notificationIdForNode(node.id);

    if (!node.alertEnabled || node.alertDate == null) {
      await _plugin.cancel(id);
      return;
    }

    final DateTime triggerAt = node.alertDate!;
    if (triggerAt.isBefore(DateTime.now())) {
      await _plugin.cancel(id);
      return;
    }

    final title = assetTitle == null || assetTitle.trim().isEmpty
        ? 'MountMap Reminder'
        : 'MountMap • $assetTitle';
    final body = (node.alertMessage != null && node.alertMessage!.trim().isNotEmpty)
        ? node.alertMessage!.trim()
        : 'Reminder for: ${node.text}';

    const androidDetails = AndroidNotificationDetails(
      'mountmap_alerts',
      'MountMap Alerts',
      channelDescription: 'Reminder notifications for MountMap nodes',
      importance: Importance.max,
      priority: Priority.high,
      visibility: NotificationVisibility.public,
    );
    const iosDetails = DarwinNotificationDetails();

    await _plugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(triggerAt, tz.local),
      const NotificationDetails(android: androidDetails, iOS: iosDetails),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: null,
      payload: node.id,
    );
  }

  Future<void> cancelNodeAlert(String nodeId) async {
    await initialize();
    await _plugin.cancel(notificationIdForNode(nodeId));
  }

  Future<void> syncAllAlerts(List<MindMapAsset> assets) async {
    await initialize();

    for (final asset in assets) {
      for (final node in asset.nodes) {
        await scheduleNodeAlert(node, assetTitle: asset.title);
      }
    }

    if (kDebugMode) {
      debugPrint('Alert notifications synced: ${assets.length} assets');
    }
  }
}
